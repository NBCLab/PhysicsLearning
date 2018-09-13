
task='fci'
numtr1=172
numtr2=167
braintemp='MNI152_T1_2mm_brain'
outputdir=/home/data/nbc/physics-learning
#roi='dlPFC_10mmSph'
#roi='V5MT+_10mmSph'
roi='RSC_10mm'

while [[ $# -gt 0 ]]; do

	numsess=($outputdir/data/pre-processed/$1/session*) #gets the number of sessions for the current subject	     
	numsess=${#numsess[@]}  #gets the number of sessions for the current subject
	sessioncount=1 #Accounts for second session, change to 0 for both

	while [[ $sessioncount -lt $numsess ]]; do #scrolls through each scanning session

		numtask=($outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task*) #gets the number of task runs for the current subject	     
		numtask=${#numtask[@]}  #gets the number of tasks for the current subject
		taskcount=0		

		while [[ $taskcount -lt $numtask ]]; do #scrolls through each scanning session
			
			if [ -d $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat ]; then
				rm -r $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat
			fi
			
			if [ ! -d $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat ]; then
			
				cp -r $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi.feat $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat
			
				flirt -in $outputdir/physics-learning/ppi-scripts/$roi -ref $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat/reg/example_func -applyxfm -init $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat/reg/standard2example_func.mat -out $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat/"$roi"_func
			
				fslmeants -i $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat/filtered_func_data_nosmooth.nii.gz -o $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat/$roi-tc.txt -m $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat/"$roi"_func

				python $outputdir/physics-learning/ppi-scripts/ppi_interleave.py $outputdir/data/behavioral-data/vectors/$1/session-$sessioncount/$task/$task-$taskcount-NonPhysics.txt $outputdir/data/behavioral-data/vectors/$1/session-$sessioncount/$task/$task-$taskcount-Physics.txt $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat/$task-$taskcount-Physics-NonPhysics.txt $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat/$task-$taskcount-Physics+NonPhysics.txt $1

		            	cp $outputdir/physics-learning/ppi-scripts/template_ppi_analysis.fsf $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-analysis-$roi.fsf
		            	
		            	cp $outputdir/data/behavioral-data/vectors/$1/session-$sessioncount/$task/$task-$taskcount-Physics.txt $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat/$task-$taskcount-Physics.txt
		            	cp $outputdir/data/behavioral-data/vectors/$1/session-$sessioncount/$task/$task-$taskcount-NonPhysics.txt $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat/$task-$taskcount-NonPhysics.txt
			
				anatdir=anatomical-0

				sed -i -e '270s:.*:set feat_files(1) "'$outputdir'/data/first-level/'$1'/session-'$sessioncount'/'$task'/'$task'-'$taskcount'/'$task'-'$taskcount'-ppi-'$roi'.feat":' $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-analysis-$roi.fsf
		           	if [ -e $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-$roi.feat/$1-session-$sessioncount-motion-outliers-censored.txt ]; then
		           		sed -i -e '276s:.*:set confoundev_files(1) "'$outputdir'/data/first-level/'$1'/session-'$sessioncount'/'$task'/'$task'-'$taskcount'/'$task'-'$taskcount'-ppi-'$roi'.feat/'$1'-session-'$sessioncount'-motion-outliers-censored.txt":' $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-analysis-$roi.fsf
		           	fi
		            	sed -i -e '310s:.*:set fmri(custom1) "'$outputdir'/data/first-level/'$1'/session-'$sessioncount'/'$task'/'$task'-'$taskcount'/'$task'-'$taskcount'-ppi-'$roi'.feat/'$task'-'$taskcount'-Physics-NonPhysics.txt":' $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-analysis-$roi.fsf
		            	sed -i -e '365s:.*:set fmri(custom2) "'$outputdir'/data/first-level/'$1'/session-'$sessioncount'/'$task'/'$task'-'$taskcount'/'$task'-'$taskcount'-ppi-'$roi'.feat/'$task'-'$taskcount'-Physics+NonPhysics.txt":' $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-analysis-$roi.fsf
		            	sed -i -e '420s:.*:set fmri(custom3) "'$outputdir'/data/first-level/'$1'/session-'$sessioncount'/'$task'/'$task'-'$taskcount'/'$task'-'$taskcount'-ppi-'$roi'.feat/'$roi'-tc.txt":' $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-analysis-$roi.fsf


		            	feat $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-ppi-analysis-$roi.fsf
                    	fi

			taskcount=$((taskcount+1))
		done
		
		if [ -d $outputdir/data/second-level/$1/session-$sessiontcount/$task/$1-session-$sessioncount-$task-ppi-$roi.feat ]; then 
			rm -r $outputdir/data/second-level/$1/session-$sessiontcount/$task/$1-session-$sessioncount-$task-ppi-$roi.feat 
		fi
		
		if [ ! -d $outputdir/data/second-level/$1/session-$sessiontcount/$task/$1-session-$sessioncount-$task-ppi-$roi.feat ]; then 
		
			cp -a $outputdir/physics-learning/ppi-scripts/template_ppi_sub.fsf $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-ppi.fsf

			sed -i -e '33s:.*:set fmri(outputdir) "/home/data/nbc/physics-learning/data/second-level/'$1'/session-'$sessioncount'/'$task'/'$1'-session-'$sessioncount'-'$task'-ppi-'$roi'":' $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-ppi.fsf
			sed -i -e '281s:.*:set feat_files(1) "/home/data/nbc/physics-learning/data/first-level/'$1'/session-'$sessioncount'/'$task'/'$task'-0/'$task'-0-ppi-'$roi'.feat":' $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-ppi.fsf
			sed -i -e '284s:.*:set feat_files(2) "/home/data/nbc/physics-learning/data/first-level/'$1'/session-'$sessioncount'/'$task'/'$task'-1/'$task'-1-ppi-'$roi'.feat":' $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-ppi.fsf
			sed -i -e '287s:.*:set feat_files(3) "/home/data/nbc/physics-learning/data/first-level/'$1'/session-'$sessioncount'/'$task'/'$task'-2/'$task'-2-ppi-'$roi'.feat":' $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-ppi.fsf

			feat $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-ppi.fsf
			
		fi
	        
		sessioncount=$((sessioncount+1))
	done
    shift #moves on to the next subject from the command line
done
