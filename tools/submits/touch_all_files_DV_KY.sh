#! /bin/sh

DIR="/BIOL/imsb/fs2/bio3/bio3/TO TAPE/50K_final/DV_KY/"
echo touching all files in $DIR
find "$DIR" -type f -name "*" -exec touch -c -a {} \; 2>/dev/null
exit 0
