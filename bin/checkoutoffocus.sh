#! /bin/sh

for inputfilename in $(find $1 -name "Measurements_*BlueSpectrum.mat" -type f -maxdepth 1); do

PATHNAME=$(dirname $inputfilename)

if [ ! -r $PATHNAME/Measurements_Image_OutOfFocus.mat ]; then

echo submitting outoffocus scoring on $PATHNAME
REPORTFILE=CheckOutOfFocus_$(date +"%y%m%d%H%M%S").results
bsub -W 7:00 -o $PATHNAME/$REPORTFILE ./CheckOutOfFocus/CheckOutOfFocus.command $PATHNAME

else

echo skipped $PATHNAME for outoffocus scoring

fi

done
