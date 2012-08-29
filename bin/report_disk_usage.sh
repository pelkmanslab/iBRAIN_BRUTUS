#! /bin/sh
DISKUSAGEFILE="/BIOL/imsb/fs2/bio3/bio3/Data/Code/iBRAIN/database/diskusage.txt"
LOGFILE=~/logs/diskusage.txt

SHARE2=$(df -kP /BIOL/imsb/fs2/bio3/bio3/ 2>/dev/null | tail -n 1 )
SHARE3=$(df -kP /BIOL/imsb/fs3/bio3/bio3/ 2>/dev/null | tail -n 1 )

# append always
echo "$(date +"%y%m%d %H:%M:%S") $SHARE2" >> $DISKUSAGEFILE
echo "$(date +"%y%m%d %H:%M:%S") $SHARE3" >> $DISKUSAGEFILE

# overwrite, then append
touch $LOGFILE
echo ${SHARE2} > $LOGFILE 
echo ${SHARE3} >> $LOGFILE
