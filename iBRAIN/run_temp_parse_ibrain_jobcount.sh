#! /bin/sh

if [ ! "$(grep temp_parse_ibrain_jobcount ~/logs/bjobsw.txt)" ]; then

bsub -W 0:50 -o /dev/null "matlab -singleCompThread -nodisplay -nojvm << M_PROG
temp_parse_ibrain_jobcount();
temp_parse_ibrain_diskusage();
M_PROG"

else

~/iBRAIN/prioritizejobs.sh temp_parse_ibrain_jobcount

fi

