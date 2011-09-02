#! /bin/sh
echo submitting plate normalization on $1
REPORTFILE=MeasurementsMeanStd_$(date +"%y%m%d%H%M%S").results
bsub -W 8:00 -o $1/$REPORTFILE "matlab -singleCompThread -nodisplay -nojvm << M_PROG; 
Measurements_mean_std_iBRAIN('$1');
M_PROG"
