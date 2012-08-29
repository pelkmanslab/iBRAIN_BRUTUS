#! /bin/sh

#######################
# RESUBMIT BATCH JOBS #
####################### 

echo looking for batchfiles in $1

for batchjob in `find $1 -name 'Batch_*.txt'`
do
  
  # echo $(basename $batchjob .txt)_OUT.mat
  if [ ! -r $(dirname $batchjob)/$(basename $batchjob .txt)_OUT.mat ]; then 


    ### TESTING E-MAIL REPORTS ON MULTIPLE BATCHJOB CRASHES
    NUMBEROFRESUBMITS=$(find $1 -name "$(basename $batchjob .txt)*.results" -maxdepth 1 | wc -l)
    if [ $NUMBEROFRESUBMITS -gt 3 ]; then 
       echo ALERT: $batchjob in $1 has been submitted more then 3 times without resulting in valid output | mail -s "iBRAIN: $batchjob exceeded crashlimit" snijder@imsb.biol.ethz.ch
    fi
    # echo found $NUMBEROFRESUBMITS result files for $batchjob


    REPORTFILE=$(basename $batchjob .txt)_$(date +"%y%m%d%H%M%S").results
    REPORTFILE2=SubmitBatchJobs.submitted
    # echo submitting ${REPORTFILE}
    echo submitting $1
    echo submitting $(basename $batchjob .txt).mat
    bsub -W 7:00 -o $(dirname $batchjob)/${REPORTFILE}  ~/CPCluster2/CPCluster.command $(dirname $batchjob)/Batch_data.mat $(dirname $batchjob)/$(basename $batchjob .txt).mat
    touch $(dirname $1)/$REPORTFILE2
  fi
done
