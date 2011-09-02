#! /bin/sh

#DATAPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Lilli/adhesome_screen_data_2
#TARGETPATH=/BIOL/imsb/fs2/bio3/bio3/Data/Users/Lilli/adhesome_screen_data_2_new_analysis

#DATAPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Frank/090617_ARS_PABP_546_CHECKER
#TARGETPATH=/BIOL/imsb/fs3/bio3/bio3/Data/Users/Frank/090617_ARS_PABP_546_CHECKER_2

#DATAPATH=~/3NAS/Data/Users/Eva/BS_iBRAIN/090930_ChtxB_density_MCF10A5
#TARGETPATH=~/3NAS/Data/Users/Eva/BS_iBRAIN/090930_ChtxB_density_MCF10A6

#DATAPATH=~/2NAS/Data/Users/Berend/50K_FollowUps/101001_HeLa_50kfollowup_3500KyTfn_AW
#TARGETPATH=~/2NAS/Data/Users/Berend/50K_FollowUps/101001_HeLa_50kfollowup_3500KyTfn_AW_Hardlinks_PerImageBGCorr

DATAPATH=~/3NAS/Data/Users/50K_final_reanalysis
TARGETPATH=~/3NAS/Data/Users/50K_final_reanalysis_segm


#DATAPATH=~/3NAS/Data/Users/Frank/100210-10-12-VSV-MYC/100210-10-12-VSV-MYC
#TARGETPATH=~/3NAS/Data/Users/Frank/100210-10-12-VSV-MYC/100210-10-12-VSV-MYC_Hardlinks_01

# DATAPATH=~/2NAS/Data/Users/Eva/iBRAIN/090130_Eva_GlyplusGGPP_FAKKO_SV40/090130_Eva_GlyplusGGPP_FAKKO_SV40/
# TARGETPATH=~/2NAS/Data/Users/Eva/iBRAIN/090130_Eva_GlyplusGGPP_FAKKO_SV40/090130_Eva_GlyplusGGPP_FAKKO_SV40_HardLinks/

#DATAPATH=~/2NAS/Data/Users/Berend/Prisca/081202_H2B_GPI_movies_F07/081202_H2B_GPI_movies_F07/
#TARGETPATH=~/2NAS/Data/Users/Berend/Prisca/081202_H2B_GPI_movies_F07/081202_H2B_GPI_movies_F07_HardLink/

#DATAPATH=~/2NAS/Data/Users/Raphael/070420_Tfn_50K_MZ
#TARGETPATH=~/2NAS/Data/Users/Berend/Raphael/070420_Tfn_50K_MZ_HardLinks/

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

IFS="%%"

cd $DATAPATH

FOLDERLIST=`find . -type d -name "TIFF" -printf "%p%%"`

for tiffdir in $FOLDERLIST; do

echo "looking for files in $tiffdir"

FILELIST=`find $tiffdir -type f -name "*.png" -printf "%p%%"`

if [ "$FILELIST" ]; then

# SEQUENTIALLY CREATE HARDLINKS FOR ALL TIF IMAGES
for filename in $FILELIST; do
if [ ! -e ${TARGETPATH}/$(dirname $filename) ]; then
echo "creating target directory $(dirname $filename) in $TARGETPATH"
mkdir -p ${TARGETPATH}/$(dirname $filename)
fi

# echo $filename
#if [ ! -e "${TARGETPATH}/$filename" ]; then 
ln -v "$filename" "${TARGETPATH}/$filename"
#ln -v "$filename" "${TARGETPATH2}/$filename"
#ln -v "$filename" "${TARGETPATH3}/$filename"
#else
#echo "skipping ${TARGETPATH}/$filename"
#fi
done

fi

done

IFS=$ORIGIFS
