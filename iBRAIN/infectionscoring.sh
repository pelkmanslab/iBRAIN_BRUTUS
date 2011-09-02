#! /bin/sh

PATHNAME=$1

if [ -d $PATHNAME ]; then

echo submitting infectionscoring on $PATHNAME
REPORTFILE=InfectionScoring_$(date +"%y%m%d%H%M%S").results

### FOR SOME REASON HOME IS NOT USED AS WORK DIRECTORY
cd ~

bsub -W 0:50 -o $PATHNAME/$REPORTFILE "matlab -singleCompThread -nodisplay -nojvm << M_PROG
TraditionalPostClusterInfectionScoring('${PATHNAME}');
M_PROG"

#bsub -W 0:30 -o ${PATHNAME}/${REPORTFILE} "matlab -nodisplay << M_PROG; 
#PreCluster('${2}','${1}/TIFF/','${1}/BATCH/'); 
#M_PROG"


touch $(dirname $1)/InfectionScoring.submitted

fi
