#!/bin/bash

find ../Compiled -type f -name '*.m' | parallel '/home/yy/dev/imls/pelkmans/General/+cmt/remove_matlab_comments.py {} {}'

