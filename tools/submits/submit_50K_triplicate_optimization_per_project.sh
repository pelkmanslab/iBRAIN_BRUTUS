#! /bin/sh

TARGETPATH="/BIOL/imsb/fs3/bio3/bio3/Data/Users/50K_final_reanalysis/${1}"

if [ "$1" ] && [ -d $TARGETPATH ]; then
echo doing $TARGETPATH
else
echo "invalid input"
exit
fi

#FOLDERLIST=`find $TARGETPATH -maxdepth 1 -mindepth 1 -type d -name "*_*" -printf "%p%%"`

ORIGIFS=$IFS
IFS="%%"

#for foldername in $FOLDERLIST; do

#if [ "$foldername" ]; then

#CURRENTTARGET="$(basename $foldername)/"

#echo $foldername

# SUBFOLDERCHECK=`find $CURRENTTARGET -maxdepth 1 -type f -name "Measurements_*.mat" | wc -l`

# if [ $SUBFOLDERCHECK -gt 10 ]; then



#echo DOING "$CURRENTTARGET"
#NUMBERS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70"
NUMBERS="71%72%73"
foldername=$TARGETPATH
SEARCHSTRING="optimize_triplicate_scoring_2"

for i in $NUMBERS
do
echo "doing optimize_triplicate_scoring_4('$foldername','$i')"
bsub -W 08:00 -oo "$foldername/optimize_triplicate_scoring_4_${i}_$(date +"%y%m%d%H%M%S").results" "matlab -nodisplay -nojvm << M_PROG
optimize_triplicate_scoring_4('$foldername','$i')
M_PROG"
done


IFS=$ORIGIFS

~/iBRAIN/prioritizejobs.sh $SEARCHSTRING

#else

#echo "SKIPPING $CURRENTTARGET"

#fi

#fi

#done


