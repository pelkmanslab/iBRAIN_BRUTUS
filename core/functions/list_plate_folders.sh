#! /bin/bash
#
# list_plate_folders.sh

function list_plate_folders {
    PROJECTPATH=$1

    if [ "$(echo $INCLUDEDPATH | grep '_DG$')" ]; then
        ### IF THIS IS A _DG PROJECT, ONLY LOOK FOR TIFF DIRECTORIES IN DEFINED DEPTH
    	echo "    DG DIRECTORY DETECTED, ONLY LOOKING FOR TIFF DIRS IN PREDEFINED DEPTHS "	
        LISTING=$(find $INCLUDEDPATH -mindepth 2 -maxdepth 2 -type d -name 'TIFF' | parallel 'dirname {}' |  uniq)
    else
        ### OTHERWISE WE CAN NOT KNOW THE DEPTH OF THE TIFF DIRECTORIES
        LISTING=$(find $INCLUDEDPATH -type d -regex '.*\/\(TIFF\|NIKON\)$' | parallel 'dirname {}' |  uniq)
    fi

    for FOLDER in $LISTING; do
        echo $FOLDER
    done
}

