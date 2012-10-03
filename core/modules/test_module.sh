#! /bin/bash	

# This is a wrapper for testing individual modules one at a time. Useful for debugging 

# List of essential parameters (essential as defined by parameter_check.sh):
# INCLUDEDPATH
# TIFFDIRECTORYLISTING
# TIFFDIR
# PROJECTDIR
# BATCHDIR
# POSTANALYSISDIR
# JPGDIR

# execute_ibrain_module is the standard function called at the end of iBRAIN modules that have a "main" function.
# It does basic BASH error handling & reporting, and imporves robustness to crashes from individual modules by
# escaping their XML output.
function execute_ibrain_module {

    echo "<!-- executing module function"
    ERRORLOG=$(mktemp)
    MODULEOUT=$( main 2> $ERRORLOG)
    MODULEEXITCODE=$?
    MODULERR=$(cat $ERRORLOG )
    rm $ERRORLOG
    echo "end of module function -->"

    if [ "$MODULERR" ]; then
        echo "     <status action=\"${MODULENAME}\">failed"
        echo "      <warning>"
        echo "    iBRAIN module \"${MODULEPATH}\" had a bash error. The error message is as follows: \"${MODULERR}\""
        echo "      </warning>"
        echo "      <output>"
        # print output while escaping reserved xml characters
        echo $(echo ${MODULEOUT} | sed -e 's~&~\&amp;~g' -e 's~<~\&lt;~g' -e  's~>~\&gt;~g' -e 's~--~\-~g')
        echo "      </output>"
        echo "     </status>"
    else
        echo "${MODULEOUT}"
    fi

}


# Just point this to any directory that contains a TIFF directory:
INCLUDEDPATH="/cluster/scratch_xl/shareholder/pelkmans/Data/Users/RNAFish/PLATES/120617_InSitu_CP104-1aa_Corr"
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

bjobs -w 1> ${JOBSFILE} 2> /dev/null


# Contains the number of jobs that point to PROJECTDIR
PLATEJOBCOUNT=$(grep "${PROJECTDIR}" $JOBSFILE -c)


# Source the module of choice, as given by first input

if [ $# -eq 1 ] && [ -f $1 ] && [ "${1}" ]; then

. ${1}

else

    echo "First input must be the path to the module to test..."

fi


# cleanup jobsfile
rm -f ${JOBSFILE}
