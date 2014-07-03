#! /bin/bash

#
# run_pipes.sh

############################
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh

${PIPESDIR:?"Need to set PIPESDIR non-empty. PIPESDIR is the path to PIPES folder inside PLATEDIR containing the chain of processes based on pippete technology"} &> /dev/null
############################


function main {

        # Exit if PLATEDIR (old PROJECTDIR) contains a "complete" flag.
        if [ -e ${PROJECTDIR}/RunPipes.complete ]; then
            echo "     <status action=\"${MODULENAME}\">completed</status>"
            return
        fi

python - <<PYTHON
# Import iBRAIN environment.
import sys
import os
import ext_path
import logging
from brainy.pipes import PipesModule


# Configure basic logging to point STDOUT.
logging.basicConfig(
        level=logging.INFO,
        stream=sys.stdout,
        format='<!--%(asctime)s %(name)-20s %(levelname)-8s %(message)s-->',
        datefmt='%m-%d %H:%M')


pipes_module = PipesModule('pipes', dict(
    tiff_path='$TIFFDIR',
    plate_path='$PROJECTDIR',
    batch_path='$BATCHDIR',
    postanalysis_path='$POSTANALYSISDIR',
    jpg_path='$JPGDIR',
    pipes_path='$PIPESDIR',
))
pipes_module.process_pipelines()


PYTHON

}


# run standardized bash-error handling of iBRAIN
execute_ibrain_module "$@"

# clear main module function
unset -f main
