# Useage: bash 3_struct_preprocess_fsl_submitjobs.sh -sub ###
#set default parameters
outputdir=/home/data/nbc/physics-learning #project folder
clean=N #if Y, will delete everything before the script runs
task=anatomical

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

		if [ ! -d $outputdir/data/pre-processed/$1 ]; then
			mkdir -p $outputdir/data/pre-processed/$1
		fi

		cp $outputdir/physics-learning/sub_jobs/submitjob_struct_preprocess_fsl.sub $outputdir/data/pre-processed/$1/submitjob_struct_preprocess_fsl_$task.sub
		sed -i -e '6s/.*/#BSUB \-J '$1'-'$task'/' $outputdir/data/pre-processed/$1/submitjob_struct_preprocess_fsl_$task.sub 
		sed -i -e '9s/.*/#BSUB \-eo \/home\/data\/nbc\/physics-learning\/data\/pre\-processed\/'$1'\/eo\-'$1'-'$task'/' $outputdir/data/pre-processed/$1/submitjob_struct_preprocess_fsl_$task.sub 
		sed -i -e '12s/.*/#BSUB \-oo \/home\/data\/nbc\/physics-learning\/data\/pre\-processed\/'$1'\/oo\-'$1'-'$task'/' $outputdir/data/pre-processed/$1/submitjob_struct_preprocess_fsl_$task.sub 
		sed -i -e '32s/.*/bash struct_preprocess_fsl\.sh -sub '$1'/' $outputdir/data/pre-processed/$1/submitjob_struct_preprocess_fsl_$task.sub 

		bsub<$outputdir/data/pre-processed/$1/submitjob_struct_preprocess_fsl_$task.sub

	fi
	shift
done
