#! /bin/bash
#
# fuse_basic_data.sh

# Fuse_basic_data is not a standard module. It is run outside of the plate-loop, and therefore should not check if all plate-wise variables are properly set in parameter_check.sh

MODULEPATH=${BASH_SOURCE}
MODULENAME=$(basename ${BASH_SOURCE} .sh)

function main {

    ##################################
    ### ADD LINKS TO ALL THE PROJECT FILES THAT MAY BE OF INTEREST FOR USERS/BROWSING
    ###
    echo "     <files>"
    for file in $(find "$INCLUDEDPATH" -maxdepth 1 -type f -name "*ADVANCEDDATA*.csv"); do
        echo "     <file type=\"advanced_data_csv\">$file</file>"  
    done
    for file in $(find "$INCLUDEDPATH" -maxdepth 1 -type f -name "*BASICDATA*.csv"); do
        echo "     <file type=\"basic_data_csv\">$file</file>"  
    done
    echo "     </files>"
    ##################################


    ######### Check over all plates if we need to submit fuse basic data
    ### IF FUSEBASICDATAFLAG=1 SUBMIT FUSE_BASIC_DATA PER PROJECT FOLDER
    FUSEBASICDATAFLAG=0
    PROJECTBASICDATAFILE="$INCLUDEDPATH/BASICDATA.mat"   
    for tiff in $TIFFDIRECTORYLISTING; do

        # IF BASICDATA OF CURRENT PLATE IS NEWER THAN THE PROJECT BASICDATA, SET FUSEBASICDATAFLAG TO 1
        # NOTE: FUSE_BASICDATA_V3 FUSES MORE THAN JUST BASICDATA_.MAT, SO ALSO CHECK FOR NEWES MODEL
        # FILES, AND NEWER Measurements_Nuclei_CellType_Overview.mat FILES.

        NEWERBASICDATAFILECOUNT=0
        if [ $FUSEBASICDATAFLAG -eq 0 ]; then  
           if [ -e $PROJECTBASICDATAFILE ]; then
                NEWERBASICDATAFILECOUNT=$(($NEWERBASICDATAFILECOUNT + $(find $BATCHDIR -maxdepth 1 -type f -newer $PROJECTBASICDATAFILE -name "BASICDATA_*.mat" | wc -l)))
                NEWERBASICDATAFILECOUNT=$(($NEWERBASICDATAFILECOUNT + $(find $BATCHDIR -maxdepth 1 -type f -newer $PROJECTBASICDATAFILE -name "ProbModel_Tensor.mat" | wc -l)))
                NEWERBASICDATAFILECOUNT=$(($NEWERBASICDATAFILECOUNT + $(find $BATCHDIR -maxdepth 1 -type f -newer $PROJECTBASICDATAFILE -name "ControlLayout.mat" | wc -l)))
                NEWERBASICDATAFILECOUNT=$(($NEWERBASICDATAFILECOUNT + $(find $BATCHDIR -maxdepth 1 -type f -newer $PROJECTBASICDATAFILE -name "Measurements_Nuclei_CellType_Overview.mat" | wc -l)))                        
                NEWERBASICDATAFILECOUNT=$(($NEWERBASICDATAFILECOUNT + $(find $BATCHDIR -maxdepth 1 -type f -newer $PROJECTBASICDATAFILE -name "OPTIMIZED_INFECTION.mat" | wc -l)))
            else
                NEWERBASICDATAFILECOUNT=$(find $BATCHDIR -type f -name "BASICDATA_*.mat" -o -name "Measurements_Nuclei_CellType_Overview.mat" | wc -l)
            fi
        fi

        if [ $NEWERBASICDATAFILECOUNT -gt 0 ]; then
           FUSEBASICDATAFLAG=1
        fi

     done            

    #######################################################
    ### SUBMIT FUSE_BASIC_DATA IF FUSEBASICDATAFLAG > 0 ###
    SEARCHSTRING="fuse_basic_data_v5('${INCLUDEDPATH}')"
    #FUSEBASICDATAJOBCOUNT=$(($(~/iBRAIN/countjobs.sh $SEARCHSTRING) + 0))
    FUSEBASICDATAJOBCOUNT=$(($(grep $SEARCHSTRING $JOBSFILE -c) + 0))
    if [ ! -w $INCLUDEDPATH ]; then
    	
        echo "     <status action=\"fuse-basic-data\">paused"
        echo "      <message>"
        echo "  NOT SUBMITTING FUSE_BASIC_DATA ON $INCLUDEDPATH, DIRECTORY IS NOT WRITABLE BY iBRAIN"
        echo "      </message>"
        echo "     </status>"              	
    	

    else
        if [ $FUSEBASICDATAFLAG -gt 0 ]; then

            if [ ! -e $INCLUDEDPATH/FuseBasicData.submitted ] && [ $FUSEBASICDATAJOBCOUNT -eq 0 ]; then

                echo "     <status action=\"fuse-basic-data\">cleaning-up"
                #echo "      <message>"
                #echo "  CLEANING UP OLD FUSE_BASIC_DATA RESULT FILES IN $INCLUDEDPATH"
                #echo "      </message>"
                echo "      <output>"                    
                find $INCLUDEDPATH -maxdepth 1 -type f -cmin +120 -name "FuseBasicData_*.results" -exec rm {} \;
                echo "      </output>"                    
                echo "     </status>"               

                echo "     <status action=\"fuse-basic-data\">submitting"
                #echo "      <message>"
                #echo "  SUBMITTING FUSE_BASIC_DATA ON $INCLUDEDPATH"
                #echo "      </message>"
                echo "      <output>"                    
                #echo "  FOUND $FUSEBASICDATAFLAG BASICDATA FILES NEWER THAN $PROJECTBASICDATAFILE"      
                bsub -W 8:00 -o "$INCLUDEDPATH/FuseBasicData_$(date +"%y%m%d%H%M%S").results" "matlab -singleCompThread -nodisplay -nojvm << M_PROG
fuse_basic_data_v5('${INCLUDEDPATH}');
check_dg_plate_correlations('${INCLUDEDPATH}');
M_PROG"
                touch $INCLUDEDPATH/FuseBasicData.submitted
                echo "      </output>"                    
                echo "     </status>"                    	

            elif [ -e $INCLUDEDPATH/FuseBasicData.submitted ] && [ $FUSEBASICDATAJOBCOUNT -gt 0 ]; then

                echo "     <status action=\"fuse-basic-data\">waiting"
                #echo "      <message>"
                #echo "  WAITING FOR FUSE_BASIC_DATA TO FINISH"
                #echo "      </message>"
                echo "     </status>"               
                
            elif [ -e $INCLUDEDPATH/FuseBasicData.submitted ] && [ $FUSEBASICDATAJOBCOUNT -eq 0 ]; then

                echo "     <status action=\"fuse-basic-data\">resetting"
                echo "      <message>"
                echo "RESETTING FUSE_BASIC_DATA: $FUSEBASICDATAFLAG ARE AWAITING FUSION, AND THERE IS NO FUSION JOB PENDING"
                echo "      </message>"
                echo "      <output>"                    
                rm -v $INCLUDEDPATH/FuseBasicData.submitted
                echo "      </output>"                    
                echo "     </status>"
                
            fi
        fi
    fi

}

# run standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main
