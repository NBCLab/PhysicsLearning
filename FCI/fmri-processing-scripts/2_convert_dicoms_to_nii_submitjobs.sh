# Creates HEAD, BRIK, and nii files from dicom images
# Author: Michael Riedel
# USEAGE: bash 2_convert_dicoms_to_nii_submitjobs.sh -sub PID PID PID PID
# Note: update func and out_func in default parameters before running
#	run "module load afni" and "module load mricron" in the shell before running

#set default parameters
outputdir=/home/data/nbc/physics-learning #project folder
clean=N #if Y, will delete everything before the script runs

#no caps
#task=reas
task=retr
#task=fci
#task=resting-state

#caps matter:
#func=REAS
func=RETR
#func=FCI
#func=Resting_State

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

if [ ! -d $outputdir/data ]; then
	mkdir $outputdir/data
fi

if [ ! -d $outputdir/data/pre-processed ]; then
	mkdir $outputdir/data/pre-processed
fi

while [[ $# -gt 0 ]]; do
	
	if [[ "$1" != "-sub" ]]; then

		if [ ! -d $outputdir/data/pre-processed/$1 ]; then
			mkdir $outputdir/data/pre-processed/$1
		fi

		cp $outputdir/physics-learning/sub_jobs/submitjob_convert_dicoms.sub $outputdir/data/pre-processed/$1/submitjob_convert_dicoms_$task.sub
		sed -i -e '6s/.*/#BSUB \-J '$1'-'$task'/' $outputdir/data/pre-processed/$1/submitjob_convert_dicoms_$task.sub 
		sed -i -e '9s/.*/#BSUB \-eo \/home\/data\/nbc\/physics-learning\/data\/pre\-processed\/'$1'\/eo\-'$1'-'$task'/' $outputdir/data/pre-processed/$1/submitjob_convert_dicoms_$task.sub 
		sed -i -e '12s/.*/#BSUB \-oo \/home\/data\/nbc\/physics-learning\/data\/pre\-processed\/'$1'\/oo\-'$1'-'$task'/' $outputdir/data/pre-processed/$1/submitjob_convert_dicoms_$task.sub 
		sed -i -e '31s/.*/bash convert_dicoms\.sh -func '$func' -outputdir_func '$task' -sub '$1'/' $outputdir/data/pre-processed/$1/submitjob_convert_dicoms_$task.sub 

		bsub<$outputdir/data/pre-processed/$1/submitjob_convert_dicoms_$task.sub

	fi
	shift
done
