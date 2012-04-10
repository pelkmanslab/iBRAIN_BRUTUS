#! /bin/sh

if [ ! -d $1 ]; then
echo $1 is not a directory
exit 1
fi

#~/MATLAB/checkmeasurementsfile/datafusioncheckandcleanup.sh $1

#bsub -W 2:00 -o $1/DataFusionCheckAndCleanup_$(date +"%y%m%d%H%M%S").results "matlab -singleCompThread -nodisplay -nojvm << M_PROG;
#checkmeasurementsfile('$1');
#M_PROG"

#bsub -W 8:00 -o $1/DataFusionCheckAndCleanup_$(date +"%y%m%d%H%M%S").results << CPC
#~/iBRAIN/datafusioncheckandcleanup.sh $1;
#CPC

bsub -W 8:00 -o $1/DataFusionCheckAndCleanup_$(date +"%y%m%d%H%M%S").results "matlab -singleCompThread -nodisplay -nojvm << M_PROG;
datafusioncheckandcleanup('$1');
M_PROG"

touch $(dirname $1)/DataFusionCheckAndCleanup.submitted

