#! /bin/sh


### START MAIN LOOP OVER ALL UNDERLYING TIFF FOLDERS
INCLUDEDPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Cameron/INCOMING/

for tiffdir in $(find $INCLUDEDPATH -mindepth 2 -maxdepth 4 -type d -name "TIFF"); do

echo $tiffdir

bsub -W 8:00 "matlab -singleCompThread -nodisplay -nojvm << M_PROG
CropBDImages_CameronChol('$tiffdir');
M_PROG"

#rm $jpg/*.results
#rm $PROJECTDIR/CreateJPGs.submitted

#if [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then
# -o $PATHNAME/CreateJPGsManualRescale_%J.results

#bsub -W 8:00 "matlab -nodisplay -nojvm << M_PROG
#create_jpgs_manual_rescale('$tiff','$JPGDIR');
#M_PROG"

#else
#echo "skipping $PROJECTDIR: iBRAIN_Stage_1 is not yet completed"
#fi

done
