#! /bin/sh

# 50K Directory
TARGETPATH="/BIOL/imsb/fs3/bio3/bio3/Data/Users/50K_final_reanalysis/"
# List all subdirectories
FOLDERLIST=`find $TARGETPATH -maxdepth 2 -mindepth 2 -type f -name "ADVANCEDDATA.mat" -printf "%p%%"`
# Internal file separator
IFS="%%"
# Job time limit
TIMELIMIT="8:00"

TARGETCOUNT=11

for foldername in $FOLDERLIST; do
ASSAYPATH=$(basename $(dirname $foldername))
echo "$ASSAYPATH"

for iPlate in 71 72 73; do
for iReplicate in 1 2 3; do


#if [ -d ~/WORK/091011_Bayesian_tests/PerWell/${ASSAYPATH}/ ]; then
#echo dir is ok
#fi

FILECOUNT=$( find ~/WORK/091011_Bayesian_tests/PerPlate/${ASSAYPATH}/ -name "*_P${iPlate}_R${iReplicate}*" | wc -l)

echo $FILECOUNT - _P${iPlate}_R${iReplicate}

#for iCol in 2 3 4 5 6 7 8 9 10 11; do
#iPlate=71
#iRow=3
#iCol=2

if [ $FILECOUNT -lt $TARGETCOUNT ]; then
echo submitting $iPlate $iReplicate $ASSAYPATH
bsub -W $TIMELIMIT -o /BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/091011_Bayesian_tests/${ASSAYPATH}_PLATE_P${iPlate}_R${iReplicate}.results -R 'rusage[mem=3000]' "matlab -singleCompThread -nodisplay -nojvm << M_PROG
singleCellBayesianPerAssayPerPlate('${ASSAYPATH}', ${iPlate}, ${iReplicate})
M_PROG"
fi

done
done

done # loop over assays
