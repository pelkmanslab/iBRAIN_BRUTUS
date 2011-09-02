#! /bin/sh

#DATAPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Lilli/adhesome_screen_data
#TARGETPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Lilli/adhesome_screen_data_new_analysis_2

#DATAPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/081015_MD_HDMECS_Tfn_pFAK
#TARGETPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/081015_MD_HDMECS_Tfn_pFAK6

DATAPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/50K_final_reanalysis/HIV_MZ_2
TARGETPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/50K_copy/HIV_MZ



echo "$0: starting"
echo "SOURCEPATH=$DATAPATH"
echo "TARGETPATH="$TARGETPATH""

mkdir $TARGETPATH

if [ ! -d $DATAPATH ] || [ ! -d $TARGETPATH ]; then
echo ERROR: DATAPATH OR TARGETPATH ARE NOT VALID
exit 1
fi

cd $DATAPATH

#FOLDERLIST=`find . -maxdepth 1 -type d -ctime +5 -printf "%p%%"`

FILELIST=$(find . -type f -name "*")

if [ "$FILELIST" ]; then

# SEQUENTIALLY CREATE HARDLINKS FOR ALL TIF IMAGES
for filename in $FILELIST; do
if [ ! -e ${TARGETPATH}/$(dirname $filename) ]; then
echo "creating target directory $(dirname $filename) in $TARGETPATH"
mkdir -p ${TARGETPATH}/$(dirname $filename)
fi

# echo $filename
if [ -e "${TARGETPATH}/$filename" ]; then 
echo "skipping - exists ${TARGETPATH}/$filename"
elif [ ${filename: -4} == ".mat" ] || [ ${filename: -4} == ".png" ]; then 
touch  "${TARGETPATH}/$filename"
else
ln -v "$filename" "${TARGETPATH}/$filename"
#echo "skipping ${TARGETPATH}/$filename"
fi
done

fi

IFS=$ORIGIFS
