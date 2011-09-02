#! /bin/sh
echo $( bjobs -w 2>/dev/null | grep "$1" | wc -l )
