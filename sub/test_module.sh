#! /bin/sh	

# This is a wrapper for testing individual modules one at a time. Useful for debugging 

# List of essential parameters (essential as defined by parameter_check.sh):
# INCLUDEDPATH
# TIFFDIRECTORYLISTING
# TIFFDIR
# PROJECTDIR
# BATCHDIR
# POSTANALYSISDIR
# JPGDIR


# Just point this to any directory that contains a TIFF directory:
INCLUDEDPATH="/BIOL/imsb/fs2/bio3/bio3/Data/Users/Katharina/iBrain/120713-MZ-FNp-LMp"
#INCLUDEDPATH="/BIOL/imsb/fs2/bio3/bio3/Data/Users/Gabriele/20120507_FixedOranoids"

# And the rest is all relative
TIFFDIRECTORYLISTING="${INCLUDEDPATH}/TIFF/"
TIFFDIR="${INCLUDEDPATH}/TIFF/"
PROJECTDIR=${INCLUDEDPATH}
BATCHDIR="${INCLUDEDPATH}/BATCH/"
POSTANALYSISDIR="${INCLUDEDPATH}/POSTANALYSIS/"
JPGDIR="${INCLUDEDPATH}/JPG/"

# Jobsfile contains the output of "bjobs -w"
JOBSFILE=~/logs/"temp_bjobs_w_$(date +"%y%m%d_%H%M%S_%N").txt"
echo "<!--"
bjobs -w 1> ${JOBSFILE}
echo "-->"

# Contains the number of jobs that point to PROJECTDIR
PLATEJOBCOUNT=$(grep "${PROJECTDIR}" $JOBSFILE -c)


# Run your module of choice, or from input

if [ $# -eq 1 ]; then  

. ${1}

else

# . ~/sub/illuminationcorrection.sh
. ~/sub/pngconversion.sh

fi


# cleanup jobsfile
rm -f ${JOBSFILE}
