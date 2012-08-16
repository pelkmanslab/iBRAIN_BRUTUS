#! /bin/bash	

# This document should be included at the beginning of each sub-module, and checks if strictly essential parameters are set. 

# List of essential parameters:
# INCLUDEDPATH
# TIFFDIRECTORYLISTING
# TIFFDIR
# PROJECTDIR
# BATCHDIR
# POSTANALYSISDIR
# JPGDIR
# JOBSFILE

# Here we could have a global test or debug variable, that bypasses these requirement-checks if we are in some sort of DEBUG or TEST mode.
${INCLUDEDPATH:?"Need to set INCLUDEDPATH non-empty; INCLUDEDPATH is the path to the current project directory"} &> /dev/null 
${TIFFDIRECTORYLISTING:?"Need to set TIFFDIRECTORYLISTING non-empty. TIFFDIRECTORYLISTING is the list of all TIFF directories found at any depth in the INCLUDEDPATH"} &> /dev/null 
${TIFFDIR:?"Need to set TIFFDIR non-empty. TIFFDIR is the current entry of the list of TIFF directories present in TIFFDIRECTORYLISTING"} &> /dev/null
${PROJECTDIR:?"Need to set PROJECTDIR non-empty. PROJECTDIR is the parent directory of TIFFDIR"} &> /dev/null
${BATCHDIR:?"Need to set BATCHDIR non-empty. BATCHDIR is a BATCH directory next to TIFFDIR"} &> /dev/null
${POSTANALYSISDIR:?"Need to set POSTANALYSISDIR non-empty. POSTANALYSISDIR is a POSTANALYSIS directory next to TIFFDIR"} &> /dev/null
${JPGDIR:?"Need to set JPGDIR non-empty. JPGDIR is a JPG directory next to TIFFDIR"} &> /dev/null
${JOBSFILE:?"Need to set JOBSFILE non-empty. JOBSFILE is a path to a file in ~/logs/temp_bjobs_w_...txt that contains the output of \"bjobs -w\""} &> /dev/null
${PLATEJOBCOUNT:?"Need to set PLATEJOBCOUNT non-empty. PLATEJOBCOUNT is the number of times PROJECTDIR occurs in the output of \"bjobs -w\""} &> /dev/null

