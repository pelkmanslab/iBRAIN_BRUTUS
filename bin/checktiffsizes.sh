#! /bin/sh

find $1 -name "TIFF" | xargs du -h
