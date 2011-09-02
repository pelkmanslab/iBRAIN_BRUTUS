#! /bin/sh

TIMELIMIT="8:00"
DATAFRACTION=2000

for iii in  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
bsub -m beta -W $TIMELIMIT -oo /BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/090330_Bayesian_tests/temp.results -R 'rusage[mem=8000]' "matlab -nodisplay -nojvm << M_PROG
singleCellBayesianInferencePerSiRNA_03()
M_PROG"
done
