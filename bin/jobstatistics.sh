#! /bin/sh

INITIALJOBS=$(( $( bjobs | wc -l) - 1 ))

ALLJOBS=$(( $( bjobs | wc -l) - 1 ))
RUNNINGJOBS=$(( $( bjobs -r | wc -l) - 1 ))
PENDINGJOBS=$(( $ALLJOBS - $RUNNINGJOBS ))


echo "JOB STATISTICS FOR $(date +"%y%m%d %H:%M:%S")"
echo "  ALL=$ALLJOBS"
echo "  RUNNING=$RUNNINGJOBS" 
echo "  PENDING=$PENDINGJOBS"
echo "  NEW=$(($INITIALJOBS - $ALLJOBS))"

#echo prioritizing $1 jobs

#for JOBID in $( bjobs -w | grep "$1" | cut -c1-7 ); do

#if [ $(($JOBID + 0)) -gt 0 ]; then

#btop $JOBID

#fi

#done
