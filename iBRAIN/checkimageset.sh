#! /bin/sh


TIFFCOUNT=$(find $1 -name "*.tif" -maxdepth 1 | wc -l)
OLDINCOMPLETECOUNT=$(find $1 -name "*.incomplete" -ctime +4 | wc -l)
CHECKIMAGESETCOUNT=$(find $1 -name "CheckImageSet*.*complete" | wc -l)

if [ $TIFFCOUNT -eq 1260 ] || [ $TIFFCOUNT -eq 6912 ] || [ $TIFFCOUNT -eq 10368 ]; then

REPORTFILE=CheckImageSet_$(($TIFFCOUNT + 0)).complete
rm -f $1/CheckImageSet_*
touch $1/$REPORTFILE
# echo created $REPORTFILE in $1

elif [ $OLDINCOMPLETECOUNT -gt 0 ]; then

echo "found incomplete file older then one week. flagging folder as complete to start analysis anyway."
touch $1/CheckImageSet_StartAnyway_$(($TIFFCOUNT + 0)).complete

elif [ $TIFFCOUNT -gt 0 ] && [ $TIFFCOUNT -lt 6912 ] && [ $CHECKIMAGESETCOUNT -eq 0 ]; then

REPORTFILE=CheckImageSet_$(($TIFFCOUNT + 0)).incomplete
touch $1/$REPORTFILE
# echo created $REPORTFILE in $1

elif [ $CHECKIMAGESETCOUNT -gt 0 ]; then

echo "waiting for tiff folder to become complete"

else

echo no tiff files found

fi
