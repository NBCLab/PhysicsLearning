#set default parameters
outputdir=/home/data/nbc/physics-learning #project folder
clean=Y #if Y, will delete everything before the script runs
task=retr

while [[ "$1" != "-sub"  ]]; do
	case "$1" in
		-outputdir)
			outputdir=$2
			;;
		-clean)
			clean=$2
			;;
		-h)
			echo "This script is designed to run a whole lot of freesurfer at once on the HPC"
			echo "Usage Information"
			echo "run_freesurf.sh <options> -sub 001 002 003 ..."
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
	
		if [ ! -d $outputdir/data/first-level ]; then
			mkdir $outputdir/data/first-level
		fi

		if [ ! -d $outputdir/data/first-level/$1 ]; then
			mkdir $outputdir/data/first-level/$1
		fi

		cp $outputdir/physics-learning/sub_jobs/submitjob_task_analysis.sub $outputdir/data/first-level/$1/submitjob_task_analysis_$task.sub
		sed -i -e '6s/.*/#BSUB \-J '$1'-'$task'/' $outputdir/data/first-level/$1/submitjob_task_analysis_$task.sub 
		sed -i -e '9s/.*/#BSUB \-eo \/home\/data\/nbc\/physics-learning\/data\/first\-level\/errorfiles\/eo\-'$1'-'$task'-analysis/' $outputdir/data/first-level/$1/submitjob_task_analysis_$task.sub 
		sed -i -e '12s/.*/#BSUB \-oo \/home\/data\/nbc\/physics-learning\/data\/first\-level\/outputfiles\/oo\-'$1'-'$task'-analysis/' $outputdir/data/first-level/$1/submitjob_task_analysis_$task.sub 
		sed -i -e '31s/.*/bash task_analysis_retr_wmotion\.sh '$1'/' $outputdir/data/first-level/$1/submitjob_task_analysis_$task.sub 

		bsub<$outputdir/data/first-level/$1/submitjob_task_analysis_$task.sub

	fi
	shift
done
