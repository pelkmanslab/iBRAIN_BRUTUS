#! /bin/sh

TIFFLIST=$1

echo "running pngconversion2.sh on input file $TIFFLIST"

# loop over present png files and remove corresponding tiff files if present...
for TIFF in $( cat $TIFFLIST ); do

if [ -e $TIFF ]; then
   echo "processing $TIFF"
else
   echo "tifffile does not exist $TIFF"
   continue
fi

PNG="$(dirname $TIFF)/$(basename $TIFF .tif).png"

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


# Let's start a second run, just to see if we processed everything OK.
echo " --- end of first run --- "
echo "   "
echo "rerunning pngconversion2.sh on input file $TIFFLIST"

# loop over present png files and remove corresponding tiff files if present...
for TIFF in $( cat $TIFFLIST ); do

if [ -e $TIFF ]; then
   echo "processing $TIFF"
else
   echo "tifffile does not exist $TIFF"
   continue
fi

PNG="$(dirname $TIFF)/$(basename $TIFF .tif).png"

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

echo "finished png conversion with double check"

