#! /bin/sh

#######################
# RESUBMIT BATCH JOBS #
####################### 

find $1 -name "*.pnl" | grep -v "z_focus_map*" | rm -f
