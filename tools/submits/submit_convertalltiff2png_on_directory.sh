#! /bin/sh


### START MAIN LOOP OVER ALL UNDERLYING TIFF FOLDERS
# INCLUDEDPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Jean-Philippe/p53SLSsecondRun
#INCLUDEDPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Raphael
#INCLUDEDPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Karin
#INCLUDEDPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/DG_screen_Salmonella
#INCLUDEDPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/MHV_DG
INCLUDEDPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/VSV_DG

#for tiffdir in $(find $INCLUDEDPATH -type d -mmin +120 -name "TIFF"); do
for tiffdir in $(find $INCLUDEDPATH -mindepth 2 -maxdepth 2 -type d -mmin +120 -name "TIFF"); do

if [ -w $tiffdir ]; then

echo found writable TIFF directory: $tiffdir

JOBCOUNT=$(bjobs -w 2>/dev/null | grep convert_all_tiff2png | wc -l)
if [ $JOBCOUNT -gt 9 ]; then
echo "$JOBCOUNT conversion jobs present, no sense in continuing search now. exiting..."
exit 0;
fi

TIFFCOUNT=$(find $tiffdir -maxdepth 1 -type f -name "*.tif" ! -name "._*.tif" | wc -l)

# check if there is already a job present for this directory
if [ $TIFFCOUNT -gt 0 ]; then
JOBCOUNT2=$(bjobs -w 2>/dev/null | grep $tiffdir | wc -l)
if [ $JOBCOUNT2 -gt 0 ]; then
echo " -- already $JOBCOUNT2 job(s) present for $tiffdir "
continue
fi
fi

if [ $TIFFCOUNT -gt 0 ] && [ $TIFFCOUNT -lt 500 ]; then

echo "  -- found $TIFFCOUNT tif images. submitting convert_all_tiff2png() to small queue"

bsub -W 1:00 "matlab -nodisplay -nojvm << M_PROG
convert_all_tiff2png('$tiffdir');
M_PROG"


elif [ $TIFFCOUNT -gt 499 ] && [ $TIFFCOUNT -lt 10000 ]; then
 
echo "  -- found $TIFFCOUNT tif images. submitting convert_all_tiff2png() to medium queue"

bsub -W 12:00 "matlab -nodisplay -nojvm << M_PROG
convert_all_tiff2png('$tiffdir');
M_PROG"

elif [ $TIFFCOUNT -gt 9999 ]; then

echo "  -- found $TIFFCOUNT tif images. submitting convert_all_tiff2png() to large queue"

bsub -W 24:00 "matlab -nodisplay -nojvm << M_PROG
convert_all_tiff2png('$tiffdir');
M_PROG"

else

echo "  -- no tif images found."

fi

else
echo found NON-writable TIFF directory: $tiffdir
fi

echo " "
done
