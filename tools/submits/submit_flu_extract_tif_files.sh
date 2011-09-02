#! /bin/sh

TARGETPATH="/BIOL/imsb/fs2/bio3/bio3/Data/Users/Salmonella_DG"

cd $TARGETPATH

FOLDERLIST=`find $TARGETPATH -maxdepth 1 -mindepth 1 -type f -name "*.tar" -printf "%p%%"`

IFS="%%"

# limit the number of jobs to 15
COUNTER=0

for foldername in $FOLDERLIST; do

# check result file for errors, if none found, delete tar file.
RESULTFILE=$TARGETPATH/$(basename $foldername .tar).results
if [ -e $RESULTFILE ]; then
 ERRORCOUNT=$(grep -i "ERror" $RESULTFILE -c)
 if [ $ERRORCOUNT -eq 0 ]; then
  echo "no errors found in $RESULTFILE"
  #rm -f $foldername
  continue
 else
  echo "$ERRORCOUNT error(s) found in $RESULTFILE"
  echo "Trying again..."
 fi
fi

COUNTER=$(($COUNTER + 1))
if [ $COUNTER -gt 15 ]; then
 exit 0
fi

if [ "$foldername" ]; then

echo $COUNTER = $foldername

bsub -W 08:00 -oo $RESULTFILE  "cd /BIOL/imsb/fs3/bio3/bio3/Data/Users/Salmonella_DG; tar -xvf $foldername;"

fi

done

# ~/iBRAIN/prioritizejobs.sh optimize
