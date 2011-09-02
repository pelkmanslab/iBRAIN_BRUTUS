#! /bin/sh

TARGETPATH="/BIOL/imsb/fs2/bio3/bio3/Data/Users/SV40_DG/"

# find $TARGETPATH -maxdepth 3 -mindepth 3 -type f -name "BASICDATA_*.mat" -ls

FOLDERLIST=`find $TARGETPATH -maxdepth 3 -mindepth 3 -type f -name "BASICDATA_*.mat" -printf "%p%%"`

IFS="%%"

for foldername in $FOLDERLIST; do

if [ "$foldername" ]; then

CURRENTTARGET="$(dirname $foldername)/"



# SUBFOLDERCHECK=`find $CURRENTTARGET -maxdepth 1 -type f -name "Measurements_.mat" | wc -l`

if [ ! -e ${CURRENTTARGET}Measurements_Well_BootstrappedSingleCellInfectionCorrelation.mat ]; then

echo DOING "$CURRENTTARGET"

bsub -W 08:00 -o "${CURRENTTARGET}singleCellCorrelationsPerWell_$(date +"%y%m%d%H%M%S").results" "matlab -nodisplay -nojvm << M_PROG
getSingleCellCorrelationsPerWell('$CURRENTTARGET');
M_PROG"

else

echo "SKIPPING $CURRENTTARGET, Measurements_Well_BootstrappedSingleCellInfectionCorrelation.mat already present"

fi

fi

done


