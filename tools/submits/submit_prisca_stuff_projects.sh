#! /bin/sh

#TARGETPATH="/BIOL/imsb/fs2/bio3/bio3/Data/Users/Berend/BATCH_RESULTS/Data/Users/50K_final/"
TARGETPATH="/BIOL/imsb/fs3/bio3/bio3/Data/Users/Prisca"


#cd $TARGETPATH

for PROJECT in $(find $TARGETPATH -maxdepth 1 -mindepth 1 -type d -name "090203*"); do


bsub -W 08:00 -o "${PROJECT}/MahalanobisPopulationGreen_$(date +"%y%m%d%H%M%S").results" "matlab -nodisplay -nojvm << M_PROG
MeasureMahalanobisDistance_Green('$PROJECT')
M_PROG"

done


