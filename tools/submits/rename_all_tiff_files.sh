#! /bin/sh

echo reaming all files in $1
for filename in $(find $1 -type f -name "KinomeScreen_.*.tif"); do

#newname="$(echo $filename | sed -e 's/_\([A-Z]\)0\([0-9][0-9]\)_/_\1\2_/g')"

# `./CP068/CP/TIFF/allfiles_O08_03_w647.tif'

#platename="$(basename $(dirname $(dirname $(dirname $filename))))"
#newname="$(echo $filename | sed -e "s/AllFiles_/KinomeScreen_${platename}-1aa_/g")"

newname="$(echo $filename | sed -e "s/KinomeScreen_./KinomeScreen_CP022/g")"


mv -v $filename $newname


done
exit 0
