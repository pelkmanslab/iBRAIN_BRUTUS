#! /bin/sh

#DATAPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Lilli/adhesome_screen_data_2
#TARGETPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Lilli/adhesome_screen_data_2_new_analysis

DATAPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/VSV_DG
TARGETPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/VSV_DG

#DATAPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/090203_Mz_Tf_EEA1/090203_Mz_Tf_EEA1_CP395-1ad
#TARGETPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/Test_Pipelines/Extract_Cell
#TARGETPATH2=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/Test_Pipelines/Extract_Vesicles
#TARGETPATH3=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/Test_Pipelines/No_Vesicles


#DATAPATH="/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/Pool_Tf/Pool-1-10x/Pool-1-10x"
#TARGETPATH="/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca/Pool_Tf/Pool-10x"


#DATAPATH="/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/20080710"
#TARGETPATH="/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/20080710_2"


#DATAPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/081015_MD_HDMECS_Tfn_pFAK
#TARGETPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/081015_MD_HDMECS_Tfn_pFAK3

echo "$0: starting"
echo "SOURCEPATH=$DATAPATH"
echo "TARGETPATH="$TARGETPATH""

if [ ! -d $DATAPATH ] || [ ! -d $TARGETPATH ]; then
echo ERROR: DATAPATH OR TARGETPATH ARE NOT VALID
exit 1
fi

cd $DATAPATH

FOLDERLIST=$(find . -type d -name "TIFF")

for tiffdir in $FOLDERLIST; do

echo "looking for files in $tiffdir"

FILELIST=$(find $tiffdir -type f -name "*.png")

if [ "$FILELIST" ]; then

# SEQUENTIALLY CREATE HARDLINKS FOR ALL TIF IMAGES
for filename in $FILELIST; do

if [ ! -e ${TARGETPATH}/$(dirname $filename) ]; then
echo "creating target directory $(dirname $filename) in $TARGETPATH"
mkdir -p ${TARGETPATH}/$(dirname $filename)
fi

# echo $filename
#if [ ! -e "${TARGETPATH}/$filename" ]; then 
cp -vu "$filename" "${TARGETPATH}/$filename"
#ln -v "$filename" "${TARGETPATH2}/$filename"
#ln -v "$filename" "${TARGETPATH3}/$filename"
#else
#echo "skipping ${TARGETPATH}/$filename"
#fi
done

fi

done

IFS=$ORIGIFS
