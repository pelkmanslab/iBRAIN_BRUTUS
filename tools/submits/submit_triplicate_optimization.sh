#! /bin/sh

TARGETPATH="/BIOL/imsb/fs2/bio3/bio3/Data/Users/SV40_DG/"

#FOLDERLIST=`find $TARGETPATH -maxdepth 3 -mindepth 2 -type f -name "BASICDATA_*.mat" -printf "%p%%"`

#IFS="%%"

#for foldername in $FOLDERLIST; do

#if [ "$foldername" ]; then

#CURRENTTARGET="$(dirname $foldername)/"



# SUBFOLDERCHECK=`find $CURRENTTARGET -maxdepth 1 -type f -name "Measurements_*.mat" | wc -l`

# if [ $SUBFOLDERCHECK -gt 10 ]; then



#echo DOING "$CURRENTTARGET"
NUMBERS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70"
for i in $NUMBERS
do
echo "doing $i"
bsub -W 08:00 -o "~/optimize_triplicate_scoring_{$i}_$(date +"%y%m%d%H%M%S").results" "matlab -nodisplay -nojvm << M_PROG
optimize_triplicate_scoring('$i')
M_PROG"

done

#else

#echo "SKIPPING $CURRENTTARGET"

#fi

# fi

#done


