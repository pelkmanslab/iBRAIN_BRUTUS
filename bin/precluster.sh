#! /bin/sh



if [ ! -d $1/BATCH ]; then
mkdir -p $1/BATCH
fi

if [ ! -r $2 ]; then
echo precluster.sh $2 is not readable
exit 1
fi

bsub -W 7:00 -o $1/BATCH/PreCluster_$(date +"%y%m%d%H%M%S").results ~/PreCluster/PreCluster.command $2 $1/TIFF/ $1/BATCH/

touch $1/PreCluster.submitted

