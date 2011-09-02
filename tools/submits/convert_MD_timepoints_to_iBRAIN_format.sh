#! /bin/sh

DATAPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Berend/Stoffel

#DATAPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/081015_MD_HDMECS_Tfn_pFAK
#TARGETPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/081015_MD_HDMECS_Tfn_pFAK3

echo "$0: starting"
echo "SOURCEPATH=$DATAPATH"

if [ ! -d $DATAPATH ]; then
echo ERROR: DATAPATH OR TARGETPATH ARE NOT VALID
exit 1
fi

cd $DATAPATH

#FOLDERLIST=`find . -maxdepth 1 -type d -ctime +5 -printf "%p%%"`

FILELIST=$(find . -type d -name "TimePoint_*")

if [ "$FILELIST" ]; then

# SEQUENTIALLY CREATE HARDLINKS FOR ALL TIF IMAGES
for filename in $FILELIST; do
if [ ! -e $filename/TIFF ]; then
echo "creating TIFF dir in filename"
mkdir -p $filename/TIFF
fi


TIFFIMAGES=$(find $filename -maxdepth 1 -type f -name "*.tif")
for tiffimage in $TIFFIMAGES; do

mv -v $tiffimage $filename/TIFF/$(basename $tiffimage)

done

done

fi

IFS=$ORIGIFS
