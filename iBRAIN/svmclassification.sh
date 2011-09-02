#! /bin/sh

#echo checking for svm classification files

PROJECT=$1
BATCH=$2

if [ -d $PROJECT ] && [ -d $BATCH ]; then

### look for SVM_*.mat files in the projectpath first

for svmfile in $(find $PROJECT -maxdepth 1 -type f -name "SVM_*.mat"); do

echo "      FOUND $(basename $svmfile)"

OUTPUT=$BATCH/Measurements_$(basename $svmfile)

if [ ! -e $OUTPUT ]; then 

echo "        SUBMITTING $(basename $svmfile)"

#echo submitting svm classification with $svmfile on $BATCH


REPORTFILE=SVMClassification_$(date +"%y%m%d%H%M%S").results
bsub -W 8:00 -o $BATCH/$REPORTFILE "matlab -nodisplay << M_PROG;
SVM_Classify_iBRAIN('$svmfile','$BATCH');
M_PROG"
touch $(dirname $BATCH)/SVMClassification.submitted

echo '   '

else

### output already exists
echo "        FOUND $(basename $OUTPUT)"

#echo output found for SVM Classification with $svmfile in $BATCH

fi

done 


### ALSO LOOK FOR SVM FILES IN THE PARENT OF BATCH

PARENT=$(dirname $BATCH)

#echo looking for SVM_files in $PARENT

for svmfile in $(find $PARENT -maxdepth 1 -type f -name "SVM_*.mat"); do

echo "      FOUND $(basename $OUTPUT)"

OUTPUT=$BATCH/Measurements_$(basename $svmfile)

echo checking for $OUTPUT

if [ ! -e $OUTPUT ]; then

echo "        SUBMITTING $(basename $svmfile)"
#echo submitting svm classification with $svmfile on $BATCH

REPORTFILE=SVMClassification_$(date +"%y%m%d%H%M%S").results
bsub -W 8:00 -o $BATCH/$REPORTFILE "matlab -nodisplay << M_PROG;
SVM_Classify_iBRAIN('$svmfile','$BATCH');
M_PROG"
touch $(dirname $BATCH)/SVMClassification.submitted

else

### output already exists

echo "        FOUND $(basename $OUTPUT)"
#echo output found for SVM Classification with $svmfile in $BATCH

fi

done

fi
