#! /bin/sh

# removes all output created by the optimize_triplicate_scoring function
TARGETPATH="/BIOL/imsb/fs3/bio3/bio3/Data/Users/50K_final_reanalysis/${1}"

#find $TARGETPATH -mindepth 3 -type f -name "Measurements_Nuclei_CellTypeClassificationForOptimization.mat" -ls -exec rm -f {} \;
#find $TARGETPATH -mindepth 3 -type f -name "cellAllGmdistributionFitFirstGaussianMeanStdevPerImage.mat" -ls -exec rm -f {} \;
find $TARGETPATH -mindepth 2 -type f -name "matInfectionIndicesForOptimization*.mat" -ls -exec rm -f {} \;
find $TARGETPATH -mindepth 2 -type f -name "strucSvmResults.mat" -ls -exec rm -f {} \;
find $TARGETPATH -mindepth 2 -type f -name "cellGaussFits.mat" -ls -exec rm -f {} \;
find $TARGETPATH -mindepth 2 -type f -name "OPTIMIZED_INFECTION.mat" -ls -exec rm -f {} \;
find $TARGETPATH -type f -name "optimize_triplicate_scoring_*.results" -ls -exec rm -f {} \;
find $TARGETPATH -mindepth 2 -type f -name "Measurements_Nuclei_VirusScreen_OptimalInfection*.mat" -ls -exec rm -f {} \;
#find $TARGETPATH -mindepth 3 -type f -name "CreateCellTypeOverview.submitted" -ls -exec rm -f {} \;
find $TARGETPATH -mindepth 2 -type f -name "CP*_triplicate_optimization_overview.pdf" -ls -exec rm -f {} \;
find $TARGETPATH -mindepth 2 -type f -name "CP*_optimized_infection.pdf" -ls -exec rm -f {} \;
#find $TARGETPATH -mindepth 3 -type f -name "*_Triplicate_Optimization_SvmSet_*.pdf" -ls -exec rm -f {} \;
