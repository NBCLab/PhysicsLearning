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

		cp $outputdir/physics-learning/ppi-scripts/submitjob_ppi_analysis.sub $outputdir/data/first-level/$1/submitjob_ppi_analysis.sub
		sed -i -e '6s:.*:#BSUB -J '$1'-rp-'$task':' $outputdir/data/first-level/$1/submitjob_ppi_analysis.sub 
		sed -i -e '9s:.*:#BSUB -eo \/home\/data\/nbc\/physics-learning\/data\/first\-level\/errorfiles\/eo\-'$1'-'$task'-ppi-fcimaxrsp-analysis:' $outputdir/data/first-level/$1/submitjob_ppi_analysis.sub
		sed -i -e '12s:.*:#BSUB -oo \/home\/data\/nbc\/physics-learning\/data\/first\-level\/outputfiles\/oo\-'$1'-'$task'-ppi-fcimaxrsp-analysis:' $outputdir/data/first-level/$1/submitjob_ppi_analysis.sub
		sed -i -e '31s:.*:bash '$outputdir'/physics-learning/ppi-scripts/ppi_analysis.sh '$1':' $outputdir/data/first-level/$1/submitjob_ppi_analysis.sub 

		bsub<$outputdir/data/first-level/$1/submitjob_ppi_analysis.sub

	fi
	shift
done
