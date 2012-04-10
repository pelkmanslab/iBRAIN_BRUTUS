#! /bin/sh
echo submitting jpg creation on $1
REPORTFILE=CreateJPGs_$(date +"%y%m%d%H%M%S").results
bsub -W 08:00 -o $2/$REPORTFILE "matlab -singleCompThread -nodisplay -nojvm << M_PROG;
create_jpgs('$1','$2');
merge_jpgs_per_plate('$2');
M_PROG"
