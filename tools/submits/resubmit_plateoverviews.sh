#! /bin/sh


### START MAIN LOOP OVER ALL UNDERLYING TIFF FOLDERS
INCLUDEDPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/SV40_DG
for jpg in $(find $INCLUDEDPATH -maxdepth 2 -type d -name "TIFF"); do

# SET MAIN DIRECTORY PARAMETERS
PROJECTDIR=$(dirname $jpg)
BATCHDIR=${PROJECTDIR}/BATCH/
POSTANALYSISDIR=${PROJECTDIR}/POSTANALYSIS/

if [ -d $POSTANALYSISDIR ]; then

epscount=$(find $POSTANALYSISDIR -maxdepth 1 -type f -name "*_plate_overview.eps" | wc -l)
echo "$POSTANALYSISDIR - $epscount plate_overview.eps files found"

if [ $epscount -gt 0 ]; then

  echo "  resetting plate overview creation"
  rm $PROJECTDIR/CreatePlateOverview.submitted

fi

else

echo "$POSTANALYSISDIR - does not exist"

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
