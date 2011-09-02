#! /bin/sh


### START MAIN LOOP OVER ALL UNDERLYING TIFF FOLDERS
INCLUDEDPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Berend/Philip/50K_Tfn
for tiff in $(find $INCLUDEDPATH -maxdepth 2 -type d -name "TIFF"); do

# SET MAIN DIRECTORY PARAMETERS
PROJECTDIR=$(dirname $tiff)
BATCHDIR=${PROJECTDIR}/BATCH/
JPGDIR=${PROJECTDIR}/overlays/

mkdir -p $JPGDIR

#if [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then
# -o $PATHNAME/CreateJPGsManualRescale_%J.results
bsub -W 8:00 "matlab -nodisplay -nojvm << M_PROG
create_jpgs_manual_rescale('$tiff','$JPGDIR');
M_PROG"

#else
#echo "skipping $PROJECTDIR: iBRAIN_Stage_1 is not yet completed"
#fi

done
