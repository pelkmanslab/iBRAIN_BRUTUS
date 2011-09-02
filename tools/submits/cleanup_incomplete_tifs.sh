#!/bin/sh
for TIFF in $(find /BIOL/imsb/fs3/bio3/bio3/Data/Users/HPV16_DG -mindepth 2 -type d -name "TIFF"); do
echo "CHECKING $TIFF"
find $TIFF -size -100k -type f -name "*.tif" -ls -exec rm {} \;

done
