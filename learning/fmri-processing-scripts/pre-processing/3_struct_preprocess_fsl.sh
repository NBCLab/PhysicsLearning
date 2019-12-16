# Useage: bash 3_struct_preprocess_fsl.sh -sub ###
#set default parameters
outputdir=/home/data/nbc/physics-learning #project folder
out_anat=anatomical #output for structural scan
clean=Y #if Y, will delete everything before the script runs
braintemp=/home/applications/fsl/5.0.8/data/standard/MNI152_T1_2mm_brain.nii.gz

while [[ "$1" != "-sub"  ]]; do
	case "$1" in
		-outputdir)
			outputdir=$2
			;;
		-outputdir_anat)
			out_anat=$2
			;;
		-clean)
			clean=$2
			;;
		-h)
			echo "This script is designed to run a whole lot of freesurfer at once on the HPC"
			echo "Usage Information"
			echo "struct_preprocess_fsl.sh <options> -sub 001 002 003 ..."
			echo "-outputdir	Full path directory to project folder"
			echo "-outputdir_anat	Output folder name for the anatomical scan"
			exit
			;;
		*)
	esac
	shift
done

while [[ $# -gt 0 ]]; do
	
	if [[ "$1" != "-sub" ]]; then

    		numsess=($outputdir/data/pre-processed/$1/session*) #finds all the scanning sessions
		numsess=${#numsess[@]}
    		sessioncount=0

		while [[ $sessioncount -lt $numsess ]]; do
		
        		numanat=($outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/*) #finds all the scans in each anatomical folder
			numanat=${#numanat[@]}			
			anatcount=0
	
			while [[ $anatcount -lt $numanat ]]; do #scrolls through scan folders
				theorient=$(3dinfo -orient $braintemp)
				
				if [ "$clean" = "Y" ]; then

					if [ -d $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/fsl ]; then
					
						rm -r $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/fsl
					fi
				fi

				if [ ! -d $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/fsl ]; then
					mkdir $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/fsl
					# change the orientation of the structural image to match that of the template
					3dresample -orient $theorient -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/fsl/$out_anat-or.nii -inset $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/$out_anat.nii.gz
					gzip $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/fsl/$out_anat-or.nii

					#perform skull stripping using FSLs BET
					bet $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/fsl/$out_anat-or $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/fsl/$out_anat-bet -m
	
					mkdir $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/fsl/segment
					#perform segmentation using FSLs FAST
					fast -g -p -b -B -o $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/fsl/segment/$out_anat-bet-segment $outputdir/data/pre-processed/$1/session-$sessioncount/$out_anat/$out_anat-$anatcount/fsl/$out_anat-bet
			
				fi

				anatcount=$((anatcount + 1))			
			done
			sessioncount=$((sessioncount + 1))
    		done
	fi
	shift
done
