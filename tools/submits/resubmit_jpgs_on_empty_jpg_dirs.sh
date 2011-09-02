#! /bin/sh


### START MAIN LOOP OVER ALL UNDERLYING TIFF FOLDERS
INCLUDEDPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/SV40_DG
for jpg in $(find $INCLUDEDPATH -maxdepth 2 -type d -name "JPG"); do

# SET MAIN DIRECTORY PARAMETERS
PROJECTDIR=$(dirname $jpg)
#BATCHDIR=${PROJECTDIR}/BATCH/
#JPGDIR=${PROJECTDIR}/overlays/

#mkdir -p $JPGDIR

jpgcount=$(find $jpg -type f -name "*PlateOverview.jpg" | wc -l)

if [ $jpgcount = 0 ]; then

echo "$jpgcount empty no jpgs in $jpg"

bsub -W 8:00 "matlab -nodisplay -nojvm << M_PROG
merge_jpgs_per_plate('$jpg');
M_PROG"

#rm $jpg/*.results
#rm $PROJECTDIR/CreateJPGs.submitted

fi

#if [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then
# -o $PATHNAME/CreateJPGsManualRescale_%J.results

#bsub -W 8:00 "matlab -nodisplay -nojvm << M_PROG
#create_jpgs_manual_rescale('$tiff','$JPGDIR');
#M_PROG"

#else
#echo "skipping $PROJECTDIR: iBRAIN_Stage_1 is not yet completed"
#fi

done
