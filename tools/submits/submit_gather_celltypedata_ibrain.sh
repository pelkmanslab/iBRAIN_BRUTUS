#! /bin/sh

TARGETPATH="/BIOL/imsb/fs2/bio3/bio3/Data/Users/SV40_DG/"

FOLDERLIST=`find $TARGETPATH -maxdepth 3 -mindepth 2 -type f -name "BASICDATA_*.mat" -printf "%p%%"`

IFS="%%"

for foldername in $FOLDERLIST; do

if [ "$foldername" ]; then

CURRENTTARGET="$(dirname $foldername)/"



# SUBFOLDERCHECK=`find $CURRENTTARGET -maxdepth 1 -type f -name "Measurements_*.mat" | wc -l`

# if [ $SUBFOLDERCHECK -gt 10 ]; then

echo DOING "$CURRENTTARGET"

bsub -W 08:00 -o "${CURRENTTARGET}Gather_CellTypeData_iBRAIN_$(date +"%y%m%d%H%M%S").results" "matlab -nodisplay -nojvm << M_PROG
Gather_CellTypeData_iBRAIN('$CURRENTTARGET');
M_PROG"

else

echo "SKIPPING $CURRENTTARGET"

fi

# fi

done


