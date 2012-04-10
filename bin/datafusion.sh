#! /bin/sh

if [ -d $1 ]; then

for iFile in $(find $1 -maxdepth 1 -type f -name "Batch_2_to_*_Measurements_*.mat"); do

FILENAME=$(echo $iFile | sed 's/.*Batch_2_to_[0-9]*_\(.*\)\.mat/\1/')

echo $FILENAME

if [ ! -e $1/${FILENAME}.mat ]; then
echo submitting DataFusion on $1/$FILENAME.mat
REPORTFILE=DataFusion_${FILENAME}_$(date +"%y%m%d%H%M%S").results

bsub -W 01:00 -o $1/$REPORTFILE "matlab -singleCompThread -nodisplay -nojvm << M_PROG;
RunDataFusion('$1','$FILENAME');
M_PROG"

else

echo $FILENAME.mat is already processed

fi

done

#touch $(dirname $1)/DataFusion.submitted

fi
