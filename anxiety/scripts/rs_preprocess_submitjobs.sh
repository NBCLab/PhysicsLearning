# Useage: bash rs_preprocess_submitjobs.sh -sub ###
# runs all the subjects resting state preprocessing in parallel
outputdir=/home/data/nbc/physics-learning

while [[ "$1" != "-sub"  ]]; do
	case "$1" in
		-h)
			echo "This script is designed to run a whole lot of freesurfer at once on the HPC"
			echo "Usage Information"
			echo "bash rs_preprocess_submitjobs.sh -sub 001 002 003 ..."
			exit
			;;
		*)
	esac
	shift
done

while [[ $# -gt 0 ]]; do
	
	if [[ "$1" != "-sub" ]]; then

		cp $outputdir/physics-learning/resting-state-scripts/submitjob_rspreprocess.sub $outputdir/data/pre-processed/$1/submitjob_rspreprocess.sub
		sed -i -e '6s/.*/#BSUB \-J '$1'-rest/' $outputdir/data/pre-processed/$1/submitjob_rspreprocess.sub 
		sed -i -e '9s/.*/#BSUB \-eo \/home\/data\/nbc\/physics-learning\/data\/pre\-processed\/'$1'\/eo\-'$1'-rest/' $outputdir/data/pre-processed/$1/submitjob_rspreprocess.sub 
		sed -i -e '12s/.*/#BSUB \-oo \/home\/data\/nbc\/physics-learning\/data\/pre\-processed\/'$1'\/oo\-'$1'-rest/' $outputdir/data/pre-processed/$1/submitjob_rspreprocess.sub 
		sed -i -e '30s/.*/bash rs_preprocess\.sh -analysisdir endor1 -clean Y -blur_FWHM 5 -sub '$1'/' $outputdir/data/pre-processed/$1/submitjob_rspreprocess.sub 

		bsub<$outputdir/data/pre-processed/$1/submitjob_rspreprocess.sub

	fi
	shift
done
