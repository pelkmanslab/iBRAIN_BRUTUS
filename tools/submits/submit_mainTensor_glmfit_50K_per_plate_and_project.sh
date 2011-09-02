#! /bin/sh

#TARGETPATH="/BIOL/imsb/fs2/bio3/bio3/Data/Users/Berend/BATCH_RESULTS/Data/Users/50K_final/"
TARGETPATH1="/BIOL/imsb/fs3/bio3/bio3/Data/Users/50K_final_reanalysis/"
TARGETPATH="${TARGETPATH1}/${1}"

if [ ! -d $TARGETPATH ] || [ ! "$1" ]; then
 echo "$1 is not a valid directory in 50K_final_reanalysis"
 exit
fi


#cd $TARGETPATH

FOLDERLIST=`find $TARGETPATH -maxdepth 1 -mindepth 1 -type d -printf "%p%%"`

IFS="%%"

for foldername in $FOLDERLIST; do

if [ "$foldername" ]; then


CURRENTTARGET="$foldername"

SUBFOLDERCHECK=`find $CURRENTTARGET -maxdepth 1 -type d | wc -l`

if [ $SUBFOLDERCHECK -gt 2 ]; then

echo DOING "$CURRENTTARGET"

echo "removing old ProbMod model files"

#if [ ! "$(find $CURRENTTARGET -maxdepth 3 -type f -name "ProbMod*.mat")" ]; then
find $CURRENTTARGET -maxdepth 3 -type f -name "ProbMod*.mat" -ls -exec rm {} \;
find $CURRENTTARGET -maxdepth 3 -type f -name "mainTensorModel_*.results" -ls -exec rm {} \;
find $CURRENTTARGET -maxdepth 1 -type f -name "ProbMod*.pdf" -ls -exec rm {} \;


echo "submitting analysis"

bsub -W 08:00 -o "${CURRENTTARGET}/mainTensorModel_$(date +"%y%m%d%H%M%S").results" "matlab -nodisplay -nojvm << M_PROG
mainTensorModel_glmfit('$CURRENTTARGET','${TARGETPATH1}ProbModel_Settings.txt');
M_PROG"
#else

#echo "output already found, skipping"

#fi
# touch $JPGTARGET/CreateJPGs.submitted

else

echo "SKIPPING $CURRENTTARGET"

fi

fi

done


