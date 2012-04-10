#! /bin/sh

BATCHDIR=$1

if [ -r $BATCHDIR/Batch_data.mat ] && [ -r $BATCHDIR/Measurements_Image_ObjectCount.mat ]; then 
    
for MATFILE in $(find $BATCHDIR -name 'Measurements_*.mat' -type f)
do 

# ./CheckMeasurementsFile.command $MATFILE $BATCHDIR/Batch_data.mat

BATCHCOUNT=$(find $BATCHDIR -name "Batch_*_$(basename $MATFILE)" -type f | wc -l)

if [ $BATCHCOUNT -gt 0 ]; then

# BS, 2009-02-10, change to non-compiled checkmeasurementsfile...
#DATACHECKOUT=$(~/matlab/checkmeasurementsfile/run_checkmeasurementsfile.sh /cluster/apps/matlab/7.6/x86_64/ $MATFILE $BATCHDIR/Batch_data.mat $BATCHDIR/Measurements_Image_ObjectCount.mat)

RUNCOMMAND="checkmeasurementsfile('$MATFILE','$BATCHDIR/Batch_data.mat','$BATCHDIR/Measurements_Image_ObjectCount.mat')";
DATACHECKOUT=$(matlab -singleCompThread -nodisplay -nojvm << M_PROG 
$RUNCOMMAND  
M_PROG)


# echo $DATACHECKOUT

DATACHECKOK=$(echo "$DATACHECKOUT" | grep "is complete" -c )
DATACHECKNOTOK=$(echo "$DATACHECKOUT" | grep "is NOT complete" -c)

if [ ! $DATACHECKNOTOK -eq 1 ]; then

# [BS 2008-12-09] PREVIOUS CODE, BUT LET'S MAKE THE CHECKING LESS STRICT
# if [ $DATACHECKOK -eq 1 ]; then

echo DATA COMPLETE $MATFILE 

echo DELETING $BATCHCOUNT BATCH FILES OF TYPE $(basename $MATFILE .mat)

### CLEAN UP BATCH FILES...
for BATCHFILE in $(find $BATCHDIR -name "Batch_*_$(basename $MATFILE)" -type f)
do
rm -f $BATCHFILE
done

### CLEAN UP OLD DATACHECK FILES
rm -f $BATCHDIR/$(basename $MATFILE .mat).datacheck-*


elif [ $DATACHECKNOTOK -eq 1 ]; then

echo !!! DATA INCOMPLETE - $MATFILE
touch $BATCHDIR/$(basename $MATFILE .mat).datacheck-incomplete

# BY MAKING THE CODE LESS SCTRICT, THIS CASE IS NO LONGER VALID... (IF UNKNOWN, IT WILL BE CONSIDERED TO BE OK)
#else
#
#echo !!! DATA INTEGRITY UNKOWN - $MATFILE
#touch $BATCHDIR/$(basename $MATFILE .mat).datacheck-unknown
#

fi # end datacheck if

else

echo SKIPPED $MATFILE \(no matching batchfiles\)

fi # end batchcount > 0 if

echo " "

done

fi
