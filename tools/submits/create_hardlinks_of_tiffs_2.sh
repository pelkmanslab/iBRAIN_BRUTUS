#! /bin/sh

#DATAPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Lilli/adhesome_screen_data
#TARGETPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Lilli/adhesome_screen_data_new_analysis_2

#DATAPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/081015_MD_HDMECS_Tfn_pFAK
#TARGETPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/081015_MD_HDMECS_Tfn_pFAK6

DATAPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Prisca/081202_H2B_GPI_movies/Movie/F07_TIFF
TARGETPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Berend/Prisca/081202_H2B_GPI_movies_F07/TIFF

echo "$0: starting"
echo "SOURCEPATH=$DATAPATH"
echo "TARGETPATH="$TARGETPATH""

mkdir -p $TARGETPATH

if [ ! -d $DATAPATH ] || [ ! -d $TARGETPATH ]; then
echo ERROR: DATAPATH OR TARGETPATH ARE NOT VALID
exit 1
fi

cd $DATAPATH

#FOLDERLIST=`find . -maxdepth 1 -type d -ctime +5 -printf "%p%%"`

FILELIST=$(find . -type f -name "*.tif")

if [ "$FILELIST" ]; then

# SEQUENTIALLY CREATE HARDLINKS FOR ALL TIF IMAGES
for filename in $FILELIST; do
if [ ! -e ${TARGETPATH}/$(dirname $filename) ]; then
echo "creating target directory $(dirname $filename) in $TARGETPATH"
mkdir -p ${TARGETPATH}/$(dirname $filename)
fi

# echo $filename
if [ ! -e "${TARGETPATH}/$filename" ]; then 
ln -v "$filename" "${TARGETPATH}/$filename"
else
echo "skipping ${TARGETPATH}/$filename"
fi
done

fi

IFS=$ORIGIFS
