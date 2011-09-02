#! /bin/sh

# ONLY LOOK AT TIFF FOLDERS WHICH HAVEN'T BEEN TOUCHED FOR 30 MINUTES
TIFFDIR=$(find $(dirname $1) -type d -mmin +30 -name 'TIFF')

echo "    checkimageset.sh: looking at $TIFFDIR in $(dirname $1)"

if [ $TIFFDIR ]; then

TIFFCOUNT=$(find $TIFFDIR -maxdepth 3 -name "*.tif" | wc -l)
OLDINCOMPLETECOUNT=$(find $TIFFDIR -cmin +120 -name "*.incomplete" | wc -l)
CHECKIMAGESETCOUNT=$(find $TIFFDIR -name "CheckImageSet*.*complete" | wc -l)

echo "    checkimageset.sh: TIFFCOUNT=$TIFFCOUNT" 

#                    50K-2CH                   CB-2CH                       384-2CH                    ...                   20x-25i-3ch          ANYTHING!!!!!
if [ $TIFFCOUNT -eq 1260 ] || [ $TIFFCOUNT -eq 1728 ] ||   [ $TIFFCOUNT -eq 6912 ] || [ $TIFFCOUNT -eq 10368 ] || [ $TIFFCOUNT -eq 7200 ]  || [ $TIFFCOUNT -gt 1 ]; then

REPORTFILE=CheckImageSet_$(($TIFFCOUNT + 0)).complete
rm -f $TIFFDIR/CheckImageSet_*
touch $TIFFDIR/$REPORTFILE
# echo created $REPORTFILE in $1

elif [ $OLDINCOMPLETECOUNT -gt 0 ]; then

echo "    found incomplete file older then 4 days. flagging folder as complete to start analysis anyway."
touch $TIFFDIR/CheckImageSet_StartAnyway_$(($TIFFCOUNT + 0)).complete

elif [ $TIFFCOUNT -gt 0 ] && [ $TIFFCOUNT -lt 6912 ] && [ $CHECKIMAGESETCOUNT -eq 0 ]; then

REPORTFILE=CheckImageSet_$(($TIFFCOUNT + 0)).incomplete
touch $TIFFDIR/$REPORTFILE
echo "    folder incomplete ${REPORTFILE}"

elif [ $CHECKIMAGESETCOUNT -gt 0 ]; then

echo "    waiting for TIFF folder to become complete"

else

echo "    no tiff files found"

fi

else

echo "    waiting for TIFF folder to pass waiting fase"

fi


