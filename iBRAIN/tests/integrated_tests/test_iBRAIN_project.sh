#!/bin/bash

#############################################
### INCLUDE IBRAIN CONFIGURATION
export IBRAIN_ROOT=$(dirname `readlink -m $0`)/../mock/root
if [ -f $IBRAIN_ROOT/etc/config ]; then
    . $IBRAIN_ROOT/etc/config
else
    echo "Aborting $(basename $0) (missing configuration at $IBRAIN_ROOT/etc/config)"
    exit 1
fi

$IBRAIN_ROOT/iBRAIN_project.sh $IBRAIN_ROOT/../project
