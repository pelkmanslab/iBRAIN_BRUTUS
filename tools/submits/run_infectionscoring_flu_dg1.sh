#! /bin/sh

PATHNAME=$1

if [ -d $PATHNAME ]; then

echo submitting infectionscoring on $PATHNAME
REPORTFILE=InfectionScoring_$(date +"%y%m%d%H%M%S").results

### FOR SOME REASON HOME IS NOT USED AS WORK DIRECTORY
#cd ~

bsub -W 8:00 -o $PATHNAME/$REPORTFILE "matlab -nodisplay -nojvm << M_PROG
VirusScreen_Cluster_02_FLU_DG1('$PATHNAME');
TraditionalPostClusterInfectionScoring_FLU_DG1('${PATHNAME}');
M_PROG"

#bsub -W 0:30 -o ${PATHNAME}/${REPORTFILE} "matlab -nodisplay << M_PROG; 
#PreCluster('${2}','${1}/TIFF/','${1}/BATCH/'); 
#M_PROG"


touch $(dirname $1)/InfectionScoring.submitted

fi
