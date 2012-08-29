#! /bin/sh

DISC=$1
PARTITION=`df -h |grep $DISC |awk '{print $5}'`
SIZE=`df -h|grep $DISC|awk '{print $1}'`
USED=`df -h|grep $DISC|awk '{print $2}'`
FREE=`df -h|grep $DISC|awk '{print $3}'`

echo "DISC USAGE ON $PARTITION FOR $(date +"%y%m%d %H:%M:%S")"
echo "  TOTAL=$SIZE"
echo "  USED=$USED"
echo "  FREE=$FREE"

