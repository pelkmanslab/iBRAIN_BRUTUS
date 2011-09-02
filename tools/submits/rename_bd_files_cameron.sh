#! /bin/sh

IFS="%%"

PATHNAME="/BIOL/imsb/fs2/bio3/bio3/Data/Users/Cameron/"

for welldir in $(find $PATHNAME -mindepth 3 -maxdepth 3 -type d -name "Well*" -printf "%h/%f%%"); do

# -printf "%f%%"

echo processing $dirname

#mkdir -p ./$dirname/TIFF

for imagename in $(find $welldir -maxdepth 1 -type f -name "*.tif" -printf "%f%%"); do

echo $welldir/$imagename


done

done

IFS=$ORIGIFS

