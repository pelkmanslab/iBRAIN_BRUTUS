#! /bin/sh

#ERRORCOUNT=$(find $1 -name "*.results" -exec grep -li "error" {} \; | wc -l)

echo "STARTING: checkresultfiles.sh $1"
echo "  SCANNING $(($(find $1 -name "*.results" | wc -l))) .results FILES" 

for filepath in $(find $1 -name "*.results" -exec grep -li "error" {} \;); do

echo " "
echo '##############################################################################'
echo "### FILE: $filepath "
echo " "
grep -i -B3 -A3 "error" $filepath
# grep "error" $filepath
ERRORCOUNT=$(($ERRORCOUNT+1))
done

echo FOUND $(($ERRORCOUNT)) .results FILES WITH ERRORS
