#! /bin/sh

for inputfilename in $(find $1 -maxdepth 1 -type f -name "Measurements_*BlueSpectrum.mat"); do

PATHNAME=$(dirname $inputfilename)

if [ ! -r $PATHNAME/Measurements_Image_OutOfFocus.mat ]; then

echo submitting outoffocus scoring on $PATHNAME
REPORTFILE=CheckOutOfFocus_$(date +"%y%m%d%H%M%S").results
bsub -W 8:00 -o $PATHNAME/$REPORTFILE "matlab -singleCompThread -nodisplay -nojvm << M_PROG; 
check_outoffocus('$PATHNAME');
M_PROG"
touch $(dirname $1)/CheckOutOfFocus.submitted
else

echo skipped $PATHNAME for outoffocus scoring

if [ ! -e $(dirname $1)/CheckOutOfFocus.submitted ]; then
touch $(dirname $1)/CheckOutOfFocus.submitted
fi

fi

done

touch $(dirname $1)/CheckOutOfFocus.submitted
