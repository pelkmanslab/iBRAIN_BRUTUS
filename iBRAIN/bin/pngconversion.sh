#! /bin/sh

TIFFDIR=$1

cd $TIFFDIR

echo "running pngconversion2.sh on $TIFFDIR"

# loop over present png files and remove corresponding tiff files if present...
for TIFF in $( find $TIFFDIR -maxdepth 1 -type f -iname "*.tif" ); do

PNG="$TIFFDIR/$(basename $TIFF .tif).png"

echo "processing $TIFF"

# CONVERT FILE IF PNG DOES NOT EXIST
if [ ! -e $PNG ]; then
   echo " -- converting to $PNG"
   convert -quiet $TIFF -depth 16 -colorspace gray -format png $PNG
fi

# CHECK IF PNG FILE EXISTS AND IS VALID, IF SO, REMOVE TIFF FILE
if [ -e $PNG ] && [ $(~/bin/pngcheck $PNG | grep "OK:" -c) -gt 0 ]; then
   echo " -- png file is ok, removing $TIFF"
   rm -f $TIFF
elif [ ! -e $PNG ]; then
   echo " -- !!! did not create png file... not sure why"
elif [ $(~/bin/pngcheck $PNG | grep "OK:" -c) -lt 1 ]; then
   echo " -- !!! png file is corrupt!"
   ~/bin/pngcheck $PNG
   echo " -- removing $PNG"
   rm -f $PNG
fi

# Create empty line between files...
echo "  "

done


