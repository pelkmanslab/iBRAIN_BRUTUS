#! /bin/sh

if [ -d $1 ]; then

echo submitting DataFusion $pathname
REPORTFILE=DataFusion_$(date +"%y%m%d%H%M%S").results
bsub -W 7:00 -o $1/$REPORTFILE ./DataFusion/RunDataFusion.command $1
touch $(dirname $1)/DataFusion.submitted

fi
