#! /bin/sh

DATAPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/FLU_DG1
TARGETPATH=/BIOL/imsb/fs2/bio3/bio3/ZIP_AND_TO_TAPE/FLU_DG1

if [ ! -d $DATAPATH ] || [ ! -d $TARGETPATH ]; then
echo ERROR: DATAPATH OR TARGETPATH ARE NOT VALID
exit 1
fi

cd $DATAPATH

FOLDERLIST=`find . -maxdepth 1 -type d -ctime +5 -printf "%p%%"`

IFS="%%"

for foldername in $FOLDERLIST; do

if [ "$foldername" ]; then

CURRENTORIG="$DATAPATH/$(basename $foldername)"
echo checking $foldername

OLDBATCHCOUNT=$(find $CURRENTORIG -maxdepth 1 -type d -mtime +3 -name "BATCH" | wc -l)
JPGPLATECOUNT=$(find $CURRENTORIG/JPG -maxdepth 1 -type f -name "*_PlateOverview.jpg" | wc -l)
SVMRESULTCOUNT=$(find $CURRENTORIG/BATCH -maxdepth 1 -type f -name "SVMClassification_*.results" | wc -l)
TIFFCOUNT=$(find $CURRENTORIG/TIFF -maxdepth 1 -type f -name "*.tif" | wc -l)


echo "  $OLDBATCHCOUNT old BATCH directories found"
echo "  $JPGPLATECOUNT PlateOverview jpgs found"
echo "  $SVMRESULTCOUNT SVM Results files found"
echo "  $TIFFCOUNT tif files found"

if [ $OLDBATCHCOUNT -eq 0 ] || [ $JPGPLATECOUNT -eq 0 ] || [ $SVMRESULTCOUNT -eq 0 ] || [ $TIFFCOUNT -eq 0 ]; then
	echo "NOT MOVING IMAGES"
	continue
fi


CURRENTTARGET="$TARGETPATH/$(basename $foldername)/TIFF"
CURRENTORIG="$DATAPATH/$(basename $foldername)/TIFF"

echo $CURRENTORIG to $CURRENTTARGET

### LOOK FOR ALL TIF FILES AND MOVE THEM TO THEIR NEW LOCATION

IFS=$ORIGIFS
FILELIST=$(find "$CURRENTORIG" -maxdepth 1 -type f -name "*.tif" -printf "%f%%")

if [ "$FILELIST" ]; then

# IF TIF FILES PRESENT, MAKE TARGET FOLDER
mkdir -p "$CURRENTTARGET"

# SET LABEL THAT THESE IMAGES HAVE BEEN MOVED
touch "$CURRENTORIG/tif_files_moved_by_berend.log"

# SEQUENTIALLY MOVE ALL TIF IMAGES
IFS="%%"
for filename in $FILELIST; do
# echo $filename
mv -f "$CURRENTORIG/$filename" "$CURRENTTARGET/$filename"
done

fi

fi

done

IFS=$ORIGIFS
