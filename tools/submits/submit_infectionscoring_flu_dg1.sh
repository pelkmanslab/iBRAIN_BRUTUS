#! /bin/sh


### START MAIN LOOP OVER ALL UNDERLYING TIFF FOLDERS
INCLUDEDPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/FLU_DG1
for tiff in $(find $INCLUDEDPATH -maxdepth 2 -type d -name "TIFF"); do

# SET MAIN DIRECTORY PARAMETERS
PROJECTDIR=$(dirname $tiff)
BATCHDIR=${PROJECTDIR}/BATCH/

if [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then
~/scripts/run_infectionscoring_flu_dg1.sh $BATCHDIR
else
echo "skipping $PROJECTDIR: iBRAIN_Stage_1 is not yet completed"
fi

done
