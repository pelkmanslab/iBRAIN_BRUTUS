#! /bin/sh


### START MAIN LOOP OVER ALL UNDERLYING TIFF FOLDERS
# INCLUDEDPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Jean-Philippe/p53SLSsecondRun
INCLUDEDPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/20080710

for dir in $(find $INCLUDEDPATH -mindepth 1 -maxdepth 1 -type d); do

WELLDIRCOUNT=$(find $dir -type d -name "Well *" | wc -l)

if [ $WELLDIRCOUNT -gt 0 ]; then

#find $dir -type d -name "Well *"

echo submitting on $dir
# SET MAIN DIRECTORY PARAMETERS
#PROJECTDIR=$(dirname $tiff)
#BATCHDIR=${PROJECTDIR}/BATCH/
#JPGDIR=${PROJECTDIR}/overlays/

#mkdir -p $JPGDIR

#if [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then
# -o $PATHNAME/CreateJPGsManualRescale_%J.results

echo "333SUBMITTING333"

bsub -W 8:00 -o $dir/TIFF/CropBDImages_%J.results "matlab -nodisplay -nojvm << M_PROG
CropBDImages('$dir');
M_PROG"

else
echo "skipping $dir: no Well dirs present"
fi

#else
#echo "skipping $PROJECTDIR: iBRAIN_Stage_1 is not yet completed"
#fi

done
