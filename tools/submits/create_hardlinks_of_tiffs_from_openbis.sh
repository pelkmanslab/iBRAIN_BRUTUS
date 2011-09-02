#! /bin/sh

DATAPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/YF_DG
OPENBISPATH=/BIOL/imsb/fs2/bio3/bio3/openbis/store/Instance_IMSB/Group_IMSB/Project_DRUGGABLE_GENOME/Experiment_YFV_HELA_CNX/ObservableType_HCS_IMAGE
OFFLINEPATH="/BIOL/imsb/fs2/bio3/bio3/TO TAPE/ZIPPED/YF_DG"
OFFLINEPATH2="/BIOL/imsb/fs2/bio3/bio3/TO TAPE/YF_DG"
#DATAPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/081015_MD_HDMECS_Tfn_pFAK
#TARGETPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/081015_MD_HDMECS_Tfn_pFAK3

echo "$0: starting"
#echo "SOURCEPATH=$DATAPATH"
#echo "TARGETPATH="$TARGETPATH""

#if [ ! -d $DATAPATH ] || [ ! -d $TARGETPATH ]; then
#echo ERROR: DATAPATH OR TARGETPATH ARE NOT VALID
#exit 1
#fi

# cd $DATAPATH

#FOLDERLIST=`find . -maxdepth 1 -type d -ctime +5 -printf "%p%%"`

TIFFDIRLIST=$(find $DATAPATH -mindepth 2 -maxdepth 2 -type d -name "TIFF")

if [ "$TIFFDIRLIST" ]; then

for TIFFDIR in $TIFFDIRLIST; do

PLATENAME=$(basename $(dirname $TIFFDIR))

CPNAME="${PLATENAME:(-9)}"
TIMESTAMP="${PLATENAME:0:13}"
#echo $TIMESTAMP

TIFFCOUNT=$(ls -l $TIFFDIR/*${CPNAME}_P24*.tif 2>/dev/null | wc -l)
echo " "
if [ $TIFFCOUNT -lt 18 ]; then
 echo "PROCESSING $PLATENAME (TIFFCOUNT=$TIFFCOUNT) ($CPNAME)"
else
 echo "SKIPPING   $PLATENAME: COMPLETE TIFF DIR PRESENT  (TIFFCOUNT=$TIFFCOUNT) ($CPNAME)"
 continue
fi

OPENBISPLATE=$(find $OPENBISPATH/Sample_${CPNAME} -mindepth 4 -maxdepth 5 -type d -name "$TIMESTAMP*$CPNAME")
if [ "$OPENBISPLATE" ]; then

 for iPlate in $OPENBISPLATE; do
  OPENBISPLATEMATCH=$iPlate
  echo "  FOUND $(basename $iPlate) (${#OPENBISPLATE[*]} match)"
  echo "  MATCH $PLATENAME"
 done
 #continue
else
 echo "  DID NOT FIND MATCH FOR $PLATENAME IN OPENBIS!"
 #ls -l "$OFFLINEPATH"
 OPENBISPLATEOFFLINE=$(find "$OFFLINEPATH" -type f -name "$TIMESTAMP*$CPNAME*.zip")
 if [ "$OPENBISPLATEOFFLINE" ]; then 
 for iPlate in "$OPENBISPLATEOFFLINE"; do
  echo "  FOUND $(basename "$iPlate") (OFFLINE)"
  echo "  MATCH $PLATENAME"
 
  ### ADD CODE HERE TO RESTORE OFFLINE FILE
  touch "$iPlate"
  echo cp -vu "$iPlate" "$TIFFDIR/$(basename "$iPlate")"
 done
 else
  echo "  DID NOT FIND OFFLINE MATCH (SKIPPING)!"
 fi


 #echo "  DID NOT FIND MATCH FOR $PLATENAME IN OPENBIS!"
 #ls -l "$OFFLINEPATH"
 OPENBISPLATEOFFLINE=$(find "$OFFLINEPATH2" -type d -name "$TIMESTAMP*$CPNAME")
 if [ "$OPENBISPLATEOFFLINE" ]; then
 for iPlate in "$OPENBISPLATEOFFLINE"; do
  echo "  FOUND $(basename "$iPlate") (OFFLINE)"
  echo "  MATCH $PLATENAME"

  ### ADD CODE HERE TO RESTORE OFFLINE FILE
  #touch "$iPlate"
  #cp -vf "$iPlate" "$TIFFDIR/$(basename "$iPlate")"
 done
 else
  echo "  DID NOT FIND OFFLINE MATCH (SKIPPING)!"
 fi




 continue
fi

echo "    PROCESSING TIFF FILES..."
FILELIST=$(find $OPENBISPLATEMATCH/TIFF -type f -name "*.tif")
# SEQUENTIALLY CREATE HARDLINKS FOR ALL TIF IMAGES
if [ "$FILELIST" ]; then
for FILENAME in $FILELIST; do
#if [ ! -e ${TARGETPATH}/$(dirname $filename) ]; then
#echo "creating target directory $(dirname $filename) in $TARGETPATH"
#mkdir -p ${TARGETPATH}/$(dirname $filename)
#fi

#echo $filename
if [ ! -e "${TIFFDIR}/$(basename $FILENAME)" ]; then 
 ln "$FILENAME" "${TIFFDIR}/$(basename $FILENAME)"
# else
 #echo "skipping $FILENAME"
fi
done
fi

done

fi

#IFS=$ORIGIFS
