task='fci'
numtr1=172
numtr2=167
braintemp='MNI152_T1_2mm_brain'
outputdir=/home/data/nbc/physics-learning

while [[ $# -gt 0 ]]; do

	numsess=($outputdir/data/pre-processed/$1/session*) #gets the number of sessions for the current subject	     
	numsess=${#numsess[@]}  #gets the number of sessions for the current subject
	sessioncount=0 #Accounts for second session, change to 0 for both

	while [[ $sessioncount -lt $numsess ]]; do #scrolls through each scanning session

		numtask=($outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task*) #gets the number of task runs for the current subject	     
		numtask=${#numtask[@]}  #gets the number of tasks for the current subject
		taskcount=0		

		while [[ $taskcount -lt $numtask ]]; do #scrolls through each scanning session

			# cut first 5 volumnes, orient to match standard template, and create 4d nii file
			if [ ! -e $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task.nii.gz ]; then
				theorient=$(3dinfo -orient /home/applications/fsl/5.0.8/data/standard/$braintemp.nii.gz)
				numtr=$(3dinfo -nt $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task+orig)
				if [ $numtr -eq 172 ]; then 
					3dcalc -a $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task+orig[5..$] -expr 'a' -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-cut
					3dresample -orient $theorient -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-cut-or -inset $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-cut+orig
					3dAFNItoNIFTI -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task.nii $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-cut-or+orig
				else
                    			3dresample -orient $theorient -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-or -inset $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task+orig
					3dAFNItoNIFTI -prefix $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task.nii $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-or+orig
				fi
				gzip $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task.nii
			fi
			
			if [ ! -d $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.feat ] && [ ! -d $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth.feat ]; then

				# copy template ppi fsf file to subject dir, edit fsf file for the smoothed preprocessing
		            	cp -a $outputdir/physics-learning/ppi-scripts/template_ppi_preprocess.fsf $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.fsf
			
				anatdir=anatomical-0

				if [ ! -e $outputdir/data/pre-processed/$1/session-$sessioncount/anatomical/$anatdir/fsl/anatomical-or_brain.nii.gz ]; then
					cp $outputdir/data/pre-processed/$1/session-$sessioncount/anatomical/$anatdir/fsl/anatomical-bet.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/anatomical/$anatdir/fsl/anatomical-or_brain.nii.gz
				fi


				sed -i -e '33s:.*:set fmri(outputdir) "'$outputdir'/data/pre-processed/'$1'/session-'$sessioncount'/'$task'/'$task'-'$taskcount'/'$task'-'$taskcount'-ppi":' $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.fsf
		           	sed -i -e '270s:.*:set feat_files(1) "'$outputdir'/data/pre-processed/'$1'/session-'$sessioncount'/'$task'/'$task'-'$taskcount'/'$task'":' $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.fsf
		            	sed -i -e '276s:.*:set highres_files(1) "'$outputdir'/data/pre-processed/'$1'/session-'$sessioncount'/anatomical/'$anatdir'/fsl/anatomical-or_brain":' $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.fsf

				# copy template ppi fsf file to subject dir, edit fsf file for the non-smoothed preprocessing		            	
		            	cp $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.fsf $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth.fsf
		            	
		            	sed -i -e '33s:.*:set fmri(outputdir) "'$outputdir'/data/pre-processed/'$1'/session-'$sessioncount'/'$task'/'$task'-'$taskcount'/'$task'-'$taskcount'-ppi-nosmooth":' $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth.fsf
		            	sed -i -e '109s:.*:set fmri(smooth) 0:' $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth.fsf

				# perform feat preprocessing on smoothed and unsmoothed data
		            	feat $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.fsf
		            	feat $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth.fsf

				# copy resulting 4d non-smoothed and preprocessed data to smoothed preprocessed directory and remove nonsmoothed dir
		            	cp $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth.feat/filtered_func_data.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.feat/filtered_func_data_nosmooth.nii.gz
		            	
		            	rm -r $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth.feat
		            	
				# copy nonsmoothed fsf for no highpass filter preprocessing, edit fsf file to set highpass to 0
		            	cp $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth.fsf $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.fsf
		            	sed -i -e '33s:.*:set fmri(outputdir) "'$outputdir'/data/pre-processed/'$1'/session-'$sessioncount'/'$task'/'$task'-'$taskcount'/'$task'-'$taskcount'-ppi-nosmooth-nohp":' $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.fsf
		            	sed -i -e '118s:.*:set fmri(temphp_yn) 0:' $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.fsf
		            	sed -i -e '260s:.*:set fmri(paradigm_hp) 1.0:' $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.fsf
		            	
				# run feat preprocessing on nonsmoothed non-highpass filtered data
		            	feat $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.fsf
		            	
				# retrieve baseline stimuli timing file
		            	if [ ! -e /home/data/nbc/physics-learning/data/behavioral-data/vectors/$1/session-$sessioncount/$task/$task-$taskcount-NonPhysics.txt ]; then
		            		if [ ! -d $outputdir/data/behavioral-data/vectors/$1/session-$sessioncount/$task/ ]; then
						mkdir -p $outputdir/data/behavioral-data/vectors/$1/session-$sessioncount/$task
					fi
		            		python $outputdir/physics-learning/make-FCI.py $outputdir/data/behavioral-data/rcsv/$1/session-$sessioncount/${task^^}/${task^^}'_'$((taskcount+1)).csv $outputdir/data/behavioral-data/vectors/$1/session-$sessioncount/$task/$task-$taskcount
		            	fi
		            	
		            	cp $outputdir/data/behavioral-data/vectors/$1/session-$sessioncount/$task/$task-$taskcount-NonPhysics.txt $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/$task-$taskcount-NonPhysics.txt
		            	cp $outputdir/data/behavioral-data/vectors/$1/session-$sessioncount/$task/$task-$taskcount-Physics.txt $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/$task-$taskcount-Physics.txt
		            	
		            	#copy template .fsf file over to create timing file to regress out the non-physics data
		            	cp $outputdir/physics-learning/ppi-scripts/template_confoundev.fsf $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/confoundev.fsf
		            	sed -i -e '303s:.*:set fmri(custom1) "'$outputdir'/data/pre-processed/'$1'/session-'$sessioncount'/'$task'/'$task'-'$taskcount'/'$task'-'$taskcount'-ppi-nosmooth-nohp.feat/'$task'-'$taskcount'-Physics.txt":' $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/confoundev.fsf
		            	feat_model $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/confoundev
		            	Vest2Text $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/confoundev.mat $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/nonphys.txt
		            	rm $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/confoundev*  	
		            	fsl_glm -i $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data --out_res=$outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_nophys --demean -m $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/mask -d $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/nonphys.txt
		            	fslcpgeom $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_nophys
                    		fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_nophys -add $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/mean_func $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_nophys
                    		fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_nophys -bptf 27.5 -1 -add $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/mean_func $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_nophys
		            	
		            	#copy template .fsf file over to create timing file to regress out the non-physics data
		            	cp $outputdir/physics-learning/ppi-scripts/template_confoundev.fsf $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/confoundev.fsf
		            	sed -i -e '303s:.*:set fmri(custom1) "'$outputdir'/data/pre-processed/'$1'/session-'$sessioncount'/'$task'/'$task'-'$taskcount'/'$task'-'$taskcount'-ppi-nosmooth-nohp.feat/'$task'-'$taskcount'-NonPhysics.txt":' $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/confoundev.fsf
		            	feat_model $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/confoundev
		            	Vest2Text $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/confoundev.mat $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/phys.txt
		            	rm $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/confoundev*  	
		            	fsl_glm -i $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data --out_res=$outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_phys --demean -m $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/mask -d $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/phys.txt
		            	fslcpgeom $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_phys
                    		fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_phys -add $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/mean_func $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_phys
                    		fslmaths $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_phys -bptf 27.5 -1 -add $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/mean_func $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_phys

				# copy 4d data with phys/baseline quesitons regressed out into main ppi dir & remove nohp preprocessed dir
		            	cp $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_phys.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.feat/filtered_func_data_phys.nii.gz
		            	cp $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/filtered_func_data_nophys.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.feat/filtered_func_data_nophys.nii.gz
		            	
		            	rm -r $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-nosmooth-nohp.feat/
		            	
				# create files for scrubbing
		            	fsl_motion_outliers -i $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task -o  $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.feat/$1-session-$sessioncount-motion-outliers.txt -s $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.feat/$1-session-$sessioncount-fd.txt -p $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.feat/$1-session-$sessioncount-fd.png --fd --thresh=0.35

		            	if [ -e $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.feat/$1-session-$sessioncount-motion-outliers.txt ]; then
					python $outputdir/physics-learning/ppi-scripts/censor_non-contig_TRs.py $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.feat/$1-session-$sessioncount-motion-outliers.txt $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.feat/$1-session-$sessioncount-motion-outliers-censored.txt
				fi				
			fi

			taskcount=$((taskcount+1))
		done
		sessioncount=$((sessioncount+1))
	done
    shift #moves on to the next subject from the command line
done
