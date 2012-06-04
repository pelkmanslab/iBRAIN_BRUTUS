#! /bin/sh
echo $( bjobs -w | grep "$1" | wc -l )
