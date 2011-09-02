#! /bin/sh

TIMELIMIT="1:00"

# Note, All DG runs within 8 hours, Cameron should run within 1 hour

for iii in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
bsub -W $TIMELIMIT "matlab -singleCompThread -nodisplay -nojvm << M_PROG
prank_brutus_NucleusSizeNotInfected()
#prank_brutus_Cameron()
#prank_brutus_all_DGs()
M_PROG"
done
done

