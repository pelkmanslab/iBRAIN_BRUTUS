#!/bin/bash

#############################################
### MOCK SOME OF IBRAIN CONFIGURATION
export IBRAIN_ROOT=$(dirname `readlink -m $0`)/../mock/root
export IBRAIN_BIN_PATH=$IBRAIN_ROOT/bin
export PATH=$IBRAIN_BIN_PATH:$PATH

#echo $PATH
#which mip.py

IMGDIR=${IBRAIN_ROOT}/../images
mip.py $IMGDIR/B06f00d0.png $IMGDIR/B06f00d1.png --outfile /tmp/ibrain_mip_test.png
RESULT="$(md5sum /tmp/ibrain_mip_test.png | awk '{print $1}')"

if [ ! -e /tmp/ibrain_mip_test.png ] || [ $RESULT != "b57e8860718a02a160da70027a56fbab" ]; then
    echo "Failed: MIP outfile has wrong checksum or is not found!"
else
    echo "OK"
fi

