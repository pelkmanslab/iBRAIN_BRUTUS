#! /bin/sh

bjobs -lr 1> ~/logs/bjobslr.txt

# JOBIDS=$(grep -e 'Job' ~/logs/bjobslr.txt | awk '{print $2}' | sed 's|[<>,]||g')
THREADCOUNTS=$(grep -e 'NTHREAD' ~/logs/bjobslr.txt | awk '{print $8}' | sed 's|<>,||g')

MAILSEND=0
for i in $THREADCOUNTS; do
if [ $(( $i + 0 )) -gt 9 ] && [ $MAILSEND -eq 0 ]; then
mail -s "iBRAIN: $(basename $0): THREAD COUNT OF 9 EXCEEDED!" "snijder@imsb.biol.ethz.ch" < ~/logs/bjobslr.txt
echo "THREAD COUNT OF 9 EXCEEDED!!!, mail sending temporarily disabled"
MAILSEND=1
fi
done
