#set default parameters
outputdir=/home/data/nbc/physics-learning #project folder
task=fci

while [[ "$1" != "-sub"  ]]; do
	case "$1" in
		-outputdir)
			outputdir=$2
			;;
		-task)
			task=$2
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

		cp $outputdir/physics-learning/ppi-scripts/submitjob_ppi_preprocess.sub $outputdir/data/pre-processed/$1/submitjob_ppi_"$task".sub
		sed -i -e '6s:.*:#BSUB -J '$1'-'$task':' $outputdir/data/pre-processed/$1/submitjob_ppi_"$task".sub 
		sed -i -e '9s:.*:#BSUB -eo \/home\/data\/nbc\/physics-learning\/data\/pre\-processed\/errorfiles\/eo\-'$1'-'$task'-ppi-analysis:' $outputdir/data/pre-processed/$1/submitjob_ppi_"$task".sub
		sed -i -e '12s:.*:#BSUB -oo \/home\/data\/nbc\/physics-learning\/data\/pre\-processed\/outputfiles\/oo\-'$1'-'$task'-ppi-analysis:' $outputdir/data/pre-processed/$1/submitjob_ppi_"$task".sub
		sed -i -e '31s:.*:bash '$outputdir'/physics-learning/ppi-scripts/ppi_preprocess.sh '$1':' $outputdir/data/pre-processed/$1/submitjob_ppi_"$task".sub 

		bsub<$outputdir/data/pre-processed/$1/submitjob_ppi_"$task".sub

	fi
	shift
done
