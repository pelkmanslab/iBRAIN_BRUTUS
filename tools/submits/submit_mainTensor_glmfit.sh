#! /bin/sh

TARGETPATH="/BIOL/imsb/fs2/bio3/bio3/Data/Users/YF_DG/"

#cd $TARGETPATH

FOLDERLIST=`find $TARGETPATH -maxdepth 1 -mindepth 1 -type d -printf "%p%%"`

IFS="%%"

for foldername in $FOLDERLIST; do

if [ "$foldername" ]; then

CURRENTTARGET="$TARGETPATH/$(basename $foldername)/BATCH/"

SUBFOLDERCHECK=`find $CURRENTTARGET -maxdepth 1 -type f -name "Measurements_*.mat" | wc -l`

if [ $SUBFOLDERCHECK -gt 10 ]; then

echo DOING "$CURRENTTARGET"

bsub -W 08:00 -o "${CURRENTTARGET}mainTensorModel_$(date +"%y%m%d%H%M%S").results" "matlab -nodisplay -nojvm << M_PROG
mainTensorModel_glmfit('$CURRENTTARGET','${TARGETPATH}ProbModel_Settings.txt');
M_PROG"

# touch $JPGTARGET/CreateJPGs.submitted

else

echo "SKIPPING $CURRENTTARGET"

fi

fi

done


