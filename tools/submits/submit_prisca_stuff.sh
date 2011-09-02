#! /bin/sh

TARGETPATH="/BIOL/imsb/fs2/bio3/bio3/Data/Users"


#cd $TARGETPATH

for PROJECT in $(find $TARGETPATH -maxdepth 1 -mindepth 1 -type d -name "1108*"); do


if [ "$PROJECT" ]; then

echo "checking $PROJECT for plate directories"

for PLATE in $(find $PROJECT -mindepth 1 -maxdepth 4 -type d -name "TIFF"); do

echo DOING "$PLATE"

bsub -W 08:00 -o "${PLATE}/Combinations$(date +"%y%m%d%H%M%S").results" "matlab -singleCompThread -nodisplay -nojvm << M_PROG
create_jpgs_aut_Prisca('$PLATE')
M_PROG"

done

fi

done

