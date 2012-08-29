#! /bin/sh

#OLDBASICDATACOUNT=$( find $1 -name 'BASICDATA.mat' -cmin +360 -maxdepth 1 | wc -l )
#VERYOLDBASICDATACOUNT=$( find $1 -name 'BASICDATA.mat' -ctime +7 -maxdepth 1 | wc -l )
#BASICDATARESULTCOUNT=$( find $1 -name 'FuseBasicData_*.results' -maxdepth 1 | wc -l )

#OLDBASICDATARESULTCOUNT=$( find $1 -name 'FuseBasicData_*.results' -cmin +360 -maxdepth 1 | wc -l )
#BASICDATACOUNT=$( find $1 -name 'BASICDATA.mat' -maxdepth 1 | wc -l )

#BASICDATASUBMITTEDCOUNT=$( find $1 -name 'FuseBasicData.submitted' -maxdepth 1 | wc -l )

#VERYOLDBASICDATASUBMITTEDCOUNT=$( find $1 -name 'FuseBasicData.submitted' -ctime +3 -maxdepth 1 | wc -l )


# echo OLDBASICDATACOUNT=${OLDBASICDATACOUNT}
# echo OLDBASICDATARESULTCOUNT=${OLDBASICDATARESULTCOUNT}
# echo BASICDATACOUNT=${BASICDATACOUNT}

#if ( [ $OLDBASICDATACOUNT -gt 0 ] && [ $OLDBASICDATARESULTCOUNT -gt 0 ] ) || ( [ $BASICDATACOUNT -eq 0 ] && [ $BASICDATASUBMITTEDCOUNT -eq 0 ] ) || [ $VERYOLDBASICDATACOUNT -gt 0 ]; then
REPORTFILE=FuseBasicData_$(date +"%y%m%d%H%M%S").results
#echo "    submitting fuse_basic_data: old results file and basic data file found, or no basic data present yet."
bsub -W 8:00 -o $1/${REPORTFILE} "matlab -singleCompThread -nodisplay -nojvm << M_PROG;
fuse_basic_data_v2('$1');
%check_dg_plate_correlations('$1');
M_PROG"
touch $1/FuseBasicData.submitted
rm -f $1/FuseBasicData_*.results
#else
#echo "    not submitting fuse_basic_data"
#fi


#if [ $VERYOLDBASICDATASUBMITTEDCOUNT -gt 0 ]; then
#rm $1/FuseBasicData.submitted
#fi


### SPECIAL CASE IF THERE IS NO RESULTS FILE PRESENT YET...
# if [ $BASICDATARESULTCOUNT -eq 0 ]; then
# REPORTFILE=FuseBasicData_$(date +"%y%m%d%H%M%S").results
# echo "    submitting fuse_basic_data: old basic data file found and no result file present yet."
# bsub -W 8:01 -o $1/${REPORTFILE} ~/MATLAB/fuse_basic_data/fuse_basic_data.command $1
# else
# echo "    not submitting fuse_basic_data"
# fi
