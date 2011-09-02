#! /bin/sh

IFS="%%"

for dirname in $(find . -maxdepth 1 -type d -printf "%f%%"); do

processing $dirname
mkdir -p ./$dirname/TIFF

for wellname in $(find ./$dirname -maxdepth 1 -type d -name "Well*" -printf "%f%%"); do

mv ./$dirname/$wellname ./$dirname/TIFF/

done

done

IFS=$ORIGIFS

