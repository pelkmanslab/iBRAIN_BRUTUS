#! /bin/sh

TIMELIMIT="12:00"
DATAFRACTION=1000

for iii in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 24 26 28 30 32 34 36 38 40 45 50 55 60
do
bsub -W $TIMELIMIT -o /BIOL/imsb/fs3/bio3/bio3/Data/Users/Mirko/090212_Vesicle_GMM_$DATAFRACTION/mirko_gmm_$DATAFRACTION_${i}_%J.results -R 'rusage[mem=8000]' "matlab -nodisplay -nojvm << M_PROG
mirko_vesicle_gmm($i,$DATAFRACTION,'rand')
M_PROG"
done
done

# ~/iBRAIN/prioritizejobs.sh mirko
