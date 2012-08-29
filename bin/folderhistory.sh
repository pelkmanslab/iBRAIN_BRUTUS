#! /bin/sh

LOGPATH="/hreidar/extern/bio3/Data/iBRAIN/logs/"

find $LOGPATH -name "*.log" -exec cat {} \; | grep $1
