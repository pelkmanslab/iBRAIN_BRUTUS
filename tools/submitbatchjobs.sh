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
    NUMBEROFRESUBMITS=$(find $1 -maxdepth 1 -name "$(basename $batchjob .txt)*.results" | wc -l)
    if [ $NUMBEROFRESUBMITS -gt 3 ]; then 
       echo ALERT: $batchjob in $1 has been submitted more then 3 times without resulting in valid output | mail -s "iBRAIN: $batchjob exceeded crashlimit" snijder@imsb.biol.ethz.ch
    fi
    # echo found $NUMBEROFRESUBMITS result files for $batchjob

    
    ### check how many image processing toolbox licenses have been handed out, and decide to submit or not on that criterium
    # NUMOFLICENSES=$(lmstat -f Image_Toolbox -c 1965@nava.ethz.ch | grep nava/1965 | wc -l)
    # if [ $NUMOFLICENSES -lt 

    REPORTFILE=$(basename $batchjob .txt)_%J_$(date +"%y%m%d%H%M%S").results
    REPORTFILE2=SubmitBatchJobs.submitted
    # echo submitting ${REPORTFILE}
    echo submitting $1
    echo submitting $(basename $batchjob .txt).mat

#bsub -W 8:00 -o $(dirname $batchjob)/${REPORTFILE} << CPC 
#~/matlab/cpcluster/run_CPCluster.sh /cluster/apps/matlab/7.6/x86_64/ $(dirname $batchjob)/Batch_data.mat $(dirname $batchjob)/$(basename $batchjob .txt).mat;
#CPC

# bsub -W 4:00 -o $(dirname $batchjob)/${REPORTFILE} < ~/matlab/cpcluster/run_CPCluster.sh /cluster/apps/matlab/7.6/x86_64/ $(dirname $batchjob)/Batch_data.mat $(dirname $batchjob)/$(basename $batchjob .txt).mat

#bsub -W 4:00 -o $(dirname $batchjob)/${REPORTFILE}  "matlab -nodisplay -nojvm << M_PROG;
#CPCluster('$(dirname $batchjob)/Batch_data.mat','$(dirname $batchjob)/$(basename $batchjob .txt).mat');
#M_PROG"

bsub -W 08:00 -o $(dirname $batchjob)/$REPORTFILE "matlab -nodisplay -nojvm << M_PROG
CPCluster('$(dirname $batchjob)/Batch_data.mat','$(dirname $batchjob)/$(basename $batchjob .txt).mat');
M_PROG"


    touch $(dirname $1)/$REPORTFILE2
  fi
done
