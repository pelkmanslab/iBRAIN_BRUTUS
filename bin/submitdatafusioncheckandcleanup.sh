#! /bin/sh

if [ ! -d $1 ]; then
echo $1 is not a directory
exit 1
fi

bsub -W 7:00 -o $1/DataFusionCheckAndCleanup_$(date +"%y%m%d%H%M%S").results ~/MATLAB/checkmeasurementsfile/datafusioncheckandcleanup.sh $1

touch $(dirname $1)/DataFusionCheckAndCleanup.submitted

