#! /bin/sh

PATHNAME=$1

if [ -d $PATHNAME ]; then

echo submitting infectionscoring on $PATHNAME
REPORTFILE=InfectionScoring_$(date +"%y%m%d%H%M%S").results
bsub -W 7:00 -o $PATHNAME/$REPORTFILE ./InfectionScoring/ScoreInfection.command $PATHNAME
touch $(dirname $1)/InfectionScoring.submitted

fi
