# Creates HEAD, BRIK, and nii files from dicom images
# Author: Michael Riedel
# USEAGE: bash 2_convert_dicoms_to_nii.sh -sub PID PID PID PID
# Note: update func and out_func in default parameters before running
#	run "module load afni" and "module load mricron" in the shell before running

#set default parameters
outputdir=/home/data/nbc/physics-learning #project folder
datadir=/home/data/nbc/DICOM/ALAI_NSF_14-007 #location of the raw DICOM files
#func=FCI #functional scan
#func=REAS #functional scan
func=RETR #functional scan
#func=Resting_State #functional scan
#out_func=fci #output for functional scan
#out_func=reas #output for functional scan
out_func=retr #output for functional scan
#out_func=resting-state #output for functional scan
anat=BRAVO #structural scan
anat2=PU #the identifier for the structural scans that had the filter applied
out_anat=anatomical #output for structural scan

while [[ "$1" != "-sub"  ]]; do
	case "$1" in
		-func)
			func=$2
			;;
		-anat)
			anat=$2
			;;
		-outputdir)
			outputdir=$2
			;;
		-outputdir_func)
			out_func=$2
			;;
		-outputdir_anat)
			out_anat=$2
			;;
		-anat_filt)
			anat2=$2
			;;
		-h)
			echo "Usage Information"
			echo "convert_dicoms.sh <options> -sub 001 002 003 ..."
			echo "-func		Identifier for the functional scan folder you want to convert"
			echo "-anat		Identifier for the anatomical scan folder you want to convert"
			echo "-outputdir	Full path directory to project folder"
			echo "-outputdir_func	Output folder name for the functional scan"
			echo "-outputdir_anat	Output folder name for the anatomical scan"
			echo "-anat_filt	Identifier for the anatomical scan folder that has been pre-filtered"
			exit
			;;
		*)
	esac
	shift
done

while [[ $# -gt 0 ]]; do #cycles through the number of subjects input at command line
	
	if [[ "$1" != "-sub" ]]; then # reads everything after the -sub

    		session_fils=($datadir/$1/*) #finds all the scanning sessions
		session_fils=$(echo ${session_fils[@]})
    		sessioncount=0

		for session_name in $session_fils; do #scrolls through each scanning session

			if [ ! -d $outputdir/data/pre-processed/$1/ ]; then

				mkdir $outputdir/data/pre-processed/$1 #creates directory for each participant
			fi

			if [ ! -d $outputdir/data/pre-processed/$1/session-$sessioncount ]; then

				mkdir $outputdir/data/pre-processed/$1/session-$sessioncount #creates directory for each scanning session
			fi

        		scan_fils=($session_name/*$func*) #finds all functional scans of interest in each folder
			scan_fils=$(echo ${scan_fils[@]})
			scans_to_convert=""
				
			for fold_name in $scan_fils; do #scrolls through scan folders

				scans_to_convert+=" ${fold_name}"
			done
			
			if [ ! -e $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/$out_anat.nii.gz ]; then

				if [ -d $session_name/*PU* ]; then

					structname=($session_name/*PU*)
					structname=$(echo ${structname[@]})
					scans_to_convert+=" ${structname}"

				else

					structname=($session_name/*$anat*)
					structname=$(echo ${structname[@]})
					scans_to_convert+=" ${structname}"
			
				fi
			fi

			echo "Converting DICOMs for the following scans:"
			echo $scans_to_convert
			anatcount=0

			for scan_name in $scans_to_convert; do

    				if echo "$scan_name"|grep -q $func; then #tests if the scanning folder is the target
					if [ -d $scan_name ]; then
						funccount=${scan_name##*_}
						if [ "$out_func" != "resting-state" ]; then
							funccount=$((funccount - 1))
						else
							funccount=0
						fi

#						if [ ! -d $outputdir/data/pre-processed/$1/session-$sessioncount/$out_func/$out_func-$funccount ]; then
						
							mkdir $outputdir/data/pre-processed/$1/session-$sessioncount/$out_func
							mkdir $outputdir/data/pre-processed/$1/session-$sessioncount/$out_func/$out_func-$funccount
							numfil=$(ls -1 $scan_name/ | wc -l)
							numTR=$((numfil / 42))

							if [ -e $outputdir/data/pre-processed/$1/session-$sessioncount/$out_func/$out_func-$funccount/$out_func+orig.HEAD ]; then
								count=1
								to3d -epan -prefix $out_func-$count -session $outputdir/data/pre-processed/$1/session-$sessioncount/$out_func/$out_func-$funccount/ -skip_outliers -time:zt 42 $numTR 2000 alt+z $scan_name/*.dcm
								count=$((count + 1))
							else
								to3d -epan -prefix $out_func -session $outputdir/data/pre-processed/$1/session-$sessioncount/$out_func/$out_func-$funccount/ -skip_outliers -time:zt 42 $numTR 2000 alt+z $scan_name/*.dcm
							fi
					
							thedate=$(date)
							if [ -a $outputdir/data/pre-processed/scan-guide.txt ]; then
								echo "$thedate	$1	session-$sessioncount	$session_name	$out_func-$funccount	$scan_name" >> $outputdir/data/pre-processed/scan-guide.txt
							else
								echo "$thedate	$1	session-$sessioncount	$session_name	$out_func-$funccount	$scan_name" > $outputdir/data/pre-processed/scan-guide.txt
							fi
#						fi
					fi
    				fi
			
				if echo "$scan_name"|grep -q "PU" || echo "$scan_name"|grep -q "BRAVO"; then

					if [ ! -e $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/$out_anat.nii.gz ]; then

						mkdir $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat
						mkdir $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount

						to3d -anat -prefix $out_anat -session $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/ $scan_name/*.dcm
						3dAFNItoNIFTI -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/$out_anat.nii $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/$out_anat+orig
						gzip $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/$out_anat.nii
					
						thedate=$(date)
						if [ -a $outputdir/data/pre-processed/scan-guide.txt ]; then
							echo "$thedate	$1	session-$sessioncount	$session_name	$out_anat-$anatcount	$scan_name" >> $outputdir/data/pre-processed/scan-guide.txt
						else
							echo "$thedate	$1	session-$sessioncount	$session_name	$out_anat-$anatcount	$scan_name" > $outputdir/data/pre-processed/scan-guide.txt
						fi
					fi
					anatcount=$((anatcount + 1))
				fi
			done
			sessioncount=$((sessioncount + 1))
    		done
	fi
	shift
done
