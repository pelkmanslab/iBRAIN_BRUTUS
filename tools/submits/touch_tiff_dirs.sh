#! /bin/sh


### START MAIN LOOP OVER ALL UNDERLYING TIFF FOLDERS
echo touching all .tif files in $1
find $1 -type f -name "*.tif" -ls -exec touch -c -a {} \;

exit 0

if [ -d $1 ]; then
	echo looking for TIFF directories in $1
else
	echo $1 is not a valid directory, aborting
fi

cd $1

for tiff in $(find $1 -type d -name "TIFF"); do
	echo "  touching * in $tiff"
	cd $tiff
	touch -c -a *
	cd $1
done
