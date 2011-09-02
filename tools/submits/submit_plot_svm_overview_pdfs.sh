#! /bin/sh


### START MAIN LOOP OVER ALL UNDERLYING TIFF FOLDERS

for INCLUDEDPATH in $(sed -e 's/[[:cntrl:]]//g' ~/2NAS/Data/Code/iBRAIN/cfg/paths.txt); do
#INCLUDEDPATH="/BIOL/imsb/fs3/bio3/bio3/Data/Users/Berend/20080710_2"

INCLUDEDPATH=$(echo $INCLUDEDPATH | sed -e 's/^DIS//g')
echo "CHECKING $INCLUDEDPATH"
#continue
for matfile in $(find $INCLUDEDPATH -type f -name "Measurements_SVM_*.mat"); do

# SET MAIN DIRECTORY PARAMETERS
BATCHDIR=$(dirname $matfile)
FILENAME=$(basename $matfile)
POSTANALYSISDIR=$(dirname $BATCHDIR)POSTANALYSIS

OUTPUTFILE=$(dirname $BATCHDIR)/POSTANALYSIS/$(basename $matfile .mat)_overview.pdf

echo "matfile=$matfile"
echo "OUTPUTFILE=$OUTPUTFILE"

if [ ! -e $OUTPUTFILE ]; then
bsub -W 00:10 -o /dev/null "matlab -nodisplay -nojvm << M_PROG
PlotBinaryClassificationResults('${BATCHDIR}','${FILENAME}');
M_PROG"
fi

done
done
