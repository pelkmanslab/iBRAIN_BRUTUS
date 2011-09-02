#! /bin/sh

echo touching all files in $1
find "$1" -type f -name "*" -ls -exec touch -c -a {} \;
exit 0
