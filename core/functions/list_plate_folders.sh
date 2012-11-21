#! /bin/bash
#
# list_plate_folders.sh

function list_plate_folders {
    PROJECTPATH=$1

    if [ "$(echo $INCLUDEDPATH | grep '_DG$')" ]; then
        ### IF THIS IS A _DG PROJECT, ONLY LOOK FOR TIFF DIRECTORIES IN DEFINED DEPTH
    	echo "    DG DIRECTORY DETECTED, ONLY LOOKING FOR TIFF DIRS IN PREDEFINED DEPTHS "	
        LISTING=$(find $INCLUDEDPATH -mindepth 2 -maxdepth 2 -type d -name "TIFF")
    else
        ### OTHERWISE WE CAN NOT KNOW THE DEPTH OF THE TIFF DIRECTORIES
        LISTING=$(find $INCLUDEDPATH -type d -name "TIFF")
    fi

    for FOLDER in $LISTING; do
        echo $(dirname $FOLDER)
    done
}

