#! /bin/sh



if [ ! -d $1/BATCH ]; then
mkdir -p $1/BATCH
fi

if [ ! -r $2 ]; then
echo precluster.sh $2 is not readable
exit 1
fi

# echo "PreCluster $2 $1/TIFF/ $1/BATCH/" > ~/temp.m
### THIS SEEMS TO WORK!
#bsub -W 8:01 -o $1/BATCH/PreCluster_$(date +"%y%m%d%H%M%S").results "matlab -singleCompThread -nodisplay -nojvm < ~/temp.m"

bsub -W 8:00 -o $1/BATCH/PreCluster_$(date +"%y%m%d%H%M%S").results "matlab -singleCompThread -nodisplay -nojvm nojit << M_PROG; 
check_missing_images_in_folder('${1}/TIFF/');
PreCluster_with_pipeline('${2}','${1}/TIFF/','${1}/BATCH/'); 
M_PROG"


touch $1/PreCluster.submitted


