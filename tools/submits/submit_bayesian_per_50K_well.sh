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
for iRow in 3 4 5 6 7; do
for iCol in 2 3 4 5 6 7 8 9 10 11; do

#if [ -d ~/WORK/091011_Bayesian_tests/PerWell/${ASSAYPATH}/ ]; then
#echo dir is ok
#fi

FILECOUNT=$( find ~/WORK/100106_Bayesian_tests/PerWell/${ASSAYPATH}/ -name "*_R${iRow}_C${iCol}_O$((${iPlate}-70))*" 2>/dev/null | wc -l)

echo $FILECOUNT - _R${iRow}_C${iCol}_O$((${iPlate}-70))

#for iCol in 2 3 4 5 6 7 8 9 10 11; do
#iPlate=71
#iRow=3
#iCol=2

if [ $FILECOUNT -lt $TARGETCOUNT ] && ! [ $iRow -eq 4 -a $iCol -eq 3 ]; then
echo submitting $iPlate $iCol $iRow $ASSAYPATH
bsub -W $TIMELIMIT -o /BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/100106_Bayesian_tests/${ASSAYPATH}_WELL_R${iRow}_C${iCol}_P${iPlate}.results -R 'rusage[mem=3000]' "matlab -singleCompThread -nodisplay -nojvm << M_PROG
singleCellBayesianPerSi('${ASSAYPATH}', ${iRow}, ${iCol}, ${iPlate})
M_PROG"
fi

done
done
done

done # loop over assays
