#! /bin/sh


TIMELIMIT="1:00"
DATAFRACTION=3000

#for iii in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
#for i in 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
#for i in 2 3 4 5 6 7 8 9 10 11 12 13 14 15
#do
#bsub -m beta -W $TIMELIMIT -oo /BIOL/imsb/fs3/bio3/bio3/Data/Users/Mirko/Berend/090316_Vesicle_GMM_$DATAFRACTION/mirko_gmm_$DATAFRACTION_${i}.results -R 'rusage[mem=8000]' "matlab -nodisplay -nojvm << M_PROG
#mirko_vesicle_gmm_2($i,$DATAFRACTION,'rand')
#M_PROG"
#done
#done

# exit 0

TIMELIMIT="1:00"
DATAFRACTION=3000

for iii in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 24 26 28 30 32 34 36 38
do
bsub -m beta -W $TIMELIMIT -oo /BIOL/imsb/fs3/bio3/bio3/Data/Users/Mirko/Berend/090316_Vesicle_GMM_$DATAFRACTION/mirko_gmm_$DATAFRACTION_${i}.results -R 'rusage[mem=8000]' "matlab -nodisplay -nojvm << M_PROG
mirko_vesicle_gmm_2($i,$DATAFRACTION,'rand')
M_PROG"
done
done

# exit 0

TIMELIMIT="8:00"

for iii in 1 2 3 4 5 6 7 8 9 10; do
# for i in 40 45 50 55 60 65 65 65 65 65 65 65 65 65 65 65 65 65 70 70 70 70 70 70 70 70 70 70 70 70 70 70 80 80 80 80 90 90 90 90 90 100 125 150 175 200 250 300
for i in 40 45 50 55 60 65 70
do
bsub -m beta -W 8:00 -oo /BIOL/imsb/fs3/bio3/bio3/Data/Users/Mirko/Berend/090316_Vesicle_GMM_$DATAFRACTION/mirko_gmm_$DATAFRACTION_${i}.results -R 'rusage[mem=8000]' "matlab -nodisplay -nojvm << M_PROG
mirko_vesicle_gmm_2($i,$DATAFRACTION,'rand')
M_PROG"
done
done

exit 0

TIMELIMIT="24:00"
DATAFRACTION=1
for iii in 1 2 3 4 5; do
# for i in 40 45 50 55 60 65 65 65 65 65 65 65 65 65 65 65 65 65 70 70 70 70 70 70 70 70 70 70 70 70 70 70 80 80 80 80 90 90 90 90 90 100 125 150 175 200 250 300
for i in 7 8 9 10 11 12 13 14 15
do
bsub -m beta -W $TIMELIMIT -oo /BIOL/imsb/fs3/bio3/bio3/Data/Users/Mirko/Berend/090316_Vesicle_GMM_$DATAFRACTION/mirko_gmm_$DATAFRACTION_${i}.results -R 'rusage[mem=18000]' "matlab -nodisplay -nojvm << M_PROG
mirko_vesicle_gmm_2($i,$DATAFRACTION,'rand')
M_PROG"
done
done
## ~/iBRAIN/prioritizejobs.sh mirko
