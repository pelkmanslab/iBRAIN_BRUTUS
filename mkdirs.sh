#!/bin/bash

function dir_exists {
    # directory $1 exists if it is a dir or a symlink
    if [ -z "$1" ]; then 
        # expected $1 to be a directory
        return
    fi
    if [ ! -d "$1" ] && [ ! -h "$1" ]; then
        return
    fi
    # test passed
    echo 'yes'
}


DIRS="bin etc var var/database var/log var/pipelines"
# Test if those folders exists. If not - try to create them.
for folder in $DIRS; do
    echo "Test if $folder exists.. "
    if [ ! -z "$(dir_exists $folder)" ]; then 
        echo "Yes, continue."
    else
        echo "No, trying to create one."
        mkdir "$folder"
    fi
done

