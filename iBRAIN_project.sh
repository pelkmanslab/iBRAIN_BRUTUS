#! /bin/sh	

INCLUDEDPATH="$1"
PRECLUSTERBACKUPPATH="$2"
PROJECTXMLDIR="$3"
NEWPROJECTXMLOUTPUT="$4"    

# Essential parameter check
${INCLUDEDPATH:?"Need to set INCLUDEDPATH non-empty; INCLUDEDPATH is the path to the current project directory"} &> /dev/null 

echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
echo "<?xml-stylesheet type=\"text/xsl\" href=\"../../project.xsl\"?>"
echo "<project>" 
echo " <project_xml_dir>$PROJECTXMLDIR</project_xml_dir>"
echo " <this_file_name>$NEWPROJECTXMLOUTPUT</this_file_name>"
echo " <now>$(date +"%y%m%d_%H%M%S")</now>"

    
if [ "$INCLUDEDPATH" ] && [ -d $INCLUDEDPATH ]; then


    # to speed up ibrain_project.sh, request full information on all jobs once, store in a file, and grep from there...
    JOBSFILE=~/logs/"temp_bjobs_w_$(date +"%y%m%d_%H%M%S_%N").txt"
    echo "   <!-- gather job information in $JOBSFILE"
 	bjobs -w 1> $JOBSFILE 
    echo "   -->"
    
    # Log includedpath
    echo "   <path>$INCLUDEDPATH</path>"

    
    ### CHECK FOR PROJECT SPECIFIC PRECLUSTER SETTINGS FILE
    # echo "  LOOKING FOR PIPELINE IN ${INCLUDEDPATH}"
    PRECLUSTERSETTINGS=$(~/iBRAIN/searchforpreclusterfile.sh "${INCLUDEDPATH}" " " "${PRECLUSTERBACKUPPATH}")
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
    
    ### GET LIST OF ALL UNDERLYING TIFF FOLDERS
    echo "    <!-- Start searching for TIFF directories"
    if [ "$(echo $INCLUDEDPATH | grep '_DG$')" ]; then
        ### IF THIS IS A _DG PROJECT, ONLY LOOK FOR TIFF DIRECTORIES IN DEFINED DEPTH
    	echo "    DG DIRECTORY DETECTED, ONLY LOOKING FOR TIFF DIRS IN PREDEFINED DEPTHS "	
        TIFFDIRECTORYLISTING=$(find $INCLUDEDPATH -mindepth 2 -maxdepth 2 -type d -name "TIFF")
    else
        ### OTHERWISE WE CAN NOT KNOW THE DEPTH OF THE TIFF DIRECTORIES
        TIFFDIRECTORYLISTING=$(find $INCLUDEDPATH -type d -name "TIFF")
    fi
    echo "    -->"
    
    ### START MAIN LOOP OVER ALL UNDERLYING TIFF FOLDERS
    for tiff in $TIFFDIRECTORYLISTING; do
        echo "    <plate>"
        ### SET MAIN DIRECTORY PARAMETERS
        TIFFDIR=$tiff                
        PROJECTDIR=$(dirname $tiff)
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


        ##################################
        ### ADD LINKS TO ALL THE FILES THAT MAY BE OF INTEREST FOR USERS/BROWSING
        ### (If the xsl can handle multiple files-elements, then each of these files can be linked in it's corresponding sub module code, which would be nicer.
        ###
        echo "     <files>"
        if [ -d $JPGDIR ]; then
            for file in $(find $JPGDIR -maxdepth 1 -type f -name "*PlateOverview.jpg"); do
            echo "     <file type=\"plate_overview_jpg\">$file</file>"  
            done
        fi
        if [ -d $BATCHDIR ]; then
            for file in $(find $BATCHDIR -maxdepth 1 -type f -name "BASICDATA_*.mat"); do
            	echo "     <file type=\"plate_basic_data_mat\">$file</file>"  
            done
        fi
        if [ -d $POSTANALYSISDIR ]; then
            for file in $(find $POSTANALYSISDIR -maxdepth 1 -type f -name "*_plate_overview.pdf"); do
                echo "     <file type=\"plate_overview_pdf\">$file</file>"  
           done
           for file in $(find $POSTANALYSISDIR -maxdepth 1 -type f -name "*_plate_overview.csv"); do
                echo "     <file type=\"plate_overview_csv\">$file</file>"  
           done
        fi
        echo "     </files>"
        ##################################

        
        
        ##################################
        ### START MAIN LOGICS: STAGE 1 ###
	. ./sub/stage_one.sh
        # includes the following steps: 
	# - timeouts
	# - PNG conversion (might be taken out of stage_one.sh)
	# - illumination correction (might be taken out of stage_one.sh)
	# - PreCluster
	# - cpcluster
	# - datafusion & check & cleanup
        ##################################
        


        ######################################
        ### STAGE INDEPENDENT JPG CREATION ###
	. ./sub/create_jpgs.sh             ###
        ######################################        
        
        

        #####################################################################################
        ### START MAIN LOGICS: STAGE 2, i.e. depends on successfull CellProfiler analysis ###

        # SEE IF THERE IS A Measurements_Image_ObjectCount.mat FILE
        OBJECTCOUNTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_Image_ObjectCount.mat" | wc -l)
        
        # if stage 1 is completed, and if there are object count measurements, perform the following checks
        if [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $OBJECTCOUNTCOUNT -gt 0 ]; then

	    . ./sub/score_out_of_focus.sh        
 
            . ./sub/plate_normalization.sh 
 
            . ./sub/get_populationcontext.sh
 
            . ./sub/stitch_segmentation_per_well.sh
  
            . ./sub/create_plate_overview.sh
 
            . ./sub/svm_classification.sh
 
            . ./sub/bin_correction.sh

            . ./sub/cell_tracker.sh

            . ./sub/create_celltype_overview.sh

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


    # I'm not sure if the include of fuse_basic_data.sh should be inside or outside the "plates" xml element.. probably inside
    ##########################
    . ./sub/fuse_basic_data.sh
    ##########################

    echo "   </plates>"
    
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
