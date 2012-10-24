#! /bin/sh

PATHNAME=$(dirname $1)

if [ ! -d $PATHNAME/POSTANALYSIS ]; then
mkdir $PATHNAME/POSTANALYSIS
fi

echo submitting create plate overview on $PATHNAME
REPORTFILE=CreatePlateOverview_$(date +"%y%m%d%H%M%S").results
bsub -W 8:00 -R "rusage[mem=4096]" -o $1/$REPORTFILE "matlab -nodisplay << M_PROG;
generate_basic_data('$1','$PATHNAME/POSTANALYSIS');
M_PROG"
touch $PATHNAME/CreatePlateOverview.submitted

