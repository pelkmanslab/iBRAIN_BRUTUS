#! /bin/sh

bsub -W 8:00 "matlab -nodisplay -nojvm << M_PROG
String_shortestpaths_02_50K_only;
M_PROG"
