#set default parameters
braintemp=/home/applications/fsl/5.0.8/data/standard/MNI152_T1_2mm_brain.nii.gz
braintemp_head=/home/applications/fsl/5.0.8/data/standard/MNI152_T1_2mm.nii.gz
outputdir=/home/data/nbc/physics-learning
analysisdir=testanalysis
restfile=resting-state #name of the resting-state files that you read in
anatfile=anatomical #name of the anatomical files that you read in
clean=Y #removes the corresponding analysis directory
blur=5 #FWHM in mm for the blurring function
anat_preproc=fsl #fsl, spm, or freesurfer; which program used for anatomy preprocessing (segmentation, registration..)
csferode=1 #number of erosions to perform on thresholded CSF mask
wmerode=2 #number of erosions to perform on thresholded WM mask

while [[ "$1" != "-sub"  ]]; do
	case "$1" in
		-template)
			braintemp=$2
			;;
		-analysisdir)
			analysisdir=$2
			;;
		-outputdir)
			outputdir=$2
			;;
		-rest)
			restfile=$2
			;;
		-anat)
			anatfile=$2
			;;
		-anat_preproc)
			anat_preproc=$2
			;;
		-csferode)
			csferode=$2
			;;
		-wmerode)
			wmerode=$2
			;;
		-blur_FWHM)
			blur=$2
			;;
		-clean)
			clean=$2
			;;
		-h)
			echo "Usage information"
			echo "rs_preprocess_fsl <options> -sub 001 002 003 ..."
			exit
			;;
		*)
	esac
	shift
done


while [[ $# -gt 0 ]]; do
	if [[ "$1" != "-sub" ]]; then
		numsess=($outputdir/data/pre-processed/$1/session*) #gets the number of sessions for the current subject
		numsess=${#numsess[@]}  #gets the number of sessions for the current subject
		sessioncount=0

		while [[ $sessioncount -lt $numsess ]]; do #scrolls through each scanning session
			# get the orientation of the template image
			theorient=$(3dinfo -orient $braintemp)

			#*******************Resting State Preprocessing Commence************

			numrest=($outputdir/data/pre-processed/$1/session-$sessioncount/$restfile*) #gets the number of resting-state sessions for the current subject
			numrest=${#numrest[@]}  #gets the number of resting-state sessions for the current subject
			restcount=0
			csferocount=$csferode
			wmerocount=$wmerode
			gmerocount=$gmerode
			while [[ $restcount -lt $numrest ]]; do

				if [ ! -e $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile.nii.gz ]; then
					# change the orientation of the resting state image to match that of the template
					numtr=$(3dinfo -nt $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile+orig)
					if [ $numtr -eq 365 ]; then
						3dcalc -a $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile+orig[5..$] -expr 'a' -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile-cut
						3dresample -orient $theorient -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile-cut-or -inset $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile-cut+orig
						3dAFNItoNIFTI -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile.nii $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile-cut-or+orig

					else
		            			3dresample -orient $theorient -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile-or -inset $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile+orig
						3dAFNItoNIFTI -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile.nii $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile-or+orig
					fi
					gzip $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile.nii
				fi

				if [ "$clean" = "Y" ]; then
					if [ -d $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat ]; then
						rm -r $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat
					fi
				fi

				if [ ! -d $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat ]; then
	    				mkdir -p $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat #creates a subject specific output folder

					cp $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$restfile.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data.nii.gz

					numtr=$(3dinfo -nt $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data.nii.gz)
					midtr=$((numtr / 2))
					#select the middle time point as the reference volume for the resting state image

					fslroi $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/example_func $midtr 1
					formcfile=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data

					if [ -d $outputdir/data/pre-processed/$1/session-$sessioncount/$anatfile/$anatfile-1 ]; then
						anatdir=$anatfile-1
					else
						anatdir=$anatfile-0
					fi

					if [ ! -e $outputdir/data/pre-processed/$1/session-$sessioncount/anatomical/$anatdir/fsl/anatomical-or_brain.nii.gz ]; then
						cp $outputdir/data/pre-processed/$1/session-$sessioncount/anatomical/$anatdir/fsl/anatomical-bet.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/anatomical/$anatdir/fsl/anatomical-or_brain.nii.gz
					fi

					#************Perform Co-Registration**************
					mkdir $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg
					cp $outputdir/data/pre-processed/$1/session-$sessioncount/$anatfile/$anatdir/fsl/$anatfile-bet.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres.nii.gz
					cp $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/example_func.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func.nii.gz
					cp $outputdir/data/pre-processed/$1/session-$sessioncount/anatomical/$anatdir/fsl/anatomical-or.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres_head.nii.gz
					#coregister the resting state reference volume to structural space
					flirt -in $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func -ref $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres -out $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func2highres -omat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func2highres.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear

					# creates inverse transform to go from structural to resting state space
					convert_xfm -inverse -omat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2example_func.mat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func2highres.mat

					cp $braintemp_head $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/standard_head.nii.gz
					cp $braintemp $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/standard.nii.gz
					cp /home/applications/fsl/5.0.8/data/standard/MNI152_T1_2mm_brain_mask_dil.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/standard_mask.nii.gz
					# coregister the structural to standard space image
					flirt -in $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres -ref $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/standard -out $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2standard -omat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2standard.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear
					fnirt --iout=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2standard_head --in=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres_head --aff=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2standard.mat --cout=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2standard_warp --iout=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2standard --jout=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2highres_jac --config=/home/applications/fsl/5.0.8/etc/flirtsch/T1_2_MNI152_2mm.cnf --ref=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/standard_head --refmask=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/standard_mask --warpres=10,10,10

					applywarp -i $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres -r $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/standard -o $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2standard -w $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2standard_warp

					# creates the inverse transform to go from standard to strutural space
					convert_xfm -inverse -omat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/standard2highres.mat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2standard.mat

					# creates transform to go from resting to standard space
					convert_xfm -omat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func2standard.mat -concat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2standard.mat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func2highres.mat

					convertwarp --ref=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/standard --premat=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func2highres.mat --warp1=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2standard_warp --out=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func2standard_warp

					applywarp --ref=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/standard --in=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func --out=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func2standard --warp=$outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func2standard_warp

					# flirt the resting state image into standard space
					#flirt -ref $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/standard -in $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func -out $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func2standard -applyxfm -init $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func2standard.mat -interp trilinear

					# creates the transform to go from standard to resting state space
					convert_xfm -inverse -omat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/standard2example_func.mat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func2standard.mat

					#*************End Co-Registration**************

					#perform motion correction
					mcflirt -in $formcfile -out $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_mcf -reffile $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/example_func -mats -plots -spline_final -rmsrel -rmsabs

					#fsl_motion_outliers -i $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_mcf -o $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/motion_outliers.txt -s $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/motion_outliers_dvars_metrics.txt -p $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/motion_outliers_dvars_metrics.png --nomoco --dvars
					fsl_motion_outliers -i $formcfile -o $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/motion_outliers.txt -s $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/motion_outliers_fd_metrics.txt -p $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/motion_outliers_fd_metrics.png --fd --thresh=0.2

					if [ -e $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/motion_outliers.txt ]; then
						python $outputdir/physics-learning/resting-state-scripts/censor_non-contig_TRs.py $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/motion_outliers.txt $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/motion_outliers-censored.txt
					fi

					mkdir $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mc
					mv -f $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_mcf.mat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_mcf*.rms $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_mcf.par $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mc

					#finds the average functional volume
					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_mcf -Tmean $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mean_func

					# performs BET on the average functional volume
	       				bet2 $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mean_func $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask -f 0.3 -n -m
					mv $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask_mask.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask.nii.gz

					#masks the resting state data using the mask from the previous step
	       				fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_mcf -mas $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_bet

					brainthresh=$(fslstats $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_bet -p 98)
					brainthresh=$(bc -l <<< $brainthresh'/10')

					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_bet -thr $brainthresh -Tmin -bin $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask -odt char

					brightnessthresh=$(fslstats $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_mcf -k $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask -p 50)
					brightnessthresh_forblur=$(bc -l <<< $brightnessthresh'*0.75')

					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask -dilF $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask

					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_mcf -mas $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_thresh

					# finds the new average resting state volume after masking
	       				fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_thresh -Tmean $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mean_func

					#blur the dataset
					fwhm=$(bc -l <<< $blur'/2.355')
					susan $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_thresh $brightnessthresh_forblur $fwhm 3 1 1 $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mean_func $brightnessthresh_forblur $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_smooth

					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_smooth -mas $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_smooth

					normfact=$(bc -l <<< '10000/'$brightnessthresh)
					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_thresh -mul $normfact $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_intnorm
					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_smooth -mul $normfact $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_intnorm_smooth
					#fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_intnorm -Tmean $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/tempmean
					#fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_intnorm_smooth -Tmean $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/tempmean_smooth


					#flirt the CSF image into functional space
					flirt -noresampblur -in $outputdir/data/pre-processed/$1/session-$sessioncount/$anatfile/$anatdir/fsl/segment/$anatfile-bet-segment_seg_0 -ref $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func -applyxfm -init $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2example_func.mat -out $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/csf-funcspace

					# binarize the CSF PVE image
					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/csf-funcspace -bin $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/csf-funcspace

					# erode the thresholded CSF image by X voxels
					while [[ $csferocount -gt 0 ]]; do
						if [ -e $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/csf-funcspace-ero.nii.gz ]; then
							mv $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/csf-funcspace-ero.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/csf-funcspace-ero-temp.nii.gz
							3dcalc -a $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/csf-funcspace-ero-temp.nii.gz -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/csf-funcspace-ero.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k -expr 'a*(1-amongst(0,b,c,d,e,f,g))'
							rm $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/csf-funcspace-ero-temp.nii.gz
						else
							3dcalc -a $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/csf-funcspace.nii.gz -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/csf-funcspace-ero.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k -expr 'a*(1-amongst(0,b,c,d,e,f,g))'
						fi
						gzip $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/csf-funcspace-ero.nii
						csferocount=$((csferocount - 1))
					done


					#flirt the WM PVE image into functional space
					flirt -noresampblur -in $outputdir/data/pre-processed/$1/session-$sessioncount/$anatfile/$anatdir/fsl/segment/$anatfile-bet-segment_seg_2 -ref $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func -applyxfm -init $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/highres2example_func.mat -out $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/wm-funcspace

					# binarize the WM PVE image
					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/wm-funcspace -bin $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/wm-funcspace

					# erode the thresholded WM image by X voxels
					while [[ $wmerocount -gt 0 ]]; do
						if [ -e $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/wm-funcspace-ero.nii.gz ]; then
							mv $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/wm-funcspace-ero.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/wm-funcspace-ero-temp.nii.gz
							3dcalc -a $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/wm-funcspace-ero-temp.nii.gz -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/wm-funcspace-ero.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k -expr 'a*(1-amongst(0,b,c,d,e,f,g))'
							rm $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/wm-funcspace-ero-temp.nii.gz
						else
							3dcalc -a $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/wm-funcspace.nii.gz -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/wm-funcspace-ero.nii -b a+i -c a-i -d a+j -e a-j -f a+k -g a-k -expr 'a*(1-amongst(0,b,c,d,e,f,g))'
						fi
						gzip $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/wm-funcspace-ero.nii
						wmerocount=$((wmerocount - 1))
					done

					###ICA_AROMA###
					bet $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/example_func $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/example_func_mask -f 0.3 -n -m -R

					python /home/data/nbc/tools/ICA-AROMA-master/ICA_AROMA.py -in $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_intnorm_smooth.nii.gz -out $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/ICA_AROMA -mc $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mc/prefiltered_func_data_mcf.par -affmat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/reg/example_func2standard.mat -m $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/example_func_mask_mask.nii.gz -den no

					rm $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/example_func_mask.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/example_func_mask_mask.nii.gz

					motion_ics=$(cat $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/ICA_AROMA/classified_motion_ICs.txt)

					fsl_regfilt -i $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_intnorm -d $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/ICA_AROMA/melodic.ica/melodic_mix -f $motion_ics -o $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_denoise -m $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask
					fsl_regfilt -i $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_intnorm_smooth -d $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/ICA_AROMA/melodic.ica/melodic_mix -f $motion_ics -o $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_denoise_smooth -m $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask


					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_intnorm -Tmean $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/tempmean
					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_intnorm_smooth -Tmean $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/tempmean_smooth

					#extract the voxel-wise time-series for the "noise" ROIs
					fsl_glm -i $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_denoise -d $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/wm-funcspace-ero -o $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/components-wm.txt --demean --dat_norm -m $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask

					fsl_glm -i $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_denoise -d $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/csf-funcspace-ero -o $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/components-csf.txt --demean --dat_norm -m $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask

					paste $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/components-wm.txt $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/components-csf.txt > $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/nuisance-signals.txt


					#for AFNI nuisance regression
					####################Nuisance signal regression using AFNI's 3dTproject##################
					3dTproject -input $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_denoise.nii.gz -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/filtered_func_data.nii -passband 0.01 0.10 -mask $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask.nii.gz -ort $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/nuisance-signals.txt
					gzip $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/filtered_func_data.nii
					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/filtered_func_data -add $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/tempmean $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/filtered_func_data
					rm $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/tempmean.nii.gz
					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/filtered_func_data -Tmean $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mean_func

					3dTproject -input $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_denoise_smooth.nii.gz -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/filtered_func_data_smooth.nii -passband 0.01 0.10 -mask $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mask.nii.gz -ort $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/nuisance-signals.txt
					gzip $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/filtered_func_data_smooth.nii

					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/filtered_func_data_smooth -add $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/tempmean_smooth $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/filtered_func_data_smooth
					rm $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/tempmean_smooth.nii.gz
					fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/filtered_func_data_smooth -Tmean $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/mean_func_smooth


					rm $outputdir/data/pre-processed/$1/session-$sessioncount/$restfile/$restfile-$restcount/$analysisdir.feat/prefiltered_func_data_*

					#*************End Resting State Preprocessing
				fi
				restcount=$((restcount + 1))
			done
			sessioncount=$((sessioncount + 1))
	    	done
	fi
	shift
done
