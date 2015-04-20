#!/bin/bash
#
# This script will convert molecular devices folder structure into iBrain
# expected format.
# 
#
# EXPECTED INPUT PATH EXAMPLE:
#    270711TomJamesNicoMovie/110727HoechstHelak/2011-07-27/2707/TimePoint_1/\
#        010611RFPGFPtestAndFakiplusFrankF07_s11_w1053D3E17-83B9-4556-906A-2A1BCA100550.png
# where ACQUISITION_FOLDER -> 270711TomJamesNicoMovie
# 
# @author: Yauhen Yakimovich <yauhen.yakimovich@uzh.ch>
# 

if [[ $# -ne 2 ]]; then
    echo "Missing parameters: $0 <ACQUISITION_FOLDER> <DESTINATION_FOLDER>"
    exit
fi

ACQUISITION_FOLDER=$1
DST_FOLDER=$2

DRY_RUN=0

# GET ALL IMAGES FOUND INSIDE THE FOLDER STRUCTURE OF THE MOLECULAR DEVICES
# (MD) MICROSCOPE

# STRUCTURE IS DEFINED BY THIS REGEXP:
#                 date                ID        timepoint
regexp='[0-9]{4}-[0-9]{2}-[0-9]{2}/[0-9]{4}/TimePoint_[0-9]*/[^/]*\.(png|tif)$'
MD_IMAGES=$(find ${ACQUISITION_FOLDER} -type f | egrep $regexp )
if [[ $? -ne 0 ]]; then MD_IMAGES=;fi

# CHECK IF ACQUISITION_FOLDER STRUCTURE CORRESPONDS TO MD STRUCTURE; IF IT DOES
# NOT - EXIT
#NO_MD_STRUCTURE=$(if [[ ${#MD_IMAGES[@]} -gt 0 ]]; then echo 0; else echo 1; fi)
NO_MD_STRUCTURE=$(if [ -z $MD_IMAGES ]; then echo 1; else echo 0; fi)

if [[ $NO_MD_STRUCTURE -ne 0 ]]; then
    echo "There was no MD structure found. Nothing to do.."
    exit
fi

echo "Found MD STRUCTURE. Proceeding to convert it into iBrain suitable folder format:"

# FOR EACH IMAGE IN FOUND IMAGES:
#   - PUT THE TIMEPOINT INTO NEW NAME OF THE FILE
#   - RESTRUCTURE FOLDERS TO CONFIRM THE CP FORMAT
for IMAGE in $MD_IMAGES; do
    IMAGE_FOLDER=$(dirname $IMAGE)
    IMAGE_FILE=$(basename $IMAGE)
    # EXPECTING TIME POINT VALUE TO BE THE LAST FOLDER
    TIME_POINT=$(basename "$IMAGE_FOLDER" | sed 's|\([^0-9]*\)||g' )
    # PRODUCE A NICE FOUR DIGITS "CP" FORMAT FOR TIMEPOINT 
    TIME_POINT_STR=_t$(printf "%04d" $TIME_POINT)_
    # SUBSTITUTE TIMEPOINT INTO THE NEW FILENAME OF THE IMAGE
    DST_IMAGE_FILE=$(echo $IMAGE_FILE | sed "s|\_|${TIME_POINT_STR}|" )
    #echo $DST_IMAGE_FILE
    DST_IMAGE=$DST_FOLDER/$DST_IMAGE_FILE
    if [[ $DRY_RUN -gt 0 ]]; then
        # RUN IN DRY MODE
        echo "mv $IMAGE $DST_IMAGE"
    else
        mv $IMAGE $DST_IMAGE
        printf '.'
    fi
done
echo

# TODO: (OPTIONALY) REMOVE EMPTY FOLDERS OF MD STRUCTURE    
# rm -rf IMAGE_FOLDER

