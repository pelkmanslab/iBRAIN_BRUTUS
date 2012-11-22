#! /bin/bash	
#
# iBRAIN_project.sh

# set -u # makes unser variables be thrown as error. Might be nice to use this. Now breaks on undeclard input parameters.

#############################################
### INCLUDE IBRAIN CONFIGURATION
if [ ! "$IBRAIN_ROOT" ]; then 
    IBRAIN_ROOT=$(dirname `readlink -m $0`)
    if [ -f $IBRAIN_ROOT/etc/config ]; then
        . $IBRAIN_ROOT/etc/config
    else
        echo "Aborting $(basename $0) (missing configuration at $IBRAIN_ROOT/etc/config)"
        exit 1
    fi
fi
# Assume configuration is set by this point.

# Best case scenario if we stay inside ROOT (thus relative pathnames will work).
if [ -d "$IBRAIN_ROOT" ]; then
    cd $IBRAIN_ROOT
else
    echo "Aborting $(basename $0) ('$IBRAIN_ROOT' folder does not exists)"
    exit 1
fi

#############################################
### SOURCE FUNCTIONS
. $IBRAIN_ROOT/core/functions/execute_ibrain_module.sh


echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
echo "<?xml-stylesheet type=\"text/xsl\" href=\"../../project.xsl\"?>"

INCLUDEDPATH="$1" # a path of the project to analyze
PRECLUSTERBACKUPPATH="$2"
PROJECTXMLDIR="$3"
NEWPROJECTXMLOUTPUT="$4"    

echo "<project>"
echo "<!--"
if [ -d $INCLUDEDPATH ]; then
echo "INCLUDEDPATH=$1 (OK)"
else
echo "INCLUDEDPATH=$1 (NOT OK!)"
fi
if [ -d $PRECLUSTERBACKUPPATH ]; then
echo "PRECLUSTERBACKUPPATH=$2 (OK)"
else
echo "PRECLUSTERBACKUPPATH=$2 (NOT OK!)"
fi
echo "-->"
    
echo " <project_xml_dir>$PROJECTXMLDIR</project_xml_dir>"
echo " <this_file_name>$NEWPROJECTXMLOUTPUT</this_file_name>"
echo " <now>$(date +"%y%m%d_%H%M%S")</now>"

    
if [ "$INCLUDEDPATH" ] && [ -d $INCLUDEDPATH ]; then


    # to speed up ibrain_project.sh, request full information on all jobs once, store in a file, and grep from there...
    JOBSFILE=$IBRAIN_LOG_PATH/"temp_bjobs_w_$(date +"%y%m%d_%H%M%S_%N").txt"
    echo "   <!-- gather job information in $JOBSFILE"
 	bjobs -w 1> $JOBSFILE 
    echo "   -->"
    
    # Log includedpath
    echo "   <path>$INCLUDEDPATH</path>"

    
    ### CHECK FOR PROJECT SPECIFIC PRECLUSTER SETTINGS FILE
    # echo "  LOOKING FOR PIPELINE IN ${INCLUDEDPATH}"
    PRECLUSTERSETTINGS=$($IBRAIN_BIN_PATH/searchforpreclusterfile.sh "${INCLUDEDPATH}" " " "${PRECLUSTERBACKUPPATH}")
    # store this as separate file as well...
    PROJECTPRECLUSTERFILE=$PRECLUSTERSETTINGS
    echo "   <pipeline>$PRECLUSTERSETTINGS</pipeline>"
    
    
    ### CHECKING PATH SPECIFIC JOB COUNT (PENDING AND RUNNING) (Note that this can cause mistakes in jobcount statistics for nested iBRAIN projects)
    # WE CHECK THE PROJECT IN A JOB, SO SUBSTRACT THIS JOB...
    ALLPROJECTJOBCOUNT=$(grep "$INCLUDEDPATH" $JOBSFILE -c)
    echo "<!-- ALLPROJECTJOBCOUNT=$ALLPROJECTJOBCOUNT -->"
    IBRAINPROJECTJOBCOUNT=$(grep "$PROJECTXMLDIR" $JOBSFILE -c)
    echo "<!-- IBRAINPROJECTJOBCOUNT=$IBRAINPROJECTJOBCOUNT-->"    
    PROJECTJOBCOUNT=$(($ALLPROJECTJOBCOUNT - $IBRAINPROJECTJOBCOUNT))
    echo "   <job_count_total>$PROJECTJOBCOUNT</job_count_total>"


    ### INIT PLATES XML ELEMENT
    echo "   <plates>"
    
    ### GET LIST OF ALL UNDERLYING PLATE FOLDERS (e.g. containing TIFF, also see wiki/docs for full definition of a plate folder) 
    echo "    <!-- "
    . ./core/functions/list_plate_folders.sh    
    echo "        Looking for plates inside the project path: $INCLUDEDPATH"
    PLATEDIRECTORYLISTING=$( list_plate_folders "$INCLUDEDPATH" )

    ### START MAIN LOOP OVER ALL UNDERLYING TIFF FOLDERS
    for PLATEFOLDER in $PLATEDIRECTORYLISTING; do
        echo "    <plate>"
        ### SET MAIN DIRECTORY PARAMETERS
        PROJECTDIR="${PLATEFOLDER}"
        TIFFDIR=${PLATEFOLDER}/TIFF/
        BATCHDIR=${PROJECTDIR}/BATCH/
        POSTANALYSISDIR=${PROJECTDIR}/POSTANALYSIS/
        JPGDIR=${PROJECTDIR}/JPG/
        
        echo "     <tiff_dir>$TIFFDIR</tiff_dir>"
        echo "     <plate_dir>$PROJECTDIR</plate_dir>"
        echo "     <batch_dir>$BATCHDIR</batch_dir>"
        echo "     <postanalysis_dir>$POSTANALYSISDIR</postanalysis_dir>"
        echo "     <jpg_dir>$JPGDIR</jpg_dir>"
        echo "     <plate_name>$(basename $PROJECTDIR)</plate_name>"
        
        ### IF WARNINGFLAG=1 DISPLAY FULL DEBUG (PRINTENV) DATA PER TIFF FOLDER
        WARNINGFLAG=0

        ### COUNT JOBNUMBER FOR THIS PARTICULAR PLATE
        PLATEJOBCOUNT=$(grep "${PROJECTDIR}" $JOBSFILE -c)
        # substract one job count if the PROJECTDIR equals the INCLUDEDPATH
        if [ "$(echo $PROJECTDIR | sed 's|/|__|g')" == "$(echo $INCLUDEDPATH | sed 's|/|__|g')" ]; then
        	PLATEJOBCOUNT=$(( $PLATEJOBCOUNT - 1 ))
        fi 
        echo "     <job_count_total>$PLATEJOBCOUNT</job_count_total>"
        
        ###############################################################
        ### CHECK IF ALL CRUCIAL DIRECTORIES ARE WRITABLE BY IBRAIN ###
        if ([ -d $PROJECTDIR ] && [ ! -w $PROJECTDIR ]) || ([ -d $TIFFDIR ] && [ ! -w $TIFFDIR ]) || ([ -d $BATCHDIR ] && [ ! -w $BATCHDIR ]); then
            echo "     <status action=\"iBRAIN\">paused"
            echo "      <message>"
            if [ -d $PROJECTDIR ] && [ ! -w $PROJECTDIR ]; then
        echo "    Paused because the $(basename $PROJECTDIR) directory is not writable by iBRAIN."
            fi
            if [ -d $TIFFDIR ] && [ ! -w $TIFFDIR ]; then
                echo "    Paused because the TIFF directory is not writable by iBRAIN."
            fi
            if [ -d $BATCHDIR ] && [ ! -w $BATCHDIR ]; then
                echo "    Paused because the BATCH directory is not writable by iBRAIN."
            fi
            echo "      </message>"
            echo "       </status>"
            echo "      </plate>"
            continue
        fi
        ###############################################################        

        # let's just create the batch directory, we need this in any case, and I've seen some cases where iBRAIN was behaving strangely because this directory was missing...
        if [ ! -d $BATCHDIR ]; then
            echo "<!-- creating BATCH directory.."
    	    mkdir -p $BATCHDIR
    	    echo "-->"
        fi

        #####################################################################
        ### DATA HANDLING INTEGRATION: includes copying/renaming of files ###
        . ./core/modules/rename_nikon.sh
        #####################################################################


        ############################################
        ### DO TIMEOUTS ON DATA (mainly TIFF)... ###
        . ./core/modules/check_image_set.sh
        ############################################
        

        #################################################################
        ### START STAGE 0: png conversion and illumination correction ###
        if [ -e ${BATCHDIR}/checkimageset.complete ]; then

            # - illumination correction
            . ./core/modules/do_illumination_correction.sh
 
            # - PNG conversion
            . ./core/modules/convert_tiff_to_png.sh

            # add backwards compatibility...
            if [ -e ${PROJECTDIR}/iBRAIN_Stage_1.completed ]; then
                touch ${BATCHDIR}/illuminationcorrection.complete
            fi

        fi
        #################################################################

        # - JPG creation (is of course dependent on the dataset being complete, and is better run after pngconversion)
        if [ -e ${BATCHDIR}/ConvertAllTiff2Png.complete ]; then
            . ./core/modules/create_jpgs.sh
        fi

        ##################################
        ### START MAIN LOGICS: STAGE 1 ###
        if [ -e ${BATCHDIR}/ConvertAllTiff2Png.complete ] && [ -e ${BATCHDIR}/illuminationcorrection.complete ]; then
            . ./core/modules/stage_one.sh
        fi
        # includes the following steps: 
        # - PreCluster
        # - cpcluster
        # - datafusion & check & cleanup
        ##################################
        

        #####################################################################################
        ### START MAIN LOGICS: STAGE 2, i.e. depends on successfull CellProfiler analysis ###

        # SEE IF THERE IS A Measurements_Image_ObjectCount.mat FILE
        OBJECTCOUNTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_Image_ObjectCount.mat" | wc -l)
        
        # if stage 1 is completed, and if there are object count measurements, perform the following checks
        if [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $OBJECTCOUNTCOUNT -gt 0 ]; then

            . ./core/modules/create_out_of_focus_measurement.sh        
 
            . ./core/modules/create_plate_normalization.sh 
 
            . ./core/modules/create_population_context_measurements.sh
 
            . ./core/modules/stitch_segmentation_per_well.sh
  
            . ./core/modules/create_plate_overview.sh
             
            . ./core/modules/do_svm_classification.sh
 
            . ./core/modules/do_bin_correction.sh

            . ./core/modules/do_cell_tracking.sh

            . ./core/modules/create_celltype_overview.sh

        fi # end check if stage 1 has been completed. end of stage 2.
        #####################################################################################        
        
        
        ##########################################
        ### DISPLAY DEBUG IF WARNING FLAG IS 1 ###
        
        if [ $WARNINGFLAG -eq 1 ]; then
            echo " <!--"
            echo $(printenv)
            echo " -->"
        fi
        
        echo "    </plate>"
    done # end loop over TIFF folders


    echo "   </plates>"

    # I'm not sure if the include of fuse_basic_data.sh should be inside or outside the "plates" xml element.. probably inside
    ##########################
    . ./core/modules/fuse_basic_data.sh
    ##########################

    
    # clean up jobsfile
    echo "   <!-- cleaning up jobsfile"
       rm -f $JOBSFILE >& /dev/null
    echo "   -->"
        
else # if [ -d $INCLUDEDPATH ]; then

    # The project directory (INCLUDEDPATH) does not exist, report and exit.
    echo "   <path>$INCLUDEDPATH</path>"
    echo "   <warning type=\"InvalidPath\">$INCLUDEDPATH DOES NOT EXIST</warning>"

fi


echo "  </project>"
echo " "


exit 0;
