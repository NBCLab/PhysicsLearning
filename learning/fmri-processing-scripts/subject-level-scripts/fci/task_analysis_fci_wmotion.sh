task='fci'
numtr1=172
numtr2=167
braintemp='MNI152_T1_2mm_brain'
outputdir=/home/data/nbc/physics-learning
smooth=5

if [ ! -d $outputdir/data/first-level ]; then
	mkdir $outputdir/data/first-level
fi

if [ ! -d $outputdir/data/second-level ]; then
	mkdir $outputdir/data/second-level
fi

while [[ $# -gt 0 ]]; do

	numsess=($outputdir/data/pre-processed/$1/session*) #gets the number of sessions for the current subject	     
	numsess=${#numsess[@]}  #gets the number of sessions for the current subject
	sessioncount=0

	while [[ $sessioncount -lt $numsess ]]; do #scrolls through each scanning session

		if [ ! -d $outputdir/data/first-level/$1/session-$sessioncount/$task ]; then
			mkdir -p $outputdir/data/first-level/$1/session-$sessioncount/$task
		fi

		if [ ! -d $outputdir/data/second-level/$1/session-$sessioncount/$task ]; then
			mkdir -p $outputdir/data/second-level/$1/session-$sessioncount/$task
		fi

		if [ ! -d $outputdir/data/behavioral-data/vectors/$1/session-$sessioncount/$task/ ]; then
			mkdir -p $outputdir/data/behavioral-data/vectors/$1/session-$sessioncount/$task
		fi

		numtask=($outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task*) #gets the number of task runs for the current subject	     
		numtask=${#numtask[@]}  #gets the number of tasks for the current subject
		taskcount=0		

		while [[ $taskcount -lt $numtask ]]; do #scrolls through each scanning session

			if [ ! -d $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount ]; then
				mkdir $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount
			fi

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

#~~~ Start if statement that skips first-level analyses for sessions that have already been run

			if [ ! -d $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-"$smooth"mm.feat ]; then

		            	python $outputdir/physics-learning/make-FCI.py $outputdir/data/behavioral-data/rcsv/$1/session-$sessioncount/${task^^}/${task^^}'_'$((taskcount+1)).csv $outputdir/data/behavioral-data/vectors/$1/session-$sessioncount/$task/$task-$taskcount

		            	cp -a template_task_wmotion.fsf $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-"$smooth"mm.fsf
				if [[ $1 == "339" ]] && [ $sessioncount -eq 0 ]; then
						anatdir=anatomical-1
				else
						anatdir=anatomical-0
				fi
				
				fsl_motion_outliers -i $outputdir/data/pre-processed/$1/session-$sessioncount/$task/$task-$taskcount/$task -o $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$1-session-$sessioncount-motion-outliers.txt -s $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$1-session-$sessioncount-fd.txt -p $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$1-session-$sessioncount-fd.png --fd --thresh=0.35 
				
				if [ -e $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$1-session-$sessioncount-motion-outliers.txt ]; then
					python $outputdir/physics-learning/censor_non-contig_TRs.py $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$1-session-$sessioncount-motion-outliers.txt $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$1-session-$sessioncount-motion-outliers-censored.txt
				fi
			
				if [ ! -e $outputdir/data/pre-processed/$1/session-$sessioncount/anatomical/$anatdir/fsl/anatomical-or_brain.nii.gz ]; then
					cp $outputdir/data/pre-processed/$1/session-$sessioncount/anatomical/$anatdir/fsl/anatomical-bet.nii.gz $outputdir/data/pre-processed/$1/session-$sessioncount/anatomical/$anatdir/fsl/anatomical-or_brain.nii.gz
				fi

				sed -i -e '33s/.*/set fmri(outputdir) "\/home\/data\/nbc\/physics-learning\/data\/first-level\/'$1'\/session-'$sessioncount'\/'$task'\/'$task'-'$taskcount'\/'$task'-'$smooth'mm"/' $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-"$smooth"mm.fsf
				sed -i -e '109s/.*/set fmri(smooth) '$smooth'/' $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-"$smooth"mm.fsf
			        sed -i -e '270s/.*/set feat_files(1) "\/home\/data\/nbc\/physics-learning\/data\/pre-processed\/'$1'\/session-'$sessioncount'\/'$task'\/'$task'-'$taskcount'\/'$task'"/' $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-"$smooth"mm.fsf
			        if [ -e $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$1-session-$sessioncount-motion-outliers-censored.txt ]; then
			        	sed -i -e '276s/.*/set confoundev_files(1) "\/home\/data\/nbc\/physics-learning\/data\/first-level\/'$1'\/session-'$sessioncount'\/'$task'\/'$task'-'$taskcount'\/'$1'-session-'$sessioncount'-motion-outliers-censored.txt"/' $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-"$smooth"mm.fsf
			        fi
			        sed -i -e '279s/.*/set highres_files(1) "\/home\/data\/nbc\/physics-learning\/data\/pre-processed\/'$1'\/session-'$sessioncount'\/anatomical\/'$anatdir'\/fsl\/anatomical-or_brain"/' $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-"$smooth"mm.fsf
			        sed -i -e '313s/.*/set fmri(custom1) "\/home\/data\/nbc\/physics-learning\/data\/behavioral-data\/vectors\/'$1'\/session-'$sessioncount'\/'$task'\/'$task'-'$taskcount'-Physics.txt"/' $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-"$smooth"mm.fsf
			        sed -i -e '362s/.*/set fmri(custom2) "\/home\/data\/nbc\/physics-learning\/data\/behavioral-data\/vectors\/'$1'\/session-'$sessioncount'\/'$task'\/'$task'-'$taskcount'-NonPhysics.txt"/' $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-"$smooth"mm.fsf

			        feat $outputdir/data/first-level/$1/session-$sessioncount/$task/$task-$taskcount/$task-$taskcount-"$smooth"mm.fsf

#~~~~ End if statement that skips first-level analyses for sessions that have already been run
			fi

			taskcount=$((taskcount+1))
		done


		if [ -d $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-"$smooth"mm.gfeat ]; then
			rm -rf $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-"$smooth"mm.gfeat
#			mv $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-"$smooth"mm.gfeat $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-"$smooth"mm_wrms.gfeat
		
		fi

	        cp -a template_task_sub.fsf $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-"$smooth"mm.fsf

	        sed -i -e '33s/.*/set fmri(outputdir) "\/home\/data\/nbc\/physics-learning\/data\/second-level\/'$1'\/session-'$sessioncount'\/'$task'\/'$1'-session-'$sessioncount'-'$task'-'$smooth'mm"/' $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-"$smooth"mm.fsf
	        sed -i -e '278s/.*/set feat_files(1) "\/home\/data\/nbc\/physics-learning\/data\/first-level\/'$1'\/session-'$sessioncount'\/'$task'\/'$task'-0\/'$task'-'$smooth'mm.feat"/' $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-"$smooth"mm.fsf
		sed -i -e '281s/.*/set feat_files(2) "\/home\/data\/nbc\/physics-learning\/data\/first-level\/'$1'\/session-'$sessioncount'\/'$task'\/'$task'-1\/'$task'-'$smooth'mm.feat"/' $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-"$smooth"mm.fsf
		sed -i -e '284s/.*/set feat_files(3) "\/home\/data\/nbc\/physics-learning\/data\/first-level\/'$1'\/session-'$sessioncount'\/'$task'\/'$task'-2\/'$task'-'$smooth'mm.feat"/' $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-"$smooth"mm.fsf

	        feat $outputdir/data/second-level/$1/session-$sessioncount/$task/$1-session-$sessioncount-$task-"$smooth"mm.fsf


		sessioncount=$((sessioncount+1))
	done
    shift #moves on to the next subject from the command line
done
