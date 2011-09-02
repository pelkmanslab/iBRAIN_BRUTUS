#! /bin/sh

LOGFILENAME="$(date +"%y%m%d%H%M%S")"_brutus.log

./ibrain.sh > ~/$LOGFILENAME 2>&1
if [ $(cat ~/$LOGFILENAME | grep "^Aborting:" | wc -l) -eq 0 ]; then
cp ~/$LOGFILENAME ~/NAS/Data/Code/iBRAIN/logs/$(date +"%y%m%d%H%M%S")_brutus.log
else
echo $(cat ~/$LOGFILENAME)
fi
rm ~/$LOGFILENAME
exit 0
