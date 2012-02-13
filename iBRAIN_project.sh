#! /bin/sh
#
# iBRAIN_project.sh
echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
echo "<?xml-stylesheet type=\"text/xsl\" href=\"../../project.xsl\"?>"

INCLUDEDPATH="$1"
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
    JOBSFILE=~/logs/"temp_bjobs_w_$(date +"%y%m%d_%H%M%S_%N").txt"
    echo "   <!-- gather job information in $JOBSFILE"
 	bjobs -w 1> $JOBSFILE 
    echo "   -->"
    
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
    
    ### CHECK IF DIRECTORY HAS BEEN CHANGED IN THE LAST 21 DAYS, AND IF IT IS PART OF A DRUGGABLE GENOME SCREEN
    ### IF NOT PART OF A "_DG" SCREEN, THAN TIME-OUTS DO NOT APPLY! 
    SEARCHDIR=$(dirname $INCLUDEDPATH)
    SEARCHTARGET=$(basename $INCLUDEDPATH)

    echo "   <path>$INCLUDEDPATH</path>"
             
    
    ### CHECK FOR PROJECT SPECIFIC PRECLUSTER SETTINGS FILE
    # echo "  LOOKING FOR PIPELINE IN ${INCLUDEDPATH}"
    PRECLUSTERSETTINGS=$(~/iBRAIN/searchforpreclusterfile.sh "${INCLUDEDPATH}" " " "${PRECLUSTERBACKUPPATH}")
   
    # store this as separate file as well...
    PROJECTPRECLUSTERFILE=$PRECLUSTERSETTINGS
    
    
    
    echo "   <pipeline>$PRECLUSTERSETTINGS</pipeline>"
    
    
    ### CHECKING PATH SPECIFIC JOB COUNT (PENDING AND RUNNING)
    #PROJECTJOBCOUNT=$(~/iBRAIN/countjobs.sh $INCLUDEDPATH)
    PROJECTJOBCOUNT=$(grep "${INCLUDEDPATH}" $JOBSFILE -c)
    
    ### WE CHECK THE PROJECT IN A JOB, SO SUBSTRACT THIS JOB...
    ALLPROJECTJOBCOUNT=$(grep "$INCLUDEDPATH" $JOBSFILE -c)
    echo "<!-- ALLPROJECTJOBCOUNT=$ALLPROJECTJOBCOUNT -->"
    IBRAINPROJECTJOBCOUNT=$(grep "$PROJECTXMLDIR" $JOBSFILE -c)
    echo "<!-- IBRAINPROJECTJOBCOUNT=$IBRAINPROJECTJOBCOUNT-->"    
    PROJECTJOBCOUNT=$(($ALLPROJECTJOBCOUNT - $IBRAINPROJECTJOBCOUNT))
    
    #PROJECTJOBCOUNT=$(($PROJECTJOBCOUNT - 1))
    # echo "   <job_count_total>$PROJECTJOBCOUNT</job_count_total>"
    
    ### IF FUSEBASICDATAFLAG=1 SUBMIT FUSE_BASIC_DATA PER PROJECT FOLDER
    FUSEBASICDATAFLAG=0
    PROJECTBASICDATAFILE="$INCLUDEDPATH/BASICDATA.mat"
    
    ### START MAIN LOOP OVER ALL UNDERLYING TIFF FOLDERS
    echo "   <plates>"
    
    ### IF THIS IS A _DG PROJECT, ONLY LOOK FOR TIFF DIRECTORIES IN DEFINED DEPTH
    echo "    <!-- Start searching for TIFF directories"
    if [ "$(echo $INCLUDEDPATH | grep '_DG$')" ]; then
    	echo "    DG DIRECTORY DETECTED, ONLY LOOKING FOR TIFF DIRS IN PREDEFINED DEPTHS "	
        TIFFDIRECTORYLISTING=$(find $INCLUDEDPATH -mindepth 2 -maxdepth 2 -type d -name "TIFF")
        
    else
    ### OTHERWISE WE CAN NOT KNOW
        TIFFDIRECTORYLISTING=$(find $INCLUDEDPATH -type d -name "TIFF")
    fi
    echo "    -->"
    
    ### CONVERT FOLDER STRUCTURE TO iBRAIN FORMAT
    if [ ! -e $PROJECTDIR/iBRAIN_Stage_0.completed ]; then
        $()
    fi

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
        
        
        ### IF WARNINGFLAG=1 DISPLAY FULL DEBUG DATA PER TIFF FOLDER
        WARNINGFLAG=0

        ### COUNT JOBNUMBER FOR THIS PARTICULAR PLATE
        PLATEJOBCOUNT=$(grep "${PROJECTDIR}" $JOBSFILE -c)
        # substract one job count if the PROJECTDIR equals the INCLUDEDPATH
        if [ "$(echo $PROJECTDIR | sed 's|/|__|g')" == "$(echo $INCLUDEDPATH | sed 's|/|__|g')" ]; then
        	PLATEJOBCOUNT=$(( $PLATEJOBCOUNT - 1 ))
        fi 
        
        ### CHECK FOR PLATE SPECIFIC PRECLUSTER SETTINGS FILE
	    # echo "  LOOKING FOR PIPELINE IN ${INCLUDEDPATH}"
	    #PLATEPRECLUSTERSETTINGS=$(~/iBRAIN/searchforpreclusterfile.sh "${PROJECTDIR}" "$PRECLUSTERSETTINGS" "${PRECLUSTERBACKUPPATH}")
	    
	    # By defauls a plate will be analyzed by the project-wide PreCluster_*.mat file. 
	    # However, if there is a plate-specific PreCluster_*.mat file, this overrules the the project-wide file.
	    
	    # set by default to project wide precluster file 
	    PLATEPRECLUSTERSETTINGS="$PRECLUSTERSETTINGS"
	    # then look for plate settings files, if present, use this. All precluster.sh calls should use $PLATEPRECLUSTERSETTINGS
        for FOUNDSETTINGSFILE in `find $PROJECTDIR -maxdepth 1 -type f -iname 'PreCluster*.mat'`
        do
            PLATEPRECLUSTERSETTINGS="$FOUNDSETTINGSFILE"
        done	    
	    
	    echo "   <pipeline>$PLATEPRECLUSTERSETTINGS</pipeline>"

        
        # CHECK IF IMAGE SET IS COMPLETE
        COMPLETEFILECHECK=$(find $TIFFDIR -maxdepth 1 -type f -name "CheckImageSet_*.complete" | wc -l)
        TIFFDIRLASTMODIFIED=$(find $PROJECTDIR -maxdepth 1 -type d -mmin +30 -name "TIFF" | wc -l)
        
        
        echo "<!-- COMPLETEFILECHECK=$COMPLETEFILECHECK -->"
        echo "<!-- TIFFDIRLASTMODIFIED=$TIFFDIRLASTMODIFIED -->"

        # PNG CONVERSION (ConvertAllTiff2Png)
        if [ $COMPLETEFILECHECK -eq 0 ]; then
            TIFFCOUNT=$(find $TIFFDIR -maxdepth 1 -type f -iname "*.tif" -o -maxdepth 1 -type f -name "*.png" | wc -l)
            echo "<!-- TIFFCOUNT=$TIFFCOUNT -->"
        fi
        
        
        ###############################################################
        ### CHECK IF ALL CRUCIAL DIRECTORIES ARE WRITABLE BY IBRAIN ###
            if ([ -d $PROJECTDIR ] && [ ! -w $PROJECTDIR ]) || ([ -d $TIFFDIR ] && [ ! -w $TIFFDIR ]) || ([ -d $BATCHDIR ] && [ ! -w $BATCHDIR ]); then
            	echo "     <status action=\"iBRAIN\">paused"        
                if [ -d $PROJECTDIR ] && [ ! -w $PROJECTDIR ]; then
		            echo "      <message>"
		            echo "    Paused because the $(basename $PROJECTDIR) directory is not writable by iBRAIN."
		            echo "      </message>"
                fi                    
                if [ -d $TIFFDIR ] && [ ! -w $TIFFDIR ]; then
                    echo "      <message>"
                    echo "    Paused because the TIFF directory is not writable by iBRAIN."
                    echo "      </message>"
                fi
                if [ -d $BATCHDIR ] && [ ! -w $BATCHDIR ]; then
                    echo "      <message>"
                    echo "    Paused because the BATCH directory is not writable by iBRAIN."
                    echo "      </message>"
                fi
                echo "       </status>"
                echo "      </plate>"            
                continue
            fi
        ###############################################################        
        
        # init to false/zero in case batch dir is not present
        COMPLETEDPNGCONVERSIONCHECK=0
        COMPLETEDILLCORMEASUREMENTCHECK=0        

        # let's just create the batch directory, we need this in any case, and I've seen some cases where iBRAIN was behaving strangely because this directory was missing...
        if [ ! -d $BATCHDIR ]; then
        	echo "<!-- creating BATCH directory.."
    		mkdir -p $BATCHDIR
    		echo "-->"
        fi
        
        if [ -d $BATCHDIR ]; then 
            
            ### CHECK THE STATUS OF THE INITIAL ANALYSIS STEPS 
            ### (PreCluster/CPCluster/DataFusion/DataFusionCheckAndCleanup)
            
            # TIFF 2 PNG CONVERSION
            COMPLETEDPNGCONVERSIONCHECK=$(find $BATCHDIR -maxdepth 1 -type f -name "ConvertAllTiff2Png.complete" | wc -l)
            CONVERTALLTIFF2PNGRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "ConvertAllTiff2Png_*.results" | wc -l)
            
            # ILLUMINATION CORRECTION MEASUREMENTS
            COMPLETEDILLCORMEASUREMENTCHECK=$(find $BATCHDIR -maxdepth 1 -type f -name "IllCorMeasurement.complete" | wc -l)
            ILLCORMEASUREMENTRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "IllCorMeasurement_*.results" | wc -l)

            # PRECLUSTER
            PRECLUSTERCHECK=$(find $BATCHDIR -maxdepth 1 -type f -name "PreCluster_*.results" | wc -l)

            
            CPCLUSTERRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Batch_*.results" | wc -l)            
            BATCHJOBCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Batch_*.txt" | wc -l)
            echo "     <total_batch_job_count>$BATCHJOBCOUNT</total_batch_job_count>"
            OUTPUTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Batch_*_OUT.mat" | wc -l)
            echo "     <completed_batch_job_count>$OUTPUTCOUNT</completed_batch_job_count>"                

            #################### BATCHDIR CLEANUP #################### 
            # Some projects are big, let's delete all Batch_*_to_*.mat, Batch_*_to_*.txt & Batch_*_to_*.results files
            if [ $OUTPUTCOUNT -gt 1 ] && [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then
            	echo "<!-- cleaning up BATCH directory a bit..."
				rm -f $BATCHDIR/Batch_*_to_*.mat
				rm -f $BATCHDIR/Batch_*_to_*.txt
				rm -f $BATCHDIR/Batch_*_to_*.results
            	echo "-->"
            fi
            ################ END OF BATCHDIR CLEANUP ################


            
            # DATAFUSION  
            DATAFUSIONRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_*.mat" | wc -l)
            EXPECTEDMEASUREMENTS=$(find $BATCHDIR -maxdepth 1 -type f -name "Batch_2_to_*_Measurements_*.mat" | wc -l)
            
            #################### TEMPORARY BUGFIX ################### 
            # WE'VE HAD A BUG IN IBRAIN WHERE DATAFUSIONCHECKANDCLEANUP COULD TIMEOUT, AND IBRAIN WOULD JUST CONTINUE... CHECK WHICH PLATES 
            # STILL HAVE BATCH MEASUREMENTS EVEN THOUGH THEY ARE "STAGE-1 COMPLETED"...
            if [ $EXPECTEDMEASUREMENTS -gt 0 ] && [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then
            	echo "<!-- TEMPORARY BUG FIXING... SUBMITTING submitdatafusioncheckandcleanup TO CLEAN UP BATCH DIR!" 
					./iBRAIN/submitdatafusioncheckandcleanup.sh $BATCHDIR            	
            	echo "-->"
            fi
            ################ END OF TEMPORARY BUGFIX ################
            
            #DATAFUSION CHECK AND CLEANUP
            FAILEDDATACHECKRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_*.datacheck-*"| wc -l)
            DATAFUSIONCHECKRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "DataFusionCheckAndCleanup_*.results" | wc -l)
            
            ### CHECK THE STATUS OF THE ADVANCED ANALYSIS STEPS 
            ### (InfectionScoring/CheckOutOfFocus)
            
            # INFECTION SCORING
            INFECTIONCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "*Measurements_*Infection*.mat" | wc -l)
            INFECTIONRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "InfectionScoring_*.results" | wc -l)
            
            # SEE IF THERE IS A Measurements_Image_ObjectCount.mat FILE
            OBJECTCOUNTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_Image_ObjectCount.mat" | wc -l)
            
            # OUT OF FOCUS SCORING
            OUTOFFOCUSCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "*Measurements_*OutOfFocus.mat" | wc -l)
            OUTOFFOCUSRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "CheckOutOfFocus_*.results" | wc -l)
            
            # PLATE OVERVIEW GENERATION
            if [ -d $POSTANALYSISDIR ]; then
                PLATEOVERVIEWCOUNT=$(find $POSTANALYSISDIR -maxdepth 1 -type f -name "*_plate_overview.*" | wc -l)
            else
                PLATEOVERVIEWCOUNT=0
            fi
            PLATEOVERVIEWRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "CreatePlateOverview_*.results" | wc -l)
            
            PLATEBASICDATACOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "BASICDATA_*.mat" | wc -l)
            
            # PLATE NORMALIZATION
            NORMALIZATIONCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_Mean_Std.mat" | wc -l)
            NORMALIZATIONRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "MeasurementsMeanStd_*.results" | wc -l)

            # PLATE NORMALIZATION
            # NORMALIZATIONCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_Mean_Std.mat" | wc -l)
            LCDCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_Nuclei_LocalCellDensity.mat" | wc -l)
            LCDRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "getLocalCellDensityPerWell_auto_*.results" | wc -l)

            # to avoid double listing of settings files if $INCLUDEDPATH and $PROJECTDIR are the same... 
        	if [ $INCLUDEDPATH -ef $PROJECTDIR ]; then
	            # SVM CLASSIFICATION
	            SVMSETTINGSFILE=$(find $PROJECTDIR -maxdepth 1 -type f -name "SVM_*.mat" | wc -l)
	            # BIN-CORRECTION
	            BINSETTINGSFILE=$(find $PROJECTDIR -maxdepth 1 -type f -name "BIN_*.txt" | wc -l)
	            # TRACKER
	            TRACKERSETTINGSFILE=$(find $PROJECTDIR -maxdepth 1 -type f -name "SetTracker_*.txt" | wc -l)
        	else
	            # SVM CLASSIFICATION
	            SVMSETTINGSFILE=$(find $INCLUDEDPATH $PROJECTDIR -maxdepth 1 -type f -name "SVM_*.mat" | wc -l)
	            # BIN-CORRECTION
	            BINSETTINGSFILE=$(find $INCLUDEDPATH $PROJECTDIR -maxdepth 1 -type f -name "BIN_*.txt" | wc -l)
	            # TRACKER
	            TRACKERSETTINGSFILE=$(find $INCLUDEDPATH $PROJECTDIR -maxdepth 1 -type f -name "SetTracker_*.txt" | wc -l)
        	fi
                    
            # IF BASICDATA OF CURRENT PLATE IS NEWER THAN THE PROJECT BASICDATA, SET FUSEBASICDATAFLAG TO 1
            # NOTE: FUSE_BASICDATA_V3 FUSES MORE THAN JUST BASICDATA_.MAT, SO ALSO CHECK FOR NEWES MODEL
            # FILES, AND NEWER Measurements_Nuclei_CellType_Overview.mat FILES.
            #
            # BS, 080829: With fuse_basicdata_v3.m the following files can be put in BASICDATA:
            # BASICDATA_CPxxx-x.mat 
            # ProbModel_TensorCorrectedData.mat
            # ProbModel_Tensor.mat
            # ProbModel_TensorDataPerWell.mat
            # Measurements_Nuclei_CellType_Overview.mat
            # ControlLayout.mat
            # BS, 081103: With fuse_basicdata_v4.m added the following input file OPTIMZIED_INFECTION:                
            NEWERBASICDATAFILECOUNT=0
            if [ $FUSEBASICDATAFLAG -eq 0 ]; then 
                if [ -e $PROJECTBASICDATAFILE ]; then
                    NEWERBASICDATAFILECOUNT=$(($NEWERBASICDATAFILECOUNT + $(find $BATCHDIR -maxdepth 1 -type f -newer $PROJECTBASICDATAFILE -name "BASICDATA_*.mat" | wc -l)))
                    NEWERBASICDATAFILECOUNT=$(($NEWERBASICDATAFILECOUNT + $(find $BATCHDIR -maxdepth 1 -type f -newer $PROJECTBASICDATAFILE -name "ProbModel_Tensor.mat" | wc -l)))
                    NEWERBASICDATAFILECOUNT=$(($NEWERBASICDATAFILECOUNT + $(find $BATCHDIR -maxdepth 1 -type f -newer $PROJECTBASICDATAFILE -name "ControlLayout.mat" | wc -l)))
                    NEWERBASICDATAFILECOUNT=$(($NEWERBASICDATAFILECOUNT + $(find $BATCHDIR -maxdepth 1 -type f -newer $PROJECTBASICDATAFILE -name "Measurements_Nuclei_CellType_Overview.mat" | wc -l)))                        
                    NEWERBASICDATAFILECOUNT=$(($NEWERBASICDATAFILECOUNT + $(find $BATCHDIR -maxdepth 1 -type f -newer $PROJECTBASICDATAFILE -name "OPTIMIZED_INFECTION.mat" | wc -l)))
                else
                    NEWERBASICDATAFILECOUNT=$(find $BATCHDIR -type f -name "BASICDATA_*.mat" -o -name "Measurements_Nuclei_CellType_Overview.mat" -o -name "ProbModel_Tensor.mat" -o -name "ControlLayout.mat" | wc -l)
                fi
            fi
            if [ $NEWERBASICDATAFILECOUNT -gt 0 ]; then
                FUSEBASICDATAFLAG=1
            fi                    
            #FUSEBASICDATAFLAG=$(( $FUSEBASICDATAFLAG + $NEWERBASICDATAFILECOUNT ))
            
            
            
        fi # if [ -d $BATCHDIR ]; then 


        ##################################
        ### ADD LINKS TO ALL THE FILES THAT MAY BE OF INTEREST FOR USERS/BROWSING
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
        
        
        ### CHECK IF IMAGE FOLDER IS COMPLETE
        if [ $COMPLETEFILECHECK -eq 0 ] && [ $TIFFCOUNT -eq 0 ]; then
        	
            echo "     <status action=\"check-image-set\">paused"
            echo "      <message>"
            echo "    Paused because the TIFF directory contains no tif images."
            echo "      </message>"
            echo "     </status>"

        elif [ $COMPLETEFILECHECK -eq 0 ] && [ $TIFFDIRLASTMODIFIED -eq 0 ]; then
            
            echo "     <status action=\"check-image-set\">waiting"
            echo "      <message>"
            echo "    Waiting because the TIFF directory has been modified in the last 30 minutes."
            echo "      </message>"

            echo "      <output>"
            ### [091208 BS] Add a TIMEOUT progress bar!
	        TIMELASTMODIFIED=$(stat -c %Y ibrain_project.sh)
	        TIMENOW=$(date +%s)
	        TIME_DIFF=$(expr $TIMENOW - $TIMELASTMODIFIED) 
	        # calculate as time in seconds since last modified date / 1800 (1800 sec = 30 min)
			PROGRESSBARVALUE=$(echo "scale=2; (${TIME_DIFF} / 1800) * 100;" | bc)
        	if [ "$PROGRESSBARVALUE" ]; then
    			echo "       <progressbar>$PROGRESSBARVALUE</progressbar>"
        	fi
        	echo "TIMELASTMODIFIED=$TIMELASTMODIFIED"
        	echo "TIMENOW=$TIMENOW"
        	echo "TIME_DIFF=$TIME_DIFF"
            echo "      </output>"                    
            
            
            
            echo "     </status>"
        
        #elif [ $COMPLETEFILECHECK -eq 0 ] && [ $TIFFDIRLASTMODIFIED -eq 1 ]; then
        elif [ $COMPLETEFILECHECK -eq 0 ] && [ ! -e $BATCHDIR/ConvertAllTiff2Png.complete ]; then
        

            TOUCHOUTPUT=$(touch $TIFFDIR/CheckImageSet_${TIFFCOUNT}.complete 2>&1)
            
            if [ ! -e $TIFFDIR/CheckImageSet_${TIFFCOUNT}.complete ]; then

                echo "     <status action=\"check-image-set\">failed"
                echo "      <warning>"
                echo "       check-image-set FAILED: CAN NOT WRITE TO TIFF DIRECTORY!"
                echo "      </warning>"
                echo "       <output>"     
                echo "$TOUCHOUTPUT"
                echo "       </output>"
                echo "     </status>"                         
            else
                echo "     <status action=\"check-image-set\">submitting"
                echo "      <message>"
                echo "    TIFF directory has passed waiting fase. Creating BATCH directory and starting iBRAIN analysis."
                echo "      </message>"
                echo "      <output>"
                echo "$TOUCHOUTPUT"                    
                if [ ! -e $BATCHDIR ]; then
                    mkdir -p $BATCHDIR
                fi
                if [ ! -d $POSTANALYSISDIR ]; then
                    mkdir -p $POSTANALYSISDIR
                fi
                echo "      </output>"                  
                echo "     </status>"
            fi
            

        elif [ ! $COMPLETEFILECHECK -eq 0 ] && [ $COMPLETEDPNGCONVERSIONCHECK -eq 0 ] && [ $COMPLETEDILLCORMEASUREMENTCHECK -eq 0 ]; then
            
            ### AT THE START OF IBRAIN, DO A PNG CONVERSION OF ALL TIF FILES IN THE TIFF DIRECTORY. 
            # ONLY IF THIS TIFF CONVERSION IS DONE, CREATE THE ConvertAllTiff2Png.complete FILE
            # FURTHER ANALYSIS AND THE JPG CREATION DEPENDS ON THIS FILE
        
            ###
            ### CONVERT ALL TIFF TO PNG
            ###
            
            TIFFCOUNT=$(find $TIFFDIR -maxdepth 1 -type f -iname "*.tif" | wc -l)
            PNGCOUNT=$(find $TIFFDIR -maxdepth 1 -type f -iname "*.png" | wc -l)

            # it's important to have an up to date conversion job count
            #TIFF2PNGCONVERSIONJOBS=$(grep "convert_all_tiff2png" $JOBSFILE -c)	 
            SEARCHSTRING="convert_all_tiff2png(${TIFFDIR})"
            TIFF2PNGCONVERSIONJOBSPERPLATE=$(($(grep $SEARCHSTRING $JOBSFILE -c) + 0))
			TIFF2PNGCONVERSIONJOBS=$(~/iBRAIN/countjobs.sh "convert_all_tiff2png")
			
            ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT SUBMIT MEASUREMENTS_MEAN_STD
            
            if [ ! -e $PROJECTDIR/ConvertAllTiff2Png.submitted ]; then
                 
                if [ $TIFFCOUNT -gt 0 ] && [ $TIFF2PNGCONVERSIONJOBS -lt 15 ] && [ $TIFF2PNGCONVERSIONJOBSPERPLATE -eq 0 ]; then
                    
                    echo "     <status action=\"convert-all-tiff-2-png\">submitting"
                    echo "      <output>"

                    # create batch files for png conversion (and clean up previous ones if present?)
                    
                    # clean up old batch png conversion files
                    rm -f ${BATCHDIR}batch_png_convert_*
                    # create new batch png conversion files, with 3000 files per batch job
                	find ${TIFFDIR} -maxdepth 1 -type f -name *.tif | split -a 3 -l 3000 -d - ${BATCHDIR}batch_png_convert_
					# loop over files and submit jobs                    
                    for BATCHPNGCONVERTFILE in $( find $BATCHDIR -maxdepth 1 -type f -name batch_png_convert_*  ); do
                    	PNGRESULTFILE="ConvertAllTiff2Png_$(basename ${BATCHPNGCONVERTFILE})_$(date +"%y%m%d%H%M%S").results"
bsub -W 8:00 -o "${BATCHDIR}$PNGRESULTFILE" << M_PROG
~/iBRAIN/batchpngconversion.sh ${BATCHPNGCONVERTFILE}
#mogrify -depth 16 -type Grayscale -format png *.tif && rm *.tif
echo "${SEARCHSTRING}"
M_PROG
                    done

                    touch $PROJECTDIR/ConvertAllTiff2Png.submitted
                    echo "      </output>"                    
                    echo "     </status>"                           

                elif [ $TIFFCOUNT -gt 0 ] && [ $TIFF2PNGCONVERSIONJOBS -gt 14 ] && [ $TIFF2PNGCONVERSIONJOBSPERPLATE -eq 0 ]; then

                    echo "     <status action=\"convert-all-tiff-2-png\">waiting"
                    echo "      <message>"
                    echo "    not yet submitting plate tiff to png conversion, too many jobs of this kind present. waiting for some jobs to finish."
                    echo "    TIFF2PNGCONVERSIONJOBS = $TIFF2PNGCONVERSIONJOBS"
                    echo "    TIFF2PNGCONVERSIONJOBSPERPLATE = $TIFF2PNGCONVERSIONJOBSPERPLATE"
                    echo "    TIFFCOUNT = $TIFFCOUNT"
                    echo "    PNGCOUNT = $PNGCOUNT"
                    echo "      </message>"
                    echo "     </status>"   

                elif [ $TIFFCOUNT -eq 0 ] && [ $PNGCOUNT -gt 0 ]; then

                    echo "     <status action=\"convert-all-tiff-2-png\">waiting"
                    echo "      <message>"
                    echo "    No TIFF files found, png files are present, and ConvertAllTiff2Png.submitted was missing, creating ConvertAllTiff2Png.submitted and ConvertAllTiff2Png.complete"
                    echo "    TIFF2PNGCONVERSIONJOBSPERPLATE = $TIFF2PNGCONVERSIONJOBSPERPLATE"
                    echo "    TIFF2PNGCONVERSIONJOBS = $TIFF2PNGCONVERSIONJOBS"
                    echo "    TIFFCOUNT = $TIFFCOUNT"
                    echo "    PNGCOUNT = $PNGCOUNT"
                    echo "      </message>"
                    echo "      <output>"
                    touch $PROJECTDIR/ConvertAllTiff2Png.submitted
                    # just make sure BATCH is present... people might delete it
                    if [ ! -e $BATCHDIR ]; then
                        mkdir -p $BATCHDIR
                    fi
                    touch $BATCHDIR/ConvertAllTiff2Png.complete
                    echo "      </output>"                    
                    echo "     </status>"                           
            
				elif [ $TIFF2PNGCONVERSIONJOBSPERPLATE -eq 0 ]; then
				
                    echo "     <status action=\"convert-all-tiff-2-png\">waiting"
                    echo "      <message>"
                    echo "    Jobs still running but and ConvertAllTiff2Png.submitted was missing, creating ConvertAllTiff2Png.submitted"
                    echo "      </message>"
                    echo "      <output>"
                    touch $PROJECTDIR/ConvertAllTiff2Png.submitted
                    # just make sure BATCH is present... people might delete it
                    if [ ! -e $BATCHDIR ]; then
                        mkdir -p $BATCHDIR
                    fi
                    echo "      </output>"                    
                    echo "     </status>" 
                    			
	            else
	                
	                echo "     <status action=\"convert-all-tiff-2-png\">unknown"
	                echo "      <warning>"
	                echo "  UNKNOWN STATUS FOR convert-all-tiff-2-png ACTION"
	                if [ -e $BATCHDIR/ConvertAllTiff2Png.complete ]; then
	                echo "    ConvertAllTiff2Png.complete IS PRESENT"
	                else
	                echo "    ConvertAllTiff2Png.complete IS NOT PRESENT"	
	                fi
	                echo "    TIFFCOUNT=$TIFFCOUNT"
	                echo "    PNGCOUNT=$PNGCOUNT"
	                echo "    TIFF2PNGCONVERSIONJOBS = $TIFF2PNGCONVERSIONJOBS"                
	                echo "    CONVERTALLTIFF2PNGRESULTCOUNT=$CONVERTALLTIFF2PNGRESULTCOUNT"
	                echo "    TIFF2PNGCONVERSIONJOBSPERPLATE = $TIFF2PNGCONVERSIONJOBSPERPLATE"                
	                echo "      </warning>"                                        
	                echo "     </status>" 
	            fi
                
            ### PLATE NORMALIZATION HAS BEEN SUBMITTED BUT DID NOT PRODUCE OUTPUT FILES YET
            elif [ -e $PROJECTDIR/ConvertAllTiff2Png.submitted ] && [ $CONVERTALLTIFF2PNGRESULTCOUNT -lt 1 ]; then
                
                echo "     <status action=\"convert-all-tiff-2-png\">waiting"
                #echo "      <message>"
                #echo "    PROCESSING: waiting for tiff-2-png conversion to finish"
                #echo "      </message>"
                echo "      <output>"                    
                ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
                if [ $PLATEJOBCOUNT -eq 0 ]; then
                    echo "    ALERT: iBRAIN IS WAITING FOR PNG CONVERSION, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                    rm -f $PROJECTDIR/ConvertAllTiff2Png.submitted
                fi
                
                ### [091208 BS] Add a PNG conversion progress bar!
                
                # This progress bar logic holds for MATLAB based conversion
				PROGRESSBARVALUE=$(echo "scale=2; (${PNGCOUNT} / (${TIFFCOUNT} + ${PNGCOUNT})) * 100;" | bc)
				
				# This progress bar logic holds for Imagemagick based conversion
				# PROGRESSBARVALUE=$(echo "scale=2; (${PNGCOUNT} / (${TIFFCOUNT})) * 100;" | bc)
            	if [ "$PROGRESSBARVALUE" ]; then
        			echo "       <progressbar>$PROGRESSBARVALUE</progressbar>"
            	fi
                
                echo "      </output>"                    
                echo "     </status>"  
                

				elif [ $TIFFCOUNT -gt 0 ] && [ -e $PROJECTDIR/ConvertAllTiff2Png.submitted ] && [ $CONVERTALLTIFF2PNGRESULTCOUNT -gt 0 ] && [ $TIFF2PNGCONVERSIONJOBSPERPLATE -gt 0 ]; then
 
                echo "     <status action=\"convert-all-tiff-2-png\">waiting"
                echo "      <message>"
                echo "    PROCESSING: waiting for tiff-2-png conversion to finish"
                echo "      </message>"
                echo "      <output>"                    
                ### [091208 BS] Add a PNG conversion progress bar!
				PROGRESSBARVALUE=$(echo "scale=2; (${PNGCOUNT} / (${TIFFCOUNT} + ${PNGCOUNT})) * 100;" | bc)
				# PROGRESSBARVALUE=$(echo "scale=2; (${PNGCOUNT} / (${TIFFCOUNT})) * 100;" | bc)
            	if [ "$PROGRESSBARVALUE" ]; then
        			echo "       <progressbar>$PROGRESSBARVALUE</progressbar>"
            	fi
                echo "    TIFF2PNGCONVERSIONJOBSPERPLATE = $TIFF2PNGCONVERSIONJOBSPERPLATE"            	
                echo "      </output>"                    
                echo "     </status>" 
                
            ### PLATE NORMALIZATION HAS BEEN COMPLETED BUT FAILED TO REMOVE ALL TIFF FILES
            elif [ $TIFFCOUNT -gt 0 ] && [ -e $PROJECTDIR/ConvertAllTiff2Png.submitted ] && [ $CONVERTALLTIFF2PNGRESULTCOUNT -gt 0 ] && [ $TIFF2PNGCONVERSIONJOBSPERPLATE -eq 0 ]; then
                
                echo "     <status action=\"convert-all-tiff-2-png\">failed"
                echo "      <warning>"
                echo "    convert-all-tiff-2-png FAILED"
                echo "      </warning>"
                echo "      <output>"  
                if [ -e $BATCHDIR/ConvertAllTiff2Png.complete ]; then
                echo "    ConvertAllTiff2Png.complete IS PRESENT"
                else
                echo "    ConvertAllTiff2Png.complete IS NOT PRESENT"   
                fi	                
                echo "    TIFFCOUNT=$TIFFCOUNT"
                echo "    PNGCOUNT=$PNGCOUNT"
                echo "    CONVERTALLTIFF2PNGRESULTCOUNT=$CONVERTALLTIFF2PNGRESULTCOUNT"
                echo "    TIFF2PNGCONVERSIONJOBSPERPLATE = $TIFF2PNGCONVERSIONJOBSPERPLATE"	                                  
                ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
                ERRORCHECKOUTPUT=$(~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "ConvertAllTiff2Png_" $PROJECTDIR/ConvertAllTiff2Png.submitted)
                echo " ${ERRORCHECKOUTPUT}"	                
                #ERRORCHECKOUTPUTTIMEOUTCOUNT=$(grep "${ERRORCHECKOUTPUT}" "Job exceeded runlimit" -c)
                if [ $(echo "$ERRORCHECKOUTPUT" | grep "no known or unknown errors were found" -c) -gt 0 ]; then
                	echo " [BS, EXPERIMENTAL] NO ERRORS FOUND IN RESULT FILE: RESETTING PNG CONVERSION JOB"
                	rm -v $PROJECTDIR/ConvertAllTiff2Png.submitted
                elif [ $(echo "$ERRORCHECKOUTPUT" | grep "Job exceeded runlimit" -c) -gt 0 ]; then
                    echo " [BS, EXPERIMENTAL] NO ERROR FOUND IN RESULT FILE: RESETTING PNG CONVERSION JOB"
                    rm -v $PROJECTDIR/ConvertAllTiff2Png.submitted
                fi
                echo "      </output>"                   
                echo "     </status>"                         


            ### IF PLATE NORMALIZATION FILE IS PRESENT, FLAG AS COMPLETED
            elif [ $TIFFCOUNT -eq 0 ] && [ $PNGCOUNT -gt 0 ] && [ $TIFFDIRLASTMODIFIED -eq 0 ]; then
                
                echo "     <status action=\"convert-all-tiff-2-png\">waiting"
                echo "      <message>"
                echo "    COMPLETED: png conversion is complete. waiting for second timeout"
                echo "      </message>"
                echo "      <output>"                    
                ### create   
                touch $BATCHDIR/ConvertAllTiff2Png.complete
                echo "      </output>"                  	                
                echo "     </status>"

            elif [ $TIFFCOUNT -eq 0 ] && [ $PNGCOUNT -gt 0 ] && [ $TIFFDIRLASTMODIFIED -eq 1 ]; then
                
                echo "     <status action=\"convert-all-tiff-2-png\">completed, waiting"
                #echo "      <message>"
                #echo "    COMPLETED: plate normalization"
                #echo "      </message>"
                echo "      <output>"                    
                ### create   
                touch $BATCHDIR/ConvertAllTiff2Png.complete
                echo "      </output>"                                      
                echo "     </status>"

            elif [ $TIFFCOUNT -gt 0 ] && [ $PNGCOUNT -gt 0 ] && [ $TIFFDIRLASTMODIFIED -eq 1 ]; then
                
                echo "     <status action=\"convert-all-tiff-2-png\">resetting"
                echo "      <message>"
                echo "    Finished waiting for the second timeout after png conversion, but new tif files were found, resetting pngconversion."
                echo "      </message>"
                echo "      <output>"                    
                rm -v $BATCHDIR/ConvertAllTiff2Png.complete
                rm -v $PROJECTDIR/ConvertAllTiff2Png.submitted
                echo "      </output>"                                      
                echo "     </status>"

            else
                
                echo "     <status action=\"convert-all-tiff-2-png\">unknown"
                echo "      <warning>"
                echo "  UNKNOWN STATUS FOR convert-all-tiff-2-png ACTION"
                if [ -e $BATCHDIR/ConvertAllTiff2Png.complete ]; then
                echo "    ConvertAllTiff2Png.complete IS PRESENT"
                else
                echo "    ConvertAllTiff2Png.complete IS NOT PRESENT"	
                fi
                echo "    TIFFCOUNT=$TIFFCOUNT"
                echo "    PNGCOUNT=$PNGCOUNT"
                echo "    CONVERTALLTIFF2PNGRESULTCOUNT=$CONVERTALLTIFF2PNGRESULTCOUNT"
                echo "    TIFF2PNGCONVERSIONJOBSPERPLATE = $TIFF2PNGCONVERSIONJOBSPERPLATE"                
                echo "      </warning>"                                        
                echo "     </status>"                     
                	                
            fi                
            
            
            
        ###
        ### ILLUMINATION CORRECTION MEASUREMENTS
        ###
        
        ### variables:

        ### IF ALL EXPECTED I.C. MEASUREMENTS ARE PRESENT SUBMIT ILL_COR_MEASUREMENTS
        #
        #
        if [ ! -e $PROJECTDIR/IllCorMeasurement.submitted ]; then

            currentjobcount=$(~/iBRAIN/countjobs.sh "Ill_Cor_Measurement_iBRAIN")
                         
            if [ $currentjobcount -lt 1 ]; then
            	
                echo "     <status action=\"illumination-correction\">submitting"
                #echo "      <message>"
                #echo "    PROCESSING: submitting illumination correction measurement"
                #echo "      </message>"
                echo "      <output>"
                ~/iBRAIN/illcormeasurement.sh $TIFFDIR
                touch $PROJECTDIR/IllCorMeasurement.submitted
                echo "      </output>"                    
                echo "     </status>"                        	

            else
            
                echo "     <status action=\"illumination-correction\">waiting"
                #echo "      <message>"
                #echo "    WAITING: not yet submitting illumination correction measurement, too many jobs of this kind present"
                #echo "      </message>"
                echo "     </status>"   

            fi
            
        ### ILLUMINATION CORRECTION WAS SUBMITTED BUT DID NOT PRODUCE OUTPUT FILES YET
        elif [ $COMPLETEDILLCORMEASUREMENTCHECK -lt 1 ] && [ -e $PROJECTDIR/IllCorMeasurement.submitted ] && [ $ILLCORMEASUREMENTRESULTCOUNT -lt 1 ]; then
            
            echo "     <status action=\"illumination-correction\">waiting"
            #echo "      <message>"
            #echo "    PROCESSING: waiting for illumination correction measurement to finish"
            #echo "      </message>"
            echo "      <output>"                    
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "    ALERT: iBRAIN IS WAITING FOR ILLUMINATION CORRECTION MEASUREMENT, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                rm -f $PROJECTDIR/IllCorMeasurement.submitted
            fi
            echo "      </output>"                    
            echo "     </status>"  
            
            
        ### ILLUMINATION CORRECTION HAS BEEN COMPLETED BUT FAILED TO PRODUCE OUTPUT FILES
        elif [ $COMPLETEDILLCORMEASUREMENTCHECK -lt 1 ] && [ -e $PROJECTDIR/IllCorMeasurement.submitted ] && [ $ILLCORMEASUREMENTRESULTCOUNT -gt 0 ]; then
            
            echo "     <status action=\"illumination-correction\">failed"
            echo "      <warning>"
            echo "    ALERT: illumination correction measurement FAILED"
            echo "      </warning>"
            echo "      <output>"                    
            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "IllCorMeasurement" $PROJECTDIR/IllCorMeasurement.submitted
            echo "      </output>"
            echo "     </status>"

        ### IF ILLUMINATION CORRECTION FILE IS PRESENT, FLAG AS COMPLETED
        elif [ $COMPLETEDILLCORMEASUREMENTCHECK -gt 0 ]; then
            
            
            echo "     <status action=\"illumination-correction\">completed"
            #echo "      <message>"
            #echo "    COMPLETED: illumination correction"
            #echo "      </message>"
            echo "     </status>"
            
        fi    
            
            
            
            
        ##################
        ### PRECLUSTER ###
        
        ### CHECK IF IT HAS BEEN PRECLUSTERED ALREADY
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && ( [ ! -d $BATCHDIR ] || [ $BATCHJOBCOUNT -eq 0 ] ) && [ ! -e $PROJECTDIR/PreCluster.submitted ]; then
            
            # LOOK FOR SETTINGS FILE IN PROJECTDIR
            # PLATEPRECLUSTERSETTINGS=$(~/iBRAIN/searchforpreclusterfile.sh ${PROJECTDIR} ${PLATEPRECLUSTERSETTINGS} ${PRECLUSTERBACKUPPATH})
            
            if [ "$PLATEPRECLUSTERSETTINGS" ] && [ "$PLATEPRECLUSTERSETTINGS" != " " ] && [ -f $PLATEPRECLUSTERSETTINGS ]; then
                #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): submitting precluster with $(basename $PLATEPRECLUSTERSETTINGS)"
                echo "     <status action=\"precluster\">submitting"
                echo "      <output>"
                if [ ! -e $BATCHDIR ]; then
                    mkdir -p $BATCHDIR
                fi
                if [ ! -d $POSTANALYSISDIR ]; then
                    mkdir -p $POSTANALYSISDIR
                fi
                ~/iBRAIN/precluster.sh $PROJECTDIR $PLATEPRECLUSTERSETTINGS
                echo "      </output>"
                echo "     </status>"
            else
                echo "     <status action=\"precluster\">paused"
                echo "      <message>"
                echo " Plate processing is paused. No CellProfiler pipeline provided for this project, please add one to the root of this project or to the root of this plate. Make sure that the PreCluster file starts with PreCluster_ and ends with .mat"
                echo "      </message>"
                echo "     </status>"                
            fi
            
        ### IF HAS BEEN SUBMITTED FOR PRECLUSTER BUT NO PRECLUSTERRESULTS ARE PRESENT DO NOTHING
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $PRECLUSTERCHECK -eq 0 ]  && [ -e $PROJECTDIR/PreCluster.submitted ]; then
            
            echo "     <status action=\"precluster\">waiting"
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): waiting for precluster to finish"
            
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            if [ $PLATEJOBCOUNT -eq 0 ]; then
            	echo "      <warning>"
                    echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                    rm -f $PROJECTDIR/PreCluster.submitted
                echo "      </warning>"
            fi
            echo "     </status>"
            
        ### IF PreCluster_*.results EXISTS AND NO BATCHJOBS ARE FOUND, PRECLUSTER FAILED
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $BATCHJOBCOUNT -eq 0 ] && [ $PRECLUSTERCHECK -gt 0 ] && [ ! -e $PROJECTDIR/PreCluster.resubmitted ]; then
            
            echo "     <status action=\"precluster\">resubmitting"
            echo "      <warning>"
            echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): PreCluster failed. Submitting PreCluster again"
            echo "      </warning>"
            # LOOK FOR SETTINGS FILE
            
            #for FOUNDSETTINGSFILE2 in `find $PROJECTDIR -maxdepth 1 -type f -iname 'PreCluster*.mat'`
            #do
            #    PRECLUSTERSETTINGS="$FOUNDSETTINGSFILE2"
            #done
            
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): submitting precluster with $(basename $PRECLUSTERSETTINGS)"
            
            echo "      <output>"
            touch $PROJECTDIR/PreCluster.resubmitted
            ~/iBRAIN/precluster.sh $PROJECTDIR $PLATEPRECLUSTERSETTINGS
            echo "      </output>"
            echo "     </status>"
            
        ### IF PRECLUSTER RESUBMITTED BUT NOT FINISHED YET
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $BATCHJOBCOUNT -eq 0 ] && [ $PRECLUSTERCHECK -eq 1 ] && [ -e $PROJECTDIR/PreCluster.resubmitted ]; then
            
            
            echo "     <status action=\"precluster\">waiting"
            echo "      <warning>"
            echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Waiting for second PreCluster attempt"
            echo "      </warning>"
            echo "      <output>"
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. CHECKING RESULT FILES FOR KNOWN ERRORS"
                # check resultfiles for known errors, reset/resubmit jobs if appropriate 
                ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "PreCluster_" $PROJECTDIR/PreCluster.resubmitted
            fi
            echo "      </output>"
            echo "     </status>"
            
        ### IF PRECLUSTER RESUBMITTED FAILED AGAIN, ABORT DIRECTORY
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $BATCHJOBCOUNT -eq 0 ] && [ $PRECLUSTERCHECK -gt 1 ] && [ -e $PROJECTDIR/PreCluster.resubmitted ]; then
         
            echo "     <status action=\"precluster\">failed"
            echo "      <warning>"
            echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Second PreCluster attempt failed. Aborting directory"
            echo "      </warning>"
            echo "      <output>"
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                #echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. CHECKING RESULT FILES FOR KNOWN ERRORS"
                # check resultfiles for known errors, reset/resubmit jobs if appropriate 
                ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "PreCluster_" $PROJECTDIR/PreCluster.resubmitted
            fi
            echo "      </output>"
            echo "     </status>"
        
        #################
        ### CPCLUSTER ###
        
        ### IF BATCHJOBS ARE FOUND AND HAVE NOT YET BEEN SUBMITTED, SUBMIT THEM
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $BATCHJOBCOUNT -gt 0 ] && [ ! -e $PROJECTDIR/SubmitBatchJobs.submitted ] && [ $OUTPUTCOUNT -eq 0 ]; then

            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): submitting CPCluster batch jobs"
            echo "     <status action=\"cpcluster\">submitting"
            echo "      <output>"
            ~/iBRAIN/submitbatchjobs.sh $BATCHDIR
            echo "      </output>"
            echo "     </status>"
            
        ### IF BATCHJOBS HAVE NOT BEEN SUBMITTED VIA iBRAIN AND NOT ALL JOBS HAVE FINISHED
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $BATCHJOBCOUNT -gt 0 ] && [ ! -e $PROJECTDIR/SubmitBatchJobs.submitted ] && [ $OUTPUTCOUNT -lt $BATCHJOBCOUNT ]; then
            
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): submitting batch jobs"
            echo "     <status action=\"cpcluster\">submitting"
            echo "      <output>"
            ~/iBRAIN/submitbatchjobs.sh $BATCHDIR
            echo "      </output>"
            echo "     </status>"
                
            
        ### IF BATCHJOBS HAVE BEEN SUBMITTED BUT NOT ALL JOBS HAVE FINISHED DO NOTHING
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $CPCLUSTERRESULTCOUNT -lt $BATCHJOBCOUNT ] && [ $OUTPUTCOUNT -lt $BATCHJOBCOUNT ]; then


            
            # ##########
            # ### [091208 BS] A more detailed analysis progress bar:
            # Here we could do a SEGMENTATION filecount check to see the actual 
            #	progress of analysis (of course depends on SaveObjectSegmentation
            #   like modules in the cellprofiler pipeline...
            if [ -d ${PROJECTDIR}/SEGMENTATION/ ]; then
				BATCHSIZE=$( find $BATCHDIR -name "Batch_2_to_*.mat" | head -n 1 | sed 's/.*Batch_2_to_\([0-9]*\).*\.mat/\1/')
				SEGMENTATIONCOUNT=$(find ${PROJECTDIR}/SEGMENTATION/ -maxdepth 1 -type f -name "*_SegmentedNuclei.png" | wc -l)
				if [ $SEGMENTATIONCOUNT -eq 0 ]; then
					SEGMENTATIONCOUNT=$(find ${PROJECTDIR}/SEGMENTATION/ -maxdepth 1 -type f -name "*_SegmentedCells.png" | wc -l)	
				fi
				PROGRESSVALUE=$(echo "scale=2; (${SEGMENTATIONCOUNT} / (${BATCHSIZE} * ${BATCHJOBCOUNT})) * 100;" | bc)
            fi
            ##########

            echo "     <status action=\"cpcluster\">waiting"
            
            #echo "      <message>"
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): waiting for batchjobs to finish"
            #echo "      </message>"
            
            echo "      <output>"
            
            ### DRAW PROGRESSBAR IF APPROPRIATE (Note: expected to be at /plates/plate/status/output/progressbar ... all others are ignored
            if [ "$PROGRESSVALUE" ]; then
        		echo "       <progressbar>$PROGRESSVALUE</progressbar>"
            fi

            
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                rm -f $PROJECTDIR/SubmitBatchJobs.submitted
            fi
            echo "      </output>"
            echo "     </status>"
            
            
            

        
        ### IF ALL JOBS HAVE FINISHED BUT NOT ALL OUTPUT IS THERE, RESUBMIT
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $CPCLUSTERRESULTCOUNT -ge $BATCHJOBCOUNT ] && [ $OUTPUTCOUNT -lt $BATCHJOBCOUNT ] && [ ! -e $PROJECTDIR/SubmitBatchJobs.resubmitted ]; then
            
            echo "     <status action=\"cpcluster\">resubmitting"
            #echo "      <message>"
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): re-submitting batch jobs"
            #echo "      </message>"                                        
            echo "      <output>"
            touch $PROJECTDIR/SubmitBatchJobs.resubmitted
            ~/iBRAIN/submitbatchjobs.sh $BATCHDIR                    
            echo "      </output>"
            echo "     </status>"
                                


            
        ### IF ALL JOBS HAVE FINISHED, AND SOME HAVE FINISHED MORE THEN ONCE, BUT NOT ALL OUTPUT IS THERE, FLAG FOLDER AS FAILED
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && ( [ $CPCLUSTERRESULTCOUNT -ge $BATCHJOBCOUNT ] || [ $BATCHJOBCOUNT -eq $CPCLUSTERRESULTCOUNT ] ) && [ $OUTPUTCOUNT -lt $BATCHJOBCOUNT ] && [ -e $PROJECTDIR/SubmitBatchJobs.resubmitted ]; then

            echo "     <status action=\"cpcluster\">waiting"
            #echo "      <message>"
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Waiting for Batchjob resubmission to finish"
            #echo "      </message>"                                        
            echo "      <output>"
            


            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. CHECKING RESULT FILES FOR KNOWN ERRORS"
                #rm -f $PROJECTDIR/SubmitBatchJobs.submitted
                # check resultfiles for known errors, reset/resubmit jobs if appropriate
                # instead of checking all result files at the same time, we should loop over the individual batch jbos and check input/output. if missing,
                # only then check the result files. this will make the error-reporting much more informative/accurate
        	    for batchJob in $(find $BATCHDIR -maxdepth 1 -type f -name "Batch_*.txt"); do
        	       JOBBASENAME=$(basename $batchJob .txt)
        	       #echo "checking $JOBBASENAME"
        	       EXPECTEDOUTPUT=$(dirname $batchJob)/"${JOBBASENAME}_OUT.mat"
        	       if [ ! -e $EXPECTEDOUTPUT ]; then
        	       	 echo "no output found for $JOBBASENAME"
                      ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR $JOBBASENAME $PROJECTDIR/SubmitBatchJobs.resubmitted
        	       fi
            	done
            fi
            echo "      </output>"
            echo "     </status>"
            
            ### NOTE: DO NOT DO THIS AFTER RE-SUBMISSION!!! BAD IDEA, CAUSES JOBS BEING RESUBMITTED ENDLESSLY... :)
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            #PLATEJOBCOUNT=$(~/iBRAIN/countjobs.sh $PROJECTDIR)
            #if [ $PLATEJOBCOUNT -eq 0 ]; then
            #    echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PLATE. RETRYING THIS FOLDER"
            #    rm -f $PROJECTDIR/SubmitBatchJobs.resubmitted
            #fi
            
        ### IF ALL JOBS HAVE FINISHED, AND SOME HAVE FINISHED MORE THEN ONCE, BUT NOT ALL OUTPUT IS THERE, FLAG FOLDER AS FAILED
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $CPCLUSTERRESULTCOUNT -ge $BATCHJOBCOUNT ] && [ $OUTPUTCOUNT -lt $BATCHJOBCOUNT ] && [ -e $PROJECTDIR/SubmitBatchJobs.resubmitted ]; then
            
            echo "     <status action=\"cpcluster\">failed"
            echo "      <warning>"
            echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Batch job file has failed repeatedly. Aborting folder"
            echo "      </warning>"                                        
            echo "      <output>"
            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. CHECKING RESULT FILES FOR KNOWN ERRORS"
                #rm -f $PROJECTDIR/SubmitBatchJobs.submitted
                # check resultfiles for known errors, reset/resubmit jobs if appropriate
                # instead of checking all result files at the same time, we should loop over the individual batch jbos and check input/output. if missing,
                # only then check the result files. this will make the error-reporting much more informative/accurate
                for batchJob in $(find $BATCHDIR -maxdepth 1 -type f -name "Batch_*.txt"); do
                   JOBBASENAME=$(basename $batchJob .txt)
                   #echo "checking $JOBBASENAME"                       
                   EXPECTEDOUTPUT="${JOBBASENAME}_OUT.mat"
                   if [ ! -e $EXPECTEDOUTPUT ]; then
                      #echo "no output found for $JOBBASENAME"
                      ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR $JOBBASENAME $PROJECTDIR/SubmitBatchJobs.resubmitted
                   fi
                done
            fi
            echo "      </output>"
            echo "     </status>"                    
        
        
        ########################################
        ### DATAFUSION AND CHECK AND CLEANUP ###
        
        ### IF ALL BATCHJOB OUTPUT EQUALS BATCHJOBS THEN SUBMIT DATAFUSION
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $BATCHJOBCOUNT -eq $OUTPUTCOUNT ] && [ ! -e $PROJECTDIR/DataFusion.submitted ]; then
            
            echo "     <status action=\"datafusion\">submitting"
            #echo "      <message>"
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Submitting datafusion"
            #echo "      </message>"                                        
            echo "      <output>"
            
            echo DATAFUSIONRESULTCOUNT=$DATAFUSIONRESULTCOUNT 
            echo EXPECTEDMEASUREMENTS=$EXPECTEDMEASUREMENTS
            touch $PROJECTDIR/DataFusion.submitted
            ~/iBRAIN/datafusion.sh $BATCHDIR
            
            echo "      </output>"
            echo "     </status>"                    
            

            
            
            
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $DATAFUSIONRESULTCOUNT -lt $EXPECTEDMEASUREMENTS ] && [ -e $PROJECTDIR/DataFusion.submitted ]; then

            echo "     <status action=\"datafusion\">waiting"
            #echo "      <message>"
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): waiting for datafusion to finish"                    
            #echo "      </message>"                                        
            echo "      <output>"
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                rm -f $PROJECTDIR/DataFusion.submitted
            fi                    
            
            ### [091208 BS] Add a DATAFUSION progress bar!
			PROGRESSBARVALUE=$(echo "scale=2; (${DATAFUSIONRESULTCOUNT} / ${EXPECTEDMEASUREMENTS}) * 100;" | bc)
        	if [ "$PROGRESSBARVALUE" ]; then
    			echo "       <progressbar>$PROGRESSBARVALUE</progressbar>"
        	fi
            
            
            echo "      </output>"
            echo "     </status>"                    

            

            

            
        ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT CHECK DATAFUSION AND CLEANUP BATCH FILES
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ -e $PROJECTDIR/DataFusion.submitted ] && [ ! -e $PROJECTDIR/DataFusionCheckAndCleanup.submitted ]; then
            
            ### ONLY SUBMIT datafusioncheckandcleanup IF THERE ARE LESS THAN 60 DATAFUSION-CHECK JOBS PRESENT, OTHERWISE THE NAS WILL FREAK OUT BECAUSE OF HIGH I/O
            DATAFUSIONCHECKJOBCOUNT=$(~/iBRAIN/countjobs.sh datafusioncheckandcleanup)
            #DATAFUSIONCHECKJOBCOUNT=$(grep "datafusioncheckandcleanup" $JOBSFILE -c)
            if [ $DATAFUSIONCHECKJOBCOUNT -lt 60 ]; then
            	
            echo "     <status action=\"datafusion-check-and-cleanup\">submitting"
            #echo "      <message>"
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Submitting datafusion check and cleanup of batch files ($DATAFUSIONCHECKJOBCOUNT similar jobs present)"
            #echo "      </message>"                                        
            echo "      <output>"
            
               ~/iBRAIN/submitdatafusioncheckandcleanup.sh $BATCHDIR
            
            echo "      </output>"
            echo "     </status>"    

            else
            
            echo "     <status action=\"datafusion-check-and-cleanup\">waiting"
            #echo "      <message>"
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Not submitting datafusion check and cleanup of batch files: too many ($DATAFUSIONCHECKJOBCOUNT) similar jobs present"
            #echo "      </message>"                                        
            echo "     </status>"                    
                                  
            fi
            
        ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT CHECK DATAFUSION AND CLEANUP BATCH FILES
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ -e $PROJECTDIR/DataFusionCheckAndCleanup.submitted ] && [ $DATAFUSIONCHECKRESULTCOUNT -eq 0 ]; then
            
            echo "     <status action=\"datafusion-check-and-cleanup\">waiting"
            #echo "      <message>"
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Waiting for datafusion check and cleanup to finish"
            #echo "      </message>"                                        
           

            echo "      <output>"
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                rm -f $PROJECTDIR/DataFusionCheckAndCleanup.submitted
            fi
            echo "      </output>"
            echo "     </status>"                                        

        ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT CHECK DATAFUSION AND CLEANUP BATCH FILES
        
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ -e $PROJECTDIR/DataFusionCheckAndCleanup.submitted ] && [ $DATAFUSIONCHECKRESULTCOUNT -gt 0 ] && [ $EXPECTEDMEASUREMENTS -eq 1 ]; then
			            
            echo "     <status action=\"datafusion-check-and-cleanup\">datafusion finished once, but did not remove all Batch measurements... resubmitting"
            #echo "      <message>"
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Waiting for datafusion check and cleanup to finish"
            #echo "      </message>"                                        
           

            echo "      <output>"
            echo "  RESETTING DATAFUSIONCHECKANDCLEANUP (UNORTHODOX :-)"
            # rm -f $PROJECTDIR/DataFusionCheckAndCleanup.submitted
            rm -f $BATCHDIR/DataFusionCheckAndCleanup_*.results
            ~/iBRAIN/submitdatafusioncheckandcleanup.sh $BATCHDIR
            echo "      </output>"
            echo "     </status>"                                        
            
            
        ### CHECK IF ALL DATAFUSION FILES PASSED THE CHECK; IF NOT, RESUBMIT DATAFUSION AS A FIRST ATTEMPT
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $FAILEDDATACHECKRESULTCOUNT -gt 0 ] && [ ! -e $PROJECTDIR/DataFusion.resubmitted ]; then
            
            echo "     <status action=\"datafusion\">resubmitting"
            echo "      <message>"
            echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Re-submitting datafusion, corrupt datafusion files found"
            echo "      </message>"                                        
            echo "      <output>"                    
            touch $PROJECTDIR/DataFusion.resubmitted
            ~/iBRAIN/datafusion.sh $BATCHDIR
            echo "      </output>"                    
            echo "     </status>"
            
        ### CHECK IF ALL DATAFUSION FILES PASSED THE CHECK; IF NOT, RESUBMIT DATAFUSION AS A FIRST ATTEMPT
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $FAILEDDATACHECKRESULTCOUNT -eq 0 ] && [ $EXPECTEDMEASUREMENTS -gt 0 ] && [ ! -e $PROJECTDIR/DataFusion.resubmitted ]; then
            
            echo "     <status action=\"datafusion\">resubmitting"
            echo "      <message>"
            echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Re-submitting datafusion, still found BATCH measurements to process"
            echo "      </message>"                                        
            echo "      <output>"                    
            touch $PROJECTDIR/DataFusion.resubmitted
            ~/iBRAIN/datafusion.sh $BATCHDIR
            echo "      </output>"                    
            echo "     </status>"
                        
        ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT CHECK DATAFUSION AND CLEANUP BATCH FILES
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ -e $PROJECTDIR/DataFusion.resubmitted ] && [ $FAILEDDATACHECKRESULTCOUNT -eq 0 ] && [ $EXPECTEDMEASUREMENTS -gt 0 ] && [ ! -e $PROJECTDIR/DataFusionCheckAndCleanup.resubmitted ]; then
            
            echo "     <status action=\"datafusion-check-and-cleanup\">resubmitting"
            #echo "      <message>"
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Re-submitting datafusion check and cleanup of batch files"
            #echo "      </message>"                                        
            echo "      <output>"                    
            touch $PROJECTDIR/DataFusionCheckAndCleanup.resubmitted
            ~/iBRAIN/submitdatafusioncheckandcleanup.sh $BATCHDIR
            echo "      </output>"                    
            echo "     </status>"                    
            
        ### IF RESUBMIT DATAFUSION STILL FAILED, FLAG IT AS SUCH
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $FAILEDDATACHECKRESULTCOUNT -gt 0 ] && [ -e $PROJECTDIR/DataFusion.resubmitted ] && [ ! -e $PROJECTDIR/InfectionScoring.submitted ]; then
            
            echo "     <status action=\"datafusion-check-and-cleanup\">failed"
            echo "      <warning>"
            echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Corrupt datafusion files found after second datafusion attempt."
            
            # [BS-TEMP-BUGFIX] ONE TIME DEBUG, TO RESUBMIT ALL DATAFUSIONCHECK JOBS, TO FORCE
            # A RERUN WITH THE NEW AND MORE RELAXED DATAFUSIONCHECKANDCLEANUP FUNCTION IN MATLAB
            # echo "  APPLYING TEMPORARY FIX BY BEREND -- REMOVE THE LINE BELOW!!! "
            # rm -v $PROJECTDIR/DataFusionCheckAndCleanup.resubmitted
            # [END OF TEMP BUGFIX]
            
            echo "      </warning>"                                        
            echo "     </status>"  
            
        ### FLAG STAGE 1 AS COMPLETED
        elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $FAILEDDATACHECKRESULTCOUNT -eq 0 ] && [ $EXPECTEDMEASUREMENTS -eq 0 ] && [ $DATAFUSIONCHECKRESULTCOUNT -gt 0 ]; then

            echo "     <status action=\"stage-1\">completed"
			if [ $OBJECTCOUNTCOUNT -eq 0 ]; then        
		        echo "      <message>"
		        echo "  NOTE, You did not create any objects in your CellProfiler pipeline, as Measurements_Image_ObjectCount.mat is missing."
		        echo "      </message>"
			fi                                        
            echo "     </status>"  
            
            #echo "  COMPLETED STAGE 1 $(basename $PROJECTDIR)"
            if [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then
                touch $PROJECTDIR/iBRAIN_Stage_1.completed
            fi
            
        ### FLAG STAGE 1 AS COMPLETED, BECAUSE IT WAS PREVIOUSLY FLAGGED AS COMPLETED 
        elif [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then

            echo "     <status action=\"stage-1\">completed"
			if [ $OBJECTCOUNTCOUNT -eq 0 ]; then        
		        echo "      <message>"
		        echo "  NOTE, You did not create any objects in your CellProfiler pipeline, as Measurements_Image_ObjectCount.mat is missing."
		        echo "      </message>"
			fi                                        
            echo "     </status>"
             
        else 

            echo "     <status action=\"stage-1\">unknown"
            echo "      <warning>"
            echo "  UNKNOWN STATUS $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): but most likely finished"
            echo "      </warning>"                                        
            echo "     </status>"
            
            if [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then
                touch $PROJECTDIR/iBRAIN_Stage_1.completed
            fi
            
            WARNINGFLAG=1
            
        fi # if [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $COMPLETEFILECHECK -eq 0 ]; then
        
        
        ######################
        ### BS TEMP HACK:
	    # if [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ ! -d $BATCHDIR ]; then
	    #     rm -f $PROJECTDIR/iBRAIN_Stage_1.completed >& /dev/null
	    #     rm -f $PROJECTDIR/*.submitted >& /dev/null
	    # fi
        
        
        
        ######################################
        ### STAGE INDEPENDENT JPG CREATION ###
        
        if [ ! $COMPLETEFILECHECK -eq 0 ] && [ ! $COMPLETEDPNGCONVERSIONCHECK -eq 0 ] && [ ! -d $JPGDIR ]; then
            echo "     <status action=\"jpg-creation\">preparing"
            #echo "      <message>"
            #echo "    PROCESSING: creating JPG directory"
            #echo "      </message>"
            echo "      <output>"
            mkdir -p $JPGDIR
            echo "      </output>"                                        
            echo "     </status>"
        fi
        
        
        
        if [ -d $JPGDIR ]; then
            # CHECK HOW MANY JPGs HAVE BEEN CREATED
            JPGCOUNT=$(find $JPGDIR -maxdepth 1 -type f -name "*.jpg" | wc -l)
            JPGPLATEOVERVIEWCOUNT=$(find $JPGDIR -maxdepth 1 -type f -name "*PlateOverview.jpg" | wc -l)                    
            CREATEJPGRESULTCOUNT=$(find $JPGDIR -maxdepth 1 -type f -name "CreateJPGs*.results" | wc -l)
        else
            JPGPLATEOVERVIEWCOUNT=0
            JPGCOUNT=0
            CREATEJPGRESULTCOUNT=0
        fi
        
        if [ -d $JPGDIR ] && [ ! -w $JPGDIR ]; then
        
            echo "     <status action=\"jpg-creation\">skipping"
            echo "      <message>"
            echo "    ALERT: JPG DIRECTORY NOT WRITABLE BY iBRAIN"
            echo "      </message>"
            echo "      <output>"
            echo "  NOT SUBMITTING JPG-CREATION IN $JPGDIR, DIRECTORY IS NOT WRITABLE BY iBRAIN"
            echo "      </output>"                                        
            echo "     </status>"                  
        
        elif [ ! $COMPLETEFILECHECK -eq 0 ] && [ ! $COMPLETEDPNGCONVERSIONCHECK -eq 0 ] && [ -d $JPGDIR ] && [ ! -e $PROJECTDIR/CreateJPGs.submitted ] && [ $JPGCOUNT -eq 0 ]; then
                
            echo "     <status action=\"jpg-creation\">submitting"
            #echo "      <message>"
            #echo "    PROCESSING: submitting jpg creation"
            #echo "      </message>"
            echo "      <output>"
            ~/iBRAIN/createjpgs.sh $TIFFDIR $JPGDIR
            touch $PROJECTDIR/CreateJPGs.submitted
            echo "      </output>"                                        
            echo "     </status>"
            
        elif [ -e $PROJECTDIR/CreateJPGs.submitted ] && [ ! -e $PROJECTDIR/CreateJPGs.resubmitted ] && ([ $JPGCOUNT -eq 0 ] || [ $JPGPLATEOVERVIEWCOUNT -eq 0 ]) && [ $CREATEJPGRESULTCOUNT -eq 0 ]; then
                
            echo "     <status action=\"jpg-creation\">waiting"
            #echo "      <message>"
            #echo "    PROCESSING: waiting for jpg creation"
            #echo "      </message>"
            echo "      <output>"
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "    ALERT: iBRAIN IS WAITING FOR JPG CREATION, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                rm -f $PROJECTDIR/CreateJPGs.submitted
            fi
            echo "      </output>"                                        
            echo "     </status>"

        elif [ -e $PROJECTDIR/CreateJPGs.submitted ] && [ ! -e $PROJECTDIR/CreateJPGs.resubmitted ] && ([ $JPGCOUNT -eq 0 ] || [ $JPGPLATEOVERVIEWCOUNT -eq 0 ]) && [ $CREATEJPGRESULTCOUNT -gt 0 ]; then

            echo "     <status action=\"jpg-creation\">resubmitting"
            #echo "      <message>"
            #echo "    PROCESSING: resubmitting jpg creation"
            #echo "      </message>"
            echo "      <output>"
            ~/iBRAIN/createjpgs.sh $TIFFDIR $JPGDIR
            touch $PROJECTDIR/CreateJPGs.resubmitted
            echo "      </output>"                                        
            echo "     </status>"

        elif [ -e $PROJECTDIR/CreateJPGs.submitted ] && [ -e $PROJECTDIR/CreateJPGs.resubmitted ] && ([ $JPGCOUNT -eq 0 ] || [ $JPGPLATEOVERVIEWCOUNT -eq 0 ]) && [ $CREATEJPGRESULTCOUNT -eq 1 ]; then
               
            echo "     <status action=\"jpg-creation\">waiting"
            #echo "      <message>"
            #echo "    PROCESSING: waiting for jpg re-submission"
            #echo "      </message>"
            echo "      <output>"
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "    ALERT: iBRAIN IS WAITING FOR JPG CREATION, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                rm -f $PROJECTDIR/CreateJPGs.resubmitted
            fi
            echo "      </output>"                                        
            echo "     </status>"
                                    
            
        elif [ -e $PROJECTDIR/CreateJPGs.submitted ] && [ -e $PROJECTDIR/CreateJPGs.resubmitted ] && ([ $JPGCOUNT -eq 0 ] || [ $JPGPLATEOVERVIEWCOUNT -eq 0 ]) && [ $CREATEJPGRESULTCOUNT -gt 1 ]; then
            
            echo "     <status action=\"jpg-creation\">failed"
            echo "      <warning>"
            echo "    ALERT: JPG CREATION FAILED TWICE"
            echo "      </warning>"
            echo "      <output>"
            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
            ~/iBRAIN/check_resultfiles_for_known_errors.sh $JPGDIR "CreateJPGs" $PROJECTDIR/CreateJPGs.resubmitted
            echo "      </output>"                                        
            echo "     </status>"                    
            
        elif [ $JPGCOUNT -gt 0 ]; then
            

            echo "     <status action=\"jpg-creation\">completed"
            #echo "      <message>"
            #echo "    COMPLETED: jpg creation"
            #echo "      </message>"
            echo "     </status>"                    
            
        fi
        
        
        
        
        
        
        
        
        ##################################
        ### START MAIN LOGICS: STAGE 2 ###
        
        
        # if stage 1 is completed, and if there are object count measurements, perform the following checks
        if [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $OBJECTCOUNTCOUNT -gt 0 ]; then
        
        
        
         ### [2010-02-18, BS] FINALLY TAKEN OUT OLD SKOOL INFECTION SCORING FROM iBRAIN
#        ###
#        ### INFECTION SCORING
#        ###
        
#        ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT SUBMIT INFECTION SCORING
        
#        INFECTIONSETTINGFILECOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_Nuclei_VirusScreenGaussians.mat" | wc -l)
#        
#        if [ ! -e $PROJECTDIR/InfectionScoring.submitted ] && [ $INFECTIONSETTINGFILECOUNT -eq 1 ]; then
#             
#            echo "     <status action=\"infection-scoring\">submitting"
#            #echo "      <message>"
#            #echo "    PROCESSING: submitting infection scoring checking"
#            #echo "      </message>"                                        
#            echo "      <output>"                    
#            ~/iBRAIN/infectionscoring.sh $BATCHDIR
#            touch $PROJECTDIR/InfectionScoring.submitted
#            echo "      </output>"                    
#            echo "     </status>"                     
#             
#            
#        ### INFECTION SCORING HAS BEEN SUBMITTED BUT DID NOT PRODUCE OUTPUT FILES YET
#        elif [ $INFECTIONCOUNT -lt 2 ] && [ -e $PROJECTDIR/InfectionScoring.submitted ] && [ $INFECTIONRESULTCOUNT -lt 1 ]; then
#            
#            echo "     <status action=\"infection-scoring\">waiting"
#            #echo "      <message>"
#            #echo "    PROCESSING: waiting for infection scoring to finish"
#            #echo "      </message>"                                        
#            echo "      <output>"                    
#            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
#            if [ $PLATEJOBCOUNT -eq 0 ]; then
#                echo "    ALERT: iBRAIN IS WAITING FOR INFECTIONSCORING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
#                rm -f $PROJECTDIR/InfectionScoring.submitted
#            fi
#            echo "      </output>"                    
#            echo "     </status>"                     
#            
#            
#            
#            
#
#            
#        elif [ $INFECTIONCOUNT -gt 1 ]; then
#
#            echo "     <status action=\"infection-scoring\">completed"
#            #echo "      <message>"
#            #echo "    COMPLETED: infectionscoring"
#            #echo "      </message>"                                        
#            echo "     </status>"                     
#            
#        elif [ $INFECTIONSETTINGFILECOUNT -eq 0 ]; then
#
#            echo "     <status action=\"infection-scoring\">skipping"
#            #echo "      <message>"
#            #echo "    SKIPPING: infectionscoring"
#            #echo "      </message>"                                        
#            echo "     </status>"                     
#            
#        else
#            
#            echo "     <status action=\"infection-scoring\">unknown"
#            echo "      <warning>"
#            echo "    UNKNOWN STATUS: infectionscoring"
#            echo "      </warning>"
#            echo "      <output>"                    
#            BOOLINFECTIONSCORINGFAILED=1
#            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
#            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "InfectionScoring" $PROJECTDIR/InfectionScoring.submitted                    
#            echo "      </output>"                    
#            echo "     </status>"                     
#                                
#        fi
        
        
        
        
        ###
        ### CHECK OUTOFFOCUS
        ###
        
        ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT SUBMIT INFECTION SCORING
        
        OUTOFFOCUSSETTINGFILECOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_*BlueSpectrum.mat" | wc -l)
        
        if [ ! -e $PROJECTDIR/CheckOutOfFocus.submitted ] && [ $OUTOFFOCUSSETTINGFILECOUNT -gt 0 ]; then
             
            echo "     <status action=\"outoffocus-scoring\">submitting"
            #echo "      <message>"
            #echo "    PROCESSING: submitting outoffocus checking"
            #echo "      </message>"
            echo "      <output>"                    
            ~/iBRAIN/checkoutoffocus.sh $BATCHDIR
            echo "      </output>"                    
            echo "     </status>"                     
            
            
        ### CHECK OUTOFFOCUS HAS BEEN SUBMITTED BUT DID NOT PRODUCE OUTPUT FILES YET
        elif [ $OUTOFFOCUSCOUNT -lt 1 ] && [ -e $PROJECTDIR/CheckOutOfFocus.submitted ] && [ $OUTOFFOCUSRESULTCOUNT -lt 1 ]; then
            
            echo "     <status action=\"outoffocus-scoring\">waiting"
            #echo "      <message>"
            #echo "    PROCESSING: waiting for outoffocus checking to finish"
            #echo "      </message>"
            echo "      <output>"                    
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. CHECKING RESULT FILES FOR KNOWN ERRORS"
                # check resultfiles for known errors, reset/resubmit jobs if appropriate 
                # ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "CheckOutOfFocus" $PROJECTDIR/CheckOutOfFocus.submitted
                rm -f $PROJECTDIR/CheckOutOfFocus.submitted
            fi
            echo "      </output>"                    
            echo "     </status>"                     

            
        ### CHECK OUTOFFOCUS HAS BEEN COMPLETED BUT FAILED TO PRODUCE OUTPUT FILES
        elif [ $OUTOFFOCUSCOUNT -lt 1 ] && [ -e $PROJECTDIR/CheckOutOfFocus.submitted ] && [ $OUTOFFOCUSRESULTCOUNT -gt 0 ]; then
            
            echo "     <status action=\"outoffocus-scoring\">failed"
            echo "      <warning>"
            echo "    ALERT: checkoutoffocus FAILED"
            echo "      </warning>"
            echo "      <output>"                    
            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "CheckOutOfFocus" $PROJECTDIR/CheckOutOfFocus.submitted
            echo "      </output>"                    
            echo "     </status>"  
          
            
        ### IF OUTOFFOCUS FILE IS PRESENT, FLAG AS COMPLETED
        elif [ $OUTOFFOCUSCOUNT -gt 0 ]; then
            
            echo "     <status action=\"outoffocus-scoring\">completed"
            #echo "      <message>"
            #echo "    COMPLETED: checkoutoffocus"
            #echo "      </message>"
            echo "     </status>"   
                                
            
            
        elif [ $OUTOFFOCUSSETTINGFILECOUNT -eq 0 ]; then

            echo "     <status action=\"outoffocus-scoring\">skipping"
            #echo "      <message>"
            #echo "    SKIPPING: checkoutoffocus"
            #echo "      </message>"
            echo "     </status>" 
            
            
            
        else

            echo "     <status action=\"outoffocus-scoring\">unknown"
            echo "      <warning>"
            echo "    UNKNOWN STATUS: checkoutoffocus"
            echo "      </warning>"
            echo "      <output>"                    
            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "CheckOutOfFocus" $PROJECTDIR/CheckOutOfFocus.submitted
            echo "      </output>"                    
            echo "     </status>" 
            
        fi
        
        
        ###
        ### PLATE NORMALIZATION
        ###
        
        ### variables:

        ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT SUBMIT MEASUREMENTS_MEAN_STD
        #
        # [100301] I added stitchWellSegmentation() to the submission code ;) should be robust!
        #
        if [ ! -e $PROJECTDIR/MeasurementsMeanStd.submitted ]; then

            currentjobcount=$(~/iBRAIN/countjobs.sh "Measurements_mean_std_iBRAIN")
            #currentjobcount=$(grep "Measurements_mean_std_iBRAIN" $JOBSFILE -c)
                         
            if [ $currentjobcount -lt 60 ]; then
            	
                echo "     <status action=\"plate-normalization\">submitting"
                #echo "      <message>"
                #echo "    PROCESSING: submitting plate normalization calculations"
                #echo "      </message>"
                echo "      <output>"                    
                ~/iBRAIN/platenormalization.sh $BATCHDIR
                touch $PROJECTDIR/MeasurementsMeanStd.submitted
                echo "      </output>"                    
                echo "     </status>"                        	

            else
            
                echo "     <status action=\"plate-normalization\">waiting"
                #echo "      <message>"
                #echo "    WAITING: not yet submitting plate normalization calculations, too many jobs of this kind present"
                #echo "      </message>"
                echo "     </status>"   
                                    

            fi
            
        ### PLATE NORMALIZATION HAS BEEN SUBMITTED BUT DID NOT PRODUCE OUTPUT FILES YET
        elif [ $NORMALIZATIONCOUNT -lt 1 ] && [ -e $PROJECTDIR/MeasurementsMeanStd.submitted ] && [ $NORMALIZATIONRESULTCOUNT -lt 1 ]; then
            
            echo "     <status action=\"plate-normalization\">waiting"
            #echo "      <message>"
            #echo "    PROCESSING: waiting for plate normalization to finish"
            #echo "      </message>"
            echo "      <output>"                    
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "    ALERT: iBRAIN IS WAITING FOR PLATE NORMALIZATION, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                rm -f $PROJECTDIR/MeasurementsMeanStd.submitted
            fi
            echo "      </output>"                    
            echo "     </status>"  
            
            
        ### PLATE NORMALIZATION HAS BEEN COMPLETED BUT FAILED TO PRODUCE OUTPUT FILES
        elif [ $NORMALIZATIONCOUNT -lt 1 ] && [ -e $PROJECTDIR/MeasurementsMeanStd.submitted ] && [ $NORMALIZATIONRESULTCOUNT -gt 0 ]; then
            
            echo "     <status action=\"plate-normalization\">failed"
            echo "      <warning>"
            echo "    ALERT: plate normalization FAILED"
            echo "      </warning>"
            echo "      <output>"                    
            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "MeasurementsMeanStd" $PROJECTDIR/MeasurementsMeanStd.submitted
            echo "      </output>"
            
            ########################################## BS HACK TEMP 10-02-21 #########
            ### For VSV_DG, lets reanalyze all these plates that have failed Measurements Mean Std.
			# if [ "$(echo $INCLUDEDPATH | grep 'VSV_DG')" ]; then
	        #     echo "      <output>"                    
	        #     echo "RESETTING ENTIRY PLATE ANALYSIS!!! temp bs hack 2010-02-21"
	        #     rm -vrf $BATCHDIR
	        #     rm -vrf $PROJECTDIR/SEGMENTATION
	        #     rm -vrf $PROJECTDIR/POSTANALYSIS
	        #     rm -vf $PROJECTDIR/*.submitted
	        #     echo "      </output>"            
			# fi                         
            ########################################## BS HACK TEMP 10-02-21 #########
            echo "     </status>"

        ### IF PLATE NORMALIZATION FILE IS PRESENT, FLAG AS COMPLETED
        elif [ $NORMALIZATIONCOUNT -gt 0 ]; then
            
            
            echo "     <status action=\"plate-normalization\">completed"
            #echo "      <message>"
            #echo "    COMPLETED: plate normalization"
            #echo "      </message>"
            echo "     </status>"          
                    
            
        fi
        
        
        
 
 
 
 
 
 
 
        ###
        ### GET LOCAL CELL DENSITY PER WELL AUTO
        ###
        
        ### variables:

        if [ ! -e $PROJECTDIR/GetLocalCellDensityPerWell_Auto.submitted ]; then
                echo "     <status action=\"get-local-cell-density-per-well\">submitting"
                #echo "      <message>"
                #echo "    PROCESSING: submitting plate normalization calculations"
                #echo "      </message>"
                echo "      <output>"           
                
                    LCDRESULTFILE="getLocalCellDensityPerWell_auto_$(date +"%y%m%d%H%M%S").results"
bsub -W 8:00 -o "${BATCHDIR}$LCDRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
getLocalCellDensityPerWell_auto('${BATCHDIR}');
Detect_BorderCells('${BATCHDIR}');
M_PROG"
                touch $PROJECTDIR/GetLocalCellDensityPerWell_Auto.submitted
                echo "      </output>"                    
                echo "     </status>"                        	
            
        ### PLATE NORMALIZATION HAS BEEN SUBMITTED BUT DID NOT PRODUCE OUTPUT FILES YET
        elif [ $LCDCOUNT -lt 1 ] && [ -e $PROJECTDIR/GetLocalCellDensityPerWell_Auto.submitted ] && [ $LCDRESULTCOUNT -lt 1 ]; then
            
            echo "     <status action=\"get-local-cell-density-per-well\">waiting"
            #echo "      <message>"
            #echo "    PROCESSING: waiting for plate normalization to finish"
            #echo "      </message>"
            echo "      <output>"                    
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "    ALERT: iBRAIN IS WAITING FOR LCD MEASUREMENTS, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                rm -f $PROJECTDIR/GetLocalCellDensityPerWell_Auto.submitted
            fi
            echo "      </output>"                    
            echo "     </status>"  
            
            
        ### PLATE NORMALIZATION HAS BEEN COMPLETED BUT FAILED TO PRODUCE OUTPUT FILES
        elif [ $LCDCOUNT -lt 1 ] && [ -e $PROJECTDIR/GetLocalCellDensityPerWell_Auto.submitted ] && [ $LCDRESULTCOUNT -gt 0 ]; then
            
            echo "     <status action=\"get-local-cell-density-per-well\">failed"
            echo "      <warning>"
            echo "    ALERT: local cell density measurement FAILED"
            echo "      </warning>"
            echo "      <output>"                    
            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "getLocalCellDensityPerWell_auto" $PROJECTDIR/GetLocalCellDensityPerWell_Auto.submitted
            echo "      </output>"

            echo "     </status>"

        ### IF PLATE NORMALIZATION FILE IS PRESENT, FLAG AS COMPLETED
        elif [ $LCDCOUNT -gt 0 ]; then
            
            echo "     <status action=\"get-local-cell-density-per-well\">completed"
            if [ -e $POSTANALYSISDIR/getLocalCellDensityPerWell_auto.pdf ]; then
                echo "     <file type=\"pdf\">$POSTANALYSISDIR/getLocalCellDensityPerWell_auto.pdf</file>"
                echo "     <file type=\"pdf\">$POSTANALYSISDIR/getLocalCellDensityPerWell_auto_auto.pdf</file>"
            fi
            echo "     </status>"        
            
        fi
        
        # end of local cell density measurement.
        
 
 
 
 
 
 
 
 
 
 
 
 
 
 
        
        
	     ###
        ### SEGMENTATION STITCHING PER WELL
        ###
        


        ### IF THERE ARE SEGMENTATION FILES, SUBMIT SEGMENTATION STITCHING PER WELL
		if [ -d $PROJECTDIR/SEGMENTATION ]; then
				
			STITCHINGMEASUREMENTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_*_StitchedWellObjectIds.mat" | wc -l)
			STITCHINRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "StitchSegmentationPerWell_*.results" | wc -l)
			
	        if [ ! -e $PROJECTDIR/StitchSegmentationPerWell.submitted ]; then
	
	            currentjobcount=$(~/iBRAIN/countjobs.sh "stitchSegmentationPerWell")
	                         
	            if [ $currentjobcount -lt 30 ]; then
	            	
	                echo "     <status action=\"stitch-segmentation-per-well\">submitting"
	                #echo "      <message>"
	                #echo "    PROCESSING: submitting plate segmentation stitching"
	                #echo "      </message>"
	                echo "      <output>"     
	                STITCHRESULTFILE="StitchSegmentationPerWell_$(date +"%y%m%d%H%M%S").results"               
	                bsub -W 8:00 -o "${BATCHDIR}$STITCHRESULTFILE" "matlab -singleCompThread -nodisplay -nojvm << M_PROG
					stitchSegmentationPerWell('${BATCHDIR}'); 
					M_PROG"
	                touch $PROJECTDIR/StitchSegmentationPerWell.submitted
	                echo "      </output>"                    
	                echo "     </status>"                        	
	
	            else
	            
	                echo "     <status action=\"stitch-segmentation-per-well\">waiting"
	                echo "      <message>"
	                echo "    WAITING: not yet submitting segmentation stitching per well, too many jobs of this kind present"
	                echo "      </message>"
	                echo "     </status>"   
	                                    
	
	            fi
	            
	        ### SEGMENTATION STITCHING HAS BEEN SUBMITTED BUT DID NOT PRODUCE OUTPUT FILES YET
	        elif [ $STITCHINGMEASUREMENTCOUNT -lt 1 ] && [ -e $PROJECTDIR/StitchSegmentationPerWell.submitted ] && [ $STITCHINRESULTCOUNT -lt 1 ]; then
	            
	            echo "     <status action=\"stitch-segmentation-per-well\">waiting"
	            #echo "      <message>"
	            #echo "    PROCESSING: waiting for SEGMENTATION STITCHING to finish"
	            #echo "      </message>"
	            echo "      <output>"                    
	            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
	            if [ $PLATEJOBCOUNT -eq 0 ]; then
	                echo "    ALERT: iBRAIN IS WAITING FOR SEGMENTATION STITCHING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
	                rm -f $PROJECTDIR/StitchSegmentationPerWell.submitted
	            fi
	            echo "      </output>"                    
	            echo "     </status>"  
	            
	            
	        ### PLATE NORMALIZATION HAS BEEN COMPLETED BUT FAILED TO PRODUCE OUTPUT FILES
	        elif [ $STITCHINGMEASUREMENTCOUNT -lt 1 ] && [ -e $PROJECTDIR/StitchSegmentationPerWell.submitted ] && [ $STITCHINRESULTCOUNT -gt 0 ]; then
	            
	            echo "     <status action=\"stitch-segmentation-per-well\">failed"
	            echo "      <warning>"
	            echo "    ALERT: segmentation stitching FAILED"
	            echo "      </warning>"
	            echo "      <output>"                    
	            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
	            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "StitchSegmentationPerWell" $PROJECTDIR/StitchSegmentationPerWell.submitted
	            echo "      </output>"                    
	            echo "     </status>"                         
	
	
	        ### IF PLATE NORMALIZATION FILE IS PRESENT, FLAG AS COMPLETED
	        elif [ $STITCHINGMEASUREMENTCOUNT -gt 0 ]; then
	            
	            
	            echo "     <status action=\"stitch-segmentation-per-well\">completed"
	            echo "     </status>"                     
	            
	        fi        
        
		fi #end of check if there's a segmentation directory present
        
        
        
        
        
        
        ###
        ### CREATE PLATE OVERVIEW
        ###
        
        ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT SUBMIT INFECTION SCORING
        
        # variables:
        # PLATEOVERVIEWCOUNT
        # PLATEOVERVIEWRESULTCOUNT
        # PLATEBASICDATACOUNT (actually the more important output! should adjust iBRAIN to check for the matlab output rather than the pdf/csv files...)
        
        
        ### CREATE PLATE OVERVIEW EITHER IF OUTOFFOCUS IS NOT TO BE DONE OR FINISHED, AND EITHER IF INFECTION SCORING IS COMPLETED OR NOT TO BE DONE
        
        ### if [ $OUTOFFOCUSCOUNT -gt 0 ] && [ $INFECTIONCOUNT -gt 1 ] && [ ! -e $PROJECTDIR/CreatePlateOverview.submitted ]; then
        
        # removed:
        #  && ( [ $INFECTIONCOUNT -gt 1 ] || [ $INFECTIONSETTINGFILECOUNT -eq 0 ] || [ $BOOLINFECTIONSCORINGFAILED -eq 1 ] )
        
        if ( [ $OUTOFFOCUSCOUNT -gt 0 ] || [ $OUTOFFOCUSSETTINGFILECOUNT -eq 0 ] ) && [ ! -e $PROJECTDIR/CreatePlateOverview.submitted ]; then

            echo "     <status action=\"plate-overview-generation\">submitting"
            echo "      <output>"
            if [ ! -d $POSTANALYSISDIR ]; then
                mkdir -p $POSTANALYSISDIR
            fi
            ~/iBRAIN/createplateoverview.sh $BATCHDIR 
            echo "      </output>"
            echo "     </status>"

        ### CHECK createplateoverview HAS BEEN SUBMITTED BUT DID NOT PRODUCE OUTPUT FILES YET
        elif [ $PLATEBASICDATACOUNT -lt 1 ] && [ -e $PROJECTDIR/CreatePlateOverview.submitted ] && [ $PLATEOVERVIEWRESULTCOUNT -lt 1 ]; then

            echo "     <status action=\"plate-overview-generation\">waiting"
            #echo "      <message>"
            #echo "    PROCESSING: waiting for plate overview generation to finish"
            #echo "      </message>"
            echo "      <output>"                    
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "    ALERT: iBRAIN IS WAITING FOR createplateoverview, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                rm -f $PROJECTDIR/CreatePlateOverview.submitted
            fi
            echo "      </output>"                    
            echo "     </status>"                    
            
        ### CHECK createplateoverview HAS BEEN COMPLETED BUT FAILED TO PRODUCE OUTPUT FILES
        elif [ $PLATEBASICDATACOUNT -lt 1 ] && [ -e $PROJECTDIR/CreatePlateOverview.submitted ] && [ $PLATEOVERVIEWRESULTCOUNT -gt 0 ]; then
            
            echo "     <status action=\"plate-overview-generation\">failed"
            echo "      <warning>"
            echo "    ALERT: plate overview generation FAILED"
            echo "      </warning>"
            echo "      <output>"                    
            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "CreatePlateOverview" $PROJECTDIR/CreatePlateOverview.submitted 
            echo "      </output>"                    
            echo "     </status>"                      
            
        elif [ $PLATEBASICDATACOUNT -gt 0 ]; then
            
            echo "     <status action=\"plate-overview-generation\">completed"
            #echo "      <message>"
            #echo "    COMPLETED: plate overview generation"
            #echo "      </message>"
            echo "     </status>"
            
        fi # end of plate overview
        
        
        
        
        ###BINCORRECTIONSETTINGSFILE
        ### SVM CLASSIFICATION
        ###
        
        # VARIABLES:
        ### NOTE THAT SVMSETTINGSFILE IS THE SUM OF CLASSIFICATION FILES IN THE INCLUDEDPATH AND IN THE PROJECTDIR!
        
        ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT SUBMIT SVM CLASSIFICATION
        BOOLSVMSWAITING=0;
        
        if [ $NORMALIZATIONCOUNT -gt 0 ] && [ $SVMSETTINGSFILE -gt 0 ]; then
             
            # should we make some special XML structure for the SVM files? group them together all in the status[@action='svm-classification']/status[@action='svm-file...']
            # note that in this case we group status-elements together in a parent status field!!!

            echo "     <status action=\"svm-classifications\">"
            echo "      <message>"
            echo "    $SVMSETTINGSFILE SVM classifications found"
            echo "      </message>"
            
            # to avoid double listing of settings files if $INCLUDEDPATH and $PROJECTDIR are the same... 
        	if [ $INCLUDEDPATH -ef $PROJECTDIR ]; then
            	ALLSVMSETTINGSFILES=$(find $PROJECTDIR -maxdepth 1 -type f -name 'SVM_*.mat')
        	else
        		# otherwise settings files can be stored both in the project directory ($INCLUDEDPATH) and in the plate directory ($PROJECTDIR) (ugly variable names...)
        		ALLSVMSETTINGSFILES=$(find $INCLUDEDPATH $PROJECTDIR -maxdepth 1 -type f -name 'SVM_*.mat')
        	fi
            
            for SVMSETTINGSFILE in $ALLSVMSETTINGSFILES; do
                
                SVMOUTPUTFILE="${BATCHDIR}Measurements_$(basename $SVMSETTINGSFILE)"
                SVMOVERVIEWPDFFILE="${POSTANALYSISDIR}Measurements_$(basename $SVMSETTINGSFILE .mat)_overview.pdf"
                SVMOVERVIEWCSVFILE="${POSTANALYSISDIR}Measurements_$(basename $SVMSETTINGSFILE .mat)_overview.csv"
                SVMRESULTFILEBASE="SVMClassification_$(basename $SVMSETTINGSFILE .mat)_"
                SVMSUBMITTEDFILE="${PROJECTDIR}/SVMClassification_$(basename $SVMSETTINGSFILE .mat).submitted"
                SVMRUNLIMITFILE="${PROJECTDIR}/SVMClassification_$(basename $SVMSETTINGSFILE .mat).runlimit"
                SVMRESULTFILECOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "$SVMRESULTFILEBASE*.results" | wc -l)
                #SVMJOBCOUNT=$(~/iBRAIN/countjobs.sh $(basename $SVMSETTINGSFILE))
                SVMJOBCOUNT=$(grep $(basename $SVMSETTINGSFILE) $JOBSFILE -c)
                if [ ! -d $POSTANALYSISDIR ]; then
                    mkdir -p $POSTANALYSISDIR
                fi
                
                if [ ! -e $SVMSUBMITTEDFILE ] && [ ! -e $SVMOUTPUTFILE ]; then
                    BOOLSVMSWAITING=1;
                    
                    echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">submitting"
                    #echo "      <message>"
                    #echo "      SUBMITTING: $(basename $SVMSETTINGSFILE)"
                    #echo "      </message>"
                    echo "      <output>"    
                    SVMRESULTFILE="$SVMRESULTFILEBASE$(date +"%y%m%d%H%M%S").results"
                    # do a 8h submission in case of timeout, otherwise do a 1h submission. 
                	if [ -e $SVMRUNLIMITFILE ]; then
bsub -W 8:00 -o "${BATCHDIR}$SVMRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
SVM_Classify_with_Probabilities_iBRAIN('${SVMSETTINGSFILE}','${BATCHDIR}');
M_PROG"
                	else
bsub -W 1:00 -o "${BATCHDIR}$SVMRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
SVM_Classify_with_Probabilities_iBRAIN('${SVMSETTINGSFILE}','${BATCHDIR}');
M_PROG"
	                fi
                    touch $SVMSUBMITTEDFILE
                    echo "      </output>"                    
                    echo "     </status>"
                                        
                    
                    
                    
                # no output yet                has been submitted          has jobs present        no output jet
                elif [ ! -e $SVMOUTPUTFILE ] && [ -e $SVMSUBMITTEDFILE ] && [ $SVMJOBCOUNT -gt 0 ] && [ $SVMRESULTFILECOUNT -eq 0 ]; then
                    BOOLSVMSWAITING=1;
                    
                    echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">waiting"
                    #echo "      <message>"
                    #echo "      WAITING: $(basename $SVMSETTINGSFILE): $SVMJOBCOUNT JOB(S) PRESENT"
                    #echo "      </message>"
                    echo "     </status>"

                # no output yet                has been submitted          no jobs present           results never produced
                elif [ ! -e $SVMOUTPUTFILE ] && [ -e $SVMSUBMITTEDFILE ] && [ $SVMJOBCOUNT -eq 0 ] && [ $SVMRESULTFILECOUNT -eq 0 ]; then
					BOOLSVMSWAITING=1;
					
                    echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">failed"
                    echo "      <warning>"
                    echo "      FAILED: $(basename $SVMSETTINGSFILE): RETRYING CLASSIFICATION. PREVIOUS JOB DID NOT PRODUCE OUTPUT (?!)"
                    echo "      </warning>"
                    echo "      <output>"                    
                    rm -fv $SVMSUBMITTEDFILE
                    echo "      </output>"                    
                    echo "     </status>"

                # no output yet                has been submitted          no jobs present           results produced once
                elif [ ! -e $SVMOUTPUTFILE ] && [ -e $SVMSUBMITTEDFILE ] && [ $SVMJOBCOUNT -eq 0 ] && [ $SVMRESULTFILECOUNT -eq 1 ]; then
					BOOLSVMSWAITING=1;
					
                    echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">failed"
                    echo "      <warning>"
                    echo "      FAILED: $(basename $SVMSETTINGSFILE): RETRYING CLASSIFICATION"
                    echo "      </warning>"
                    echo "      <output>"                    
                    ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
                    ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "$SVMRESULTFILEBASE" $SVMSUBMITTEDFILE                            
                    rm -fv $SVMSUBMITTEDFILE
                    echo "      </output>"                    
                    echo "     </status>"
                    
                # no output yet                has been submitted          no jobs present           results produced twice
                elif [ ! -e $SVMOUTPUTFILE ] && [ -e $SVMSUBMITTEDFILE ] && [ $SVMJOBCOUNT -eq 0 ] && [ $SVMRESULTFILECOUNT -eq 2 ]; then
					
                    echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">failed"
                    echo "      <warning>"
                    echo "      ABORTED: $(basename $SVMSETTINGSFILE): FAILED TWICE"
                    echo "      </warning>"
                    echo "      <output>"                    
                    ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
                    ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "$SVMRESULTFILEBASE" $SVMSUBMITTEDFILE
                    echo "      </output>"                    
                    echo "     </status>"
                    
                    
                # output present
                elif [ -e $SVMOUTPUTFILE ] ; then
                    
                    echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">completed"
                    #echo "      <message>"
                    #echo "      COMPLETED: $(basename $SVMSETTINGSFILE)"
                    #echo "      </message>"
                    if [ -e $SVMOVERVIEWPDFFILE ]; then
                        echo "     <file type=\"pdf\">$SVMOVERVIEWPDFFILE</file>"
                    fi
                    if [ -e $SVMOVERVIEWCSVFILE ]; then
                        echo "     <file type=\"csv\">$SVMOVERVIEWCSVFILE</file>"
                    fi
                    
                    echo "     </status>"
                    
                else
                
                    echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">unknown"
                    echo "      <warning>"
                    echo "      UNKNOWN STATUS: $(basename $SVMSETTINGSFILE)"
                    if [ -e $SVMSETTINGSFILE ]; then
                        echo "        DEBUG: SVMSETTINGSFILE=$SVMSETTINGSFILE (present)"
                    else
                        echo "        DEBUG: SVMSETTINGSFILE=$SVMSETTINGSFILE (missing)"
                    fi
                    if [ -e $SVMOUTPUTFILE ]; then
                        echo "        DEBUG: SVMOUTPUTFILE=$SVMOUTPUTFILE (present)"
                    else
                        echo "        DEBUG: SVMOUTPUTFILE=$SVMOUTPUTFILE (missing)"
                    fi
                    if [ -e $SVMSUBMITTEDFILE ]; then
                        echo "        DEBUG: SVMSUBMITTEDFILE=$SVMSUBMITTEDFILE (present)"
                    else
                        echo "        DEBUG: SVMSUBMITTEDFILE=$SVMSUBMITTEDFILE (missing)"
                    fi
                    echo "        DEBUG: SVMRESULTFILEBASE=$SVMRESULTFILEBASE"
                    echo "        DEBUG: SVMRESULTFILECOUNT-SEARCH-STRING=$SVMRESULTFILEBASE*.results"                            
                    echo "        DEBUG: SVMRESULTFILECOUNT=$SVMRESULTFILECOUNT"
                    echo "        DEBUG: SVMJOBCOUNT=$SVMJOBCOUNT"

                    echo "      </warning>"
                    echo "      <output>"                            
                    ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
                    ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "$SVMRESULTFILEBASE" $SVMSUBMITTEDFILE                            
                    echo "      </output>"
                    
                    echo "     </status>"
                                            
                
                
                fi
             
            done #LOOP OVER SVMSETTINGS FILES
            echo "     </status>"
                                
		fi # end of svms
        






        ###
        ### BIN CORRECTION
        ###
        
        # VARIABLES:
        ### NOTE THAT BINCORRECTIONSETTINGSFILE IS THE SUM OF BIN-CORRECTION FILES IN THE INCLUDEDPATH AND IN THE PROJECTDIR!
        ### WE DO NOT WANT TO RUN ANY BIN CORRECTION AS LONG AS THERE ARE SVMS WAITING TO BE DONE (BOOLSVMSWAITING==1)
        
        ### IF ANY SETTINGS FILE IS PRESENT, SUBMIT
        
        if [ $BINSETTINGSFILE -gt 0 ]; then
             
            # should we make some special XML structure for the SVM files? group them together all in the status[@action='bin-correction']/status[@action='bin-correction-file...']
            # note that in this case we group status-elements together in a parent status field!!!

            echo "     <status action=\"bin-correction\">"
            echo "      <message>"
            echo "    $BINSETTINGSFILE Bin correction settings files found"
            echo "      </message>"


            # to avoid double listing of settings files if $INCLUDEDPATH and $PROJECTDIR are the same... 
        	if [ $INCLUDEDPATH -ef $PROJECTDIR ]; then
            	ALLBINSETTINGSFILES=$(find $PROJECTDIR -maxdepth 1 -type f -name 'BIN_*.txt')
        	else
        		# otherwise settings files can be stored both in the project directory ($INCLUDEDPATH) and in the plate directory ($PROJECTDIR) (ugly variable names...)
        		ALLBINSETTINGSFILES=$(find $INCLUDEDPATH $PROJECTDIR -maxdepth 1 -type f -name 'BIN_*.txt')
        	fi
            
            for BINSETTINGSFILE in $ALLBINSETTINGSFILES; do
                
                BINOUTPUTFILE="${BATCHDIR}Measurements_$(basename $BINSETTINGSFILE .txt).mat"
                BINOVERVIEWPDFFILE="${POSTANALYSISDIR}Measurements_$(basename $BINSETTINGSFILE .txt)_overview.pdf"
                BINOVERVIEWCSVFILE="${POSTANALYSISDIR}Measurements_$(basename $BINSETTINGSFILE .txt)_overview.csv"
                BINRESULTFILEBASE="BINClassification_$(basename $BINSETTINGSFILE .txt)_"
                BINSUBMITTEDFILE="${PROJECTDIR}/BINClassification_$(basename $BINSETTINGSFILE .txt).submitted"
                BINRUNLIMITFILE="${PROJECTDIR}/BINClassification_$(basename $BINSETTINGSFILE .txt).runlimit"
                BINRESULTFILECOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "$BINRESULTFILEBASE*.results" | wc -l)
                #BINJOBCOUNT=$(~/iBRAIN/countjobs.sh $(basename $BINSETTINGSFILE))
                BINJOBCOUNT=$(grep $(basename $BINSETTINGSFILE) $JOBSFILE -c)
                if [ ! -d $POSTANALYSISDIR ]; then
                    mkdir -p $POSTANALYSISDIR
                fi
                
                if [ ! -e $BINSUBMITTEDFILE ] && [ ! -e $BINOUTPUTFILE ]; then
                    
                    # Do not submit if there are SVMs waiting...
                    if [ $BOOLSVMSWAITING -eq 1 ]; then

	                    echo "     <status action=\"$(basename $BINSETTINGSFILE)\">waiting"
	                    echo "      <message>"
	                    echo "      Waiting for all SVMs to be finished (or crashed), before submitting bin correction"
	                    echo "      </message>"
	                    echo "     </status>"
					
                    else
	                    echo "     <status action=\"$(basename $BINSETTINGSFILE)\">submitting"
	                    #echo "      <message>"
	                    #echo "      SUBMITTING: $(basename $BINSETTINGSFILE)"
	                    #echo "      </message>"
	                    echo "      <output>"    
	                    BINRESULTFILE="$BINRESULTFILEBASE$(date +"%y%m%d%H%M%S").results"
	                    if [-e $BINRUNLIMITFILE ]; then
bsub -W 8:00 -o "${BATCHDIR}$BINRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
runBinCorrection('${BATCHDIR}','${BINSETTINGSFILE}','$(basename $BINOUTPUTFILE)');
M_PROG"
	                    else
bsub -W 1:00 -o "${BATCHDIR}$BINRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
runBinCorrection('${BATCHDIR}','${BINSETTINGSFILE}','$(basename $BINOUTPUTFILE)');
M_PROG"
	                	fi                    
	                    touch $BINSUBMITTEDFILE
	                    echo "      </output>"                    
	                    echo "     </status>"
            		fi;                                        
                    
                    
                    
                # no output yet                has been submitted          has jobs present        no output jet
                elif [ ! -e $BINOUTPUTFILE ] && [ -e $BINSUBMITTEDFILE ] && [ $BINJOBCOUNT -gt 0 ] && [ $BINRESULTFILECOUNT -eq 0 ]; then
                    
                    echo "     <status action=\"$(basename $BINSETTINGSFILE)\">waiting"
                    #echo "      <message>"
                    #echo "      WAITING: $(basename $BINSETTINGSFILE): $BINJOBCOUNT JOB(S) PRESENT"
                    #echo "      </message>"
                    echo "     </status>"

                # no output yet                has been submitted          no jobs present           results never produced
                elif [ ! -e $BINOUTPUTFILE ] && [ -e $BINSUBMITTEDFILE ] && [ $BINJOBCOUNT -eq 0 ] && [ $BINRESULTFILECOUNT -eq 0 ]; then

                    echo "     <status action=\"$(basename $BINSETTINGSFILE)\">failed"
                    echo "      <warning>"
                    echo "      FAILED: $(basename $BINSETTINGSFILE): RETRYING CLASSIFICATION. PREVIOUS JOB DID NOT PRODUCE OUTPUT (?!)"
                    echo "      </warning>"
                    echo "      <output>"                    
                    rm -fv $BINSUBMITTEDFILE
                    echo "      </output>"                    
                    echo "     </status>"

                # no output yet                has been submitted          no jobs present           results produced once
                elif [ ! -e $BINOUTPUTFILE ] && [ -e $BINSUBMITTEDFILE ] && [ $BINJOBCOUNT -eq 0 ] && [ $BINRESULTFILECOUNT -eq 1 ]; then

                    echo "     <status action=\"$(basename $BINSETTINGSFILE)\">failed"
                    echo "      <warning>"
                    echo "      FAILED: $(basename $BINSETTINGSFILE): RETRYING CLASSIFICATION"
                    echo "      </warning>"
                    echo "      <output>"                    
                    ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
                    ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "$BINRESULTFILEBASE" $BINSUBMITTEDFILE                            
                    rm -fv $BINSUBMITTEDFILE
                    echo "      </output>"                    
                    echo "     </status>"
                    
                # no output yet                has been submitted          no jobs present           results produced twice
                elif [ ! -e $BINOUTPUTFILE ] && [ -e $BINSUBMITTEDFILE ] && [ $BINJOBCOUNT -eq 0 ] && [ $BINRESULTFILECOUNT -eq 2 ]; then

                    echo "     <status action=\"$(basename $BINSETTINGSFILE)\">failed"
                    echo "      <warning>"
                    echo "      ABORTED: $(basename $BINSETTINGSFILE): FAILED TWICE"
                    echo "      </warning>"
                    echo "      <output>"                    
                    ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
                    ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "$BINRESULTFILEBASE" $BINSUBMITTEDFILE
                    echo "      </output>"                    
                    echo "     </status>"
                    
                    
                # output present
                elif [ -e $BINOUTPUTFILE ] ; then
                    
                    echo "     <status action=\"$(basename $BINSETTINGSFILE)\">completed"
                    #echo "      <message>"
                    #echo "      COMPLETED: $(basename $BINSETTINGSFILE)"
                    #echo "      </message>"
                    if [ -e $BINOVERVIEWPDFFILE ]; then
                        echo "     <file type=\"pdf\">$BINOVERVIEWPDFFILE</file>"
                    fi
                    if [ -e $BINSETTINGSFILE ]; then
                        echo "     <file type=\"txt\">$BINSETTINGSFILE</file>"
                    fi
                    
                    echo "     </status>"
                    
                else
                
                    echo "     <status action=\"$(basename $BINSETTINGSFILE)\">unknown"
                    echo "      <warning>"
                    echo "      UNKNOWN STATUS: $(basename $BINSETTINGSFILE)"
                    if [ -e $BINSETTINGSFILE ]; then
                        echo "        DEBUG: BINSETTINGSFILE=$BINSETTINGSFILE (present)"
                    else
                        echo "        DEBUG: BINSETTINGSFILE=$BINSETTINGSFILE (missing)"
                    fi
                    if [ -e $BINOUTPUTFILE ]; then
                        echo "        DEBUG: BINOUTPUTFILE=$BINOUTPUTFILE (present)"
                    else
                        echo "        DEBUG: BINOUTPUTFILE=$BINOUTPUTFILE (missing)"
                    fi
                    if [ -e $BINSUBMITTEDFILE ]; then
                        echo "        DEBUG: BINSUBMITTEDFILE=$BINSUBMITTEDFILE (present)"
                    else
                        echo "        DEBUG: BINSUBMITTEDFILE=$BINSUBMITTEDFILE (missing)"
                    fi
                    echo "        DEBUG: BINRESULTFILEBASE=$BINRESULTFILEBASE"
                    echo "        DEBUG: BINRESULTFILECOUNT-SEARCH-STRING=$BINRESULTFILEBASE*.results"                            
                    echo "        DEBUG: BINRESULTFILECOUNT=$BINRESULTFILECOUNT"
                    echo "        DEBUG: BINJOBCOUNT=$BINJOBCOUNT"

                    echo "      </warning>"
                    echo "      <output>"                            
                    ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
                    ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "$BINRESULTFILEBASE" $BINSUBMITTEDFILE                            
                    echo "      </output>"
                    
                    echo "     </status>"
                                            
                
                
                fi
             
            done #LOOP OVER BINSETTINGS FILES
            echo "     </status>"
                                
		fi # end of bins











        ###
        ### TRACKER
        ###
        
        # VARIABLES:
        ### NOTE THAT TRACKERSETTINGSFILE IS THE SUM OF SetTracker FILES IN THE INCLUDEDPATH AND IN THE PROJECTDIR!
        
        ### IF ANY SETTINGS FILE IS PRESENT, SUBMIT
        
        if [ $TRACKERSETTINGSFILE -gt 0 ]; then
             
            # should we make some special XML structure for the SVM files? group them together all in the status[@action='bin-correction']/status[@action='bin-correction-file...']
            # note that in this case we group status-elements together in a parent status field!!!

            echo "     <status action=\"tracker-settings\">"
            echo "      <message>"
            echo "    $TRACKERSETTINGSFILE tracker settings files found."
            echo "      </message>"
            
            # to avoid double listing of settings files if $INCLUDEDPATH and $PROJECTDIR are the same... 
        	if [ $INCLUDEDPATH -ef $PROJECTDIR ]; then
            	ALLTRACKERSETTINGSFILES=$(find $PROJECTDIR -maxdepth 1 -type f -name 'SetTracker_*.txt')
        	else
        		# otherwise settings files can be stored both in the project directory ($INCLUDEDPATH) and in the plate directory ($PROJECTDIR) (ugly variable names...)
        		ALLTRACKERSETTINGSFILES=$(find $INCLUDEDPATH $PROJECTDIR -maxdepth 1 -type f -name 'SetTracker_*.txt')
        	fi
        	
            for TRACKERSETTINGSFILE in $ALLTRACKERSETTINGSFILES; do

				# We could parse out the object name from the settings file, which looks something like this
				# "structTrackingSettings.ObjectName = 'Nuclei'" We need this to know the output name...
				TRACKEROBJECTNAME=$(grep -e 'structTrackingSettings.ObjectName' $TRACKERSETTINGSFILE | sed 's|structTrackingSettings.ObjectName\s*=\s*[^A-Za-z0-9]*\([A-Za-z0-9_]*\)[^A-Za-z0-9]*|\1|g') 
            	TRACKEROUTPUTFILE="${BATCHDIR}Measurements_${TRACKEROBJECTNAME}_TrackObjects_$(basename $TRACKERSETTINGSFILE .txt | sed 's|SetTracker_||g').mat"
                # If the tracker produces a movie, we might be able to link to this movie file from the website :)
                # TRACKEROVERVIEWPDFFILE="${POSTANALYSISDIR}Measurements_$(basename $TRACKERSETTINGSFILE .txt)_overview.pdf"
                # TRACKEROVERVIEWCSVFILE="${POSTANALYSISDIR}Measurements_$(basename $TRACKERSETTINGSFILE .txt)_overview.csv"
                TRACKERRESULTFILEBASE="TRACKER_$(basename $TRACKERSETTINGSFILE .txt | sed 's|SetTracker_||g')_"
                TRACKERSUBMITTEDFILE="${PROJECTDIR}/TRACKER_$(basename $TRACKERSETTINGSFILE .txt | sed 's|SetTracker_||g').submitted"
                TRACKERRUNLIMITFILE="${PROJECTDIR}/TRACKER_$(basename $TRACKERSETTINGSFILE .txt | sed 's|SetTracker_||g').runlimit"
                TRACKERRESULTFILECOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "$TRACKERRESULTFILEBASE*.results" | wc -l)
                #TRACKERJOBCOUNT=$(~/iBRAIN/countjobs.sh $(basename $TRACKERSETTINGSFILE))
                TRACKERJOBCOUNT=$(grep $(basename $TRACKERSETTINGSFILE) $JOBSFILE -c)
                if [ ! -d $POSTANALYSISDIR ]; then
                    mkdir -p $POSTANALYSISDIR
                fi
                
                if [ ! -e $TRACKERSUBMITTEDFILE ] && [ ! -e $TRACKEROUTPUTFILE ]; then
                    
                    echo "     <status action=\"$(basename $TRACKERSETTINGSFILE)\">submitting"
                    #echo "      <message>"
                    #echo "      SUBMITTING: $(basename $TRACKERSETTINGSFILE)"
                    #echo "      </message>"
                    echo "      <output>"    
                    TRACKERRESULTFILE="$TRACKERRESULTFILEBASE$(date +"%y%m%d%H%M%S").results"
                    # Always submit to 8h queue...
#                    if [ -e $TRACKERRUNLIMITFILE ]; then
bsub -W 8:00 -o "${BATCHDIR}$TRACKERRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
iBrainTrackerV1('${PROJECTDIR}','${TRACKERSETTINGSFILE}');
M_PROG"
#                    else
#bsub -W 1:00 -o "${BATCHDIR}$TRACKERRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
#iBrainTrackerV1('${PROJECTDIR}','${TRACKERSETTINGSFILE}');
#M_PROG"
#                	fi                    
                    touch $TRACKERSUBMITTEDFILE
                    echo "      </output>"     
                    if [ -e $TRACKERSETTINGSFILE ]; then
                        echo "     <file type=\"txt\">$TRACKERSETTINGSFILE</file>"
                    fi                                   
                    echo "     </status>"
                    
                    
                # no output yet                has been submitted          has jobs present        no output jet
                elif [ ! -e $TRACKEROUTPUTFILE ] && [ -e $TRACKERSUBMITTEDFILE ] && [ $TRACKERJOBCOUNT -gt 0 ] && [ $TRACKERRESULTFILECOUNT -eq 0 ]; then
                    
                    echo "     <status action=\"$(basename $TRACKERSETTINGSFILE)\">waiting"
                    echo "      <message>"
                    echo "      WAITING: $(basename $TRACKERSETTINGSFILE): ($TRACKEROBJECTNAME object) $TRACKERJOBCOUNT JOB(S) PRESENT"
                    echo "      </message>"
            		if [ -e $TRACKERSETTINGSFILE ]; then
                        echo "     <file type=\"txt\">$TRACKERSETTINGSFILE</file>"
                    fi
                    echo "     </status>"

                # no output yet                has been submitted          no jobs present           results never produced
                elif [ ! -e $TRACKEROUTPUTFILE ] && [ -e $TRACKERSUBMITTEDFILE ] && [ $TRACKERJOBCOUNT -eq 0 ] && [ $TRACKERRESULTFILECOUNT -eq 0 ]; then

                    echo "     <status action=\"$(basename $TRACKERSETTINGSFILE)\">failed"
                    echo "      <warning>"
                    echo "      FAILED: $(basename $TRACKERSETTINGSFILE): RETRYING TRACKING. PREVIOUS JOB DID NOT PRODUCE OUTPUT (?!)"
                    echo "      </warning>"
                    echo "      <output>"                    
                    rm -fv $TRACKERSUBMITTEDFILE
                    echo "      </output>"      
            		if [ -e $TRACKERSETTINGSFILE ]; then
                        echo "     <file type=\"txt\">$TRACKERSETTINGSFILE</file>"
                    fi
                    echo "     </status>"

                # no output yet                has been submitted          no jobs present           results produced once
                elif [ ! -e $TRACKEROUTPUTFILE ] && [ -e $TRACKERSUBMITTEDFILE ] && [ $TRACKERJOBCOUNT -eq 0 ] && [ $TRACKERRESULTFILECOUNT -eq 1 ]; then

                    echo "     <status action=\"$(basename $TRACKERSETTINGSFILE)\">failed"
                    echo "      <warning>"
                    echo "      FAILED: $(basename $TRACKERSETTINGSFILE): RETRYING TRACKING"
                    echo "      </warning>"
                    echo "      <output>"                    
                    ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
                    ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "$TRACKERRESULTFILEBASE" $TRACKERSUBMITTEDFILE                            
                    rm -fv $TRACKERSUBMITTEDFILE
                    echo "      </output>"   
            		if [ -e $TRACKERSETTINGSFILE ]; then
                        echo "     <file type=\"txt\">$TRACKERSETTINGSFILE</file>"
                    fi
                    echo "     </status>"
                    
                # no output yet                has been submitted          no jobs present           results produced twice
                elif [ ! -e $TRACKEROUTPUTFILE ] && [ -e $TRACKERSUBMITTEDFILE ] && [ $TRACKERJOBCOUNT -eq 0 ] && [ $TRACKERRESULTFILECOUNT -eq 2 ]; then

                    echo "     <status action=\"$(basename $TRACKERSETTINGSFILE)\">failed"
                    echo "      <warning>"
                    echo "      ABORTED: $(basename $TRACKERSETTINGSFILE): FAILED TWICE"
                    echo "      </warning>"
                    echo "      <output>"                    
                    ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
                    ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "$TRACKERRESULTFILEBASE" $TRACKERSUBMITTEDFILE
                    echo "      </output>"   
            		if [ -e $TRACKERSETTINGSFILE ]; then
                        echo "     <file type=\"txt\">$TRACKERSETTINGSFILE</file>"
                    fi
                    echo "     </status>"
                    
                    
                # output present
                elif [ -e $TRACKEROUTPUTFILE ] ; then
                    
                    echo "     <status action=\"$(basename $TRACKERSETTINGSFILE)\">completed"
                    #if [ -e $TRACKEROVERVIEWPDFFILE ]; then
                    #    echo "     <file type=\"pdf\">$TRACKEROVERVIEWPDFFILE</file>"
                    #fi
                    if [ -e $TRACKERSETTINGSFILE ]; then
                        echo "     <file type=\"txt\">$TRACKERSETTINGSFILE</file>"
                    fi
                    
                    echo "     </status>"
                    
                else
                
                    echo "     <status action=\"$(basename $TRACKERSETTINGSFILE)\">unknown"
                    echo "      <warning>"
                    echo "      UNKNOWN STATUS: $(basename $TRACKERSETTINGSFILE)"
                    if [ -e $TRACKERSETTINGSFILE ]; then
                        echo "        DEBUG: TRACKERSETTINGSFILE=$TRACKERSETTINGSFILE (present)"
                    else
                        echo "        DEBUG: TRACKERSETTINGSFILE=$TRACKERSETTINGSFILE (missing)"
                    fi
                    if [ -e $TRACKEROUTPUTFILE ]; then
                        echo "        DEBUG: TRACKEROUTPUTFILE=$TRACKEROUTPUTFILE (present)"
                    else
                        echo "        DEBUG: TRACKEROUTPUTFILE=$TRACKEROUTPUTFILE (missing)"
                    fi
                    if [ -e $TRACKERSUBMITTEDFILE ]; then
                        echo "        DEBUG: TRACKERSUBMITTEDFILE=$TRACKERSUBMITTEDFILE (present)"
                    else
                        echo "        DEBUG: TRACKERSUBMITTEDFILE=$TRACKERSUBMITTEDFILE (missing)"
                    fi
                    echo "        DEBUG: TRACKERRESULTFILEBASE=$TRACKERRESULTFILEBASE"
                    echo "        DEBUG: TRACKERRESULTFILECOUNT-SEARCH-STRING=$TRACKERRESULTFILEBASE*.results"                            
                    echo "        DEBUG: TRACKERRESULTFILECOUNT=$TRACKERRESULTFILECOUNT"
                    echo "        DEBUG: TRACKERJOBCOUNT=$TRACKERJOBCOUNT"

                    echo "      </warning>"
                    echo "      <output>"                            
                    ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
                    ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "$TRACKERRESULTFILEBASE" $TRACKERSUBMITTEDFILE                            
                    echo "      </output>"
					if [ -e $TRACKERSETTINGSFILE ]; then
                        echo "     <file type=\"txt\">$TRACKERSETTINGSFILE</file>"
                    fi
                    echo "     </status>"
                                            
                
                
                fi
             
            done #LOOP OVER TRACKERSETTINGS FILES
            echo "     </status>"
                                
		fi # end of TRACKER
















        ###
        ### CREATE CELLTYPE OVERVIEW
        ### INCLUDES THE FOLLOWING 4 MATLAB FUNCTIONS IN ONE JOB: 
        ###
        ### 1. Create_CellTypeClassificationPerColumn_iBRAIN
        ### 2. VirusScreen_Cluster_With_SVM_01
        ### 3. TraditionalPostClusterInfectionScoring_With_SVM
        ### 4. Create_CellTypeOverview_iBRAIN
        ###

		# BASICDATA_*.mat is required...        
		if [ $PLATEBASICDATACOUNT -gt 0 ]; then        
		
	        ### MORE SIMPLE VERSION, ALWAYS UPDATE Measurements_Nuclei_CellType_Overview.mat IF THERE ARE NEWER SVM FILES
	        ### THAN Measurements_Nuclei_CellType_Overview.mat
	        CELLTYPEOVERVIEWFILE="${BATCHDIR}Measurements_Nuclei_CellType_Overview.mat"
	        CELLTYPEOVERVIEWRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "CreateCellTypeOverview_*.results" | wc -l)
	        if [ -e $CELLTYPEOVERVIEWFILE ]; then
	        	NEWERSVMFILECOUNT=$(( $(find $BATCHDIR -maxdepth 1 -type f -newer $CELLTYPEOVERVIEWFILE -name "Measurements_SVM_*.mat" | wc -l) + 0))
	        	
	        	#if [ $(find $INCLUDEDPATH -maxdepth 1 -type f -cmin +480 -name "FuseBasicData_*.results") ]; then
	        	#	### [2010-02-18] TEMPORARY HACK, PAULI MADE GATHER_CELLTYPE_DATA_IBRAIN2 RESETTING ALL OLD MEASUREMENTS... 
		        #    echo "     <status action=\"celltype-overview-generation\">resetting"
		        #    echo "      <message>"
		        #    echo "    [2010-02-18] TEMPORARY HACK: UPDATING TO NEWER VERSION OF GATHER_CELLTYPE_DATA_IBRAIN2.M, resetting cell type overview"
		        #    echo "      </message>"
		        #    echo "      <output>"
		        #    rm -v ${PROJECTDIR}/CreateCellTypeOverview.submitted
		        #    rm -v ${BATCHDIR}CreateCellTypeOverview_*.results
		        #    rm -v ${BATCHDIR}Measurements_Nuclei_CellType_Overview.mat
		        #    rm -v ${BATCHDIR}Measurements_Nuclei_CellTypeClassificationPerColumn.mat
		        #    echo "      </output>"
	            #    echo "     </status>"
	        	#fi
	        		        	
	        	if [ $NEWERSVMFILECOUNT -gt 0 ]; then
		            echo "     <status action=\"celltype-overview-generation\">resetting"
		            echo "      <message>"
		            echo "    UPDATING: new SVM files found, resetting cell type overview"
		            echo "      </message>"
		            echo "      <output>"
		            rm -v ${PROJECTDIR}/CreateCellTypeOverview.submitted
		            rm -v ${BATCHDIR}CreateCellTypeOverview_*.results
		            rm -v ${BATCHDIR}Measurements_Nuclei_CellType_Overview.mat
		            rm -v ${BATCHDIR}Measurements_Nuclei_CellTypeClassificationPerColumn.mat
		            echo "      </output>"
	                echo "     </status>"		            
	        	fi  
	        else
	            NEWERSVMFILECOUNT=$(( $(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_SVM_*.mat" | wc -l) + 0))
	        fi
	        
	        
	        # VARIABLES:
	        # set BOOLALLSVMSPRESENT to 1 is there are SVM results of all 4 required SVM classifications: interphase, mitotic, apoptotic, and blobs.
	        #
	        # [BS081107] note that if there is any of these SVM files newer than the existing celltype overview, these data need to be updated!
	        # if we need an update, remove .submitted, .results and output.mat files.
	        #if  [ $(find $BATCHDIR -maxdepth 1 -type f -iname "Measurements_SVM_*interphase*.mat" | wc -l) -gt 0 ] &&
	        #    [ $(find $BATCHDIR -maxdepth 1 -type f -iname "Measurements_SVM_*mitotic*.mat" | wc -l) -gt 0 ] &&
	        #    [ $(find $BATCHDIR -maxdepth 1 -type f -iname "Measurements_SVM_*apoptotic*.mat" | wc -l) -gt 0 ] &&
	        #    [ $(find $BATCHDIR -maxdepth 1 -type f -iname "Measurements_SVM_*blob*.mat" | wc -l) -gt 0 ]; then
	        #                    	
	        #    BOOLALLSVMSPRESENT=1
	        #    
	        #    # if so, we might just as well check for the other parameters
	        #    CELLTYPEOVERVIEWCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_Nuclei_CellType_Overview.mat" | wc -l)
	        #	 CELLTYPEOVERVIEWRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "CreateCellTypeOverview_*.results" | wc -l)
	
	        #    CELLTYPEOVERVIEWSUBMITTEDFILE="${PROJECTDIR}/CreateCellTypeOverview.submitted"
	        #    CELLTYPEOVERVIEWFILE="${BATCHDIR}Measurements_Nuclei_CellType_Overview.mat"
	
	        #    # if the output already exists, see if we need to update the celltype overview creation
	        #    # right now, we only update if there's SVM training for Interphase/Mitotic/Apoptotic/Blob, but if this function is updated to include 
	        #    # all SVM files, we should always check if there's ANY newer SVM files at any time. 
	        #    if [ ! $CELLTYPEOVERVIEWCOUNT -eq 0 ] && [ ! $CELLTYPEOVERVIEWRESULTCOUNT -eq 0 ] && [ -e $CELLTYPEOVERVIEWSUBMITTEDFILE ]; then
	        #        NEWERSVMFILECOUNT1=$(( $(find $BATCHDIR -maxdepth 1 -type f -newer $CELLTYPEOVERVIEWFILE -name "Measurements_SVM_*.mat" | wc -l) + 0))
	        #        NEWERSVMFILECOUNT2=$(( $(find $BATCHDIR -maxdepth 1 -type f -newer $CELLTYPEOVERVIEWSUBMITTEDFILE -name "Measurements_SVM_*.mat" | wc -l) + 0))
	        #        if [ ! $NEWERSVMFILECOUNT1 -eq 0 ] && [ ! $NEWERSVMFILECOUNT2 -eq 0 ]; then
		    #            echo "     <status action=\"celltype-overview-generation\">resetting"
		    #            echo "      <message>"
		    #            echo "    UPDATING: SVM files found that are newer than Measurements_Nuclei_CellType_Overview.mat, resetting CellType overview generation"
		    #            echo "      </message>"
		    #            echo "      <output>"
		    #            rm -v ${PROJECTDIR}/CreateCellTypeOverview.submitted
		    #            rm -v ${BATCHDIR}CreateCellTypeOverview_*.results
		    #            rm -v ${BATCHDIR}Measurements_Nuclei_CellType_Overview.mat
	        #            echo "      </output>"
		    #			CELLTYPEOVERVIEWCOUNT=0
			#			CELLTYPEOVERVIEWRESULTCOUNT=0
	        #        fi
	        #    fi
	        #                        
	        #else
	        #    BOOLALLSVMSPRESENT=0
	        #    CELLTYPEOVERVIEWCOUNT=0
	        #    CELLTYPEOVERVIEWRESULTCOUNT=0
	        #fi
	        
	        # output to check for:
	        # Measurements_Nuclei_CellType_Overview.mat
	        #                 
	        if [ $NEWERSVMFILECOUNT -gt 0 ] && [ ! -e $PROJECTDIR/CreateCellTypeOverview.submitted ]; then
	             
	            echo "     <status action=\"celltype-overview-generation\">submitting"
	            echo "      <output>"                    
	
	            ### NOTE: Create_CellType_Overview and Create_CellType_ClassificationPerColumn have been replaced
	            ### by Gather_CellType_Data!
	            CELLTYPEOVERVIEWRESULTFILE="CreateCellTypeOverview_$(date +"%y%m%d%H%M%S").results"
bsub -W 1:00 -o "${BATCHDIR}$CELLTYPEOVERVIEWRESULTFILE" "matlab -singleCompThread -nodisplay -nojvm << M_PROG
Gather_CelltypeData_iBRAIN2('${BATCHDIR}');
M_PROG"
	            touch $PROJECTDIR/CreateCellTypeOverview.submitted
	            echo "      </output>"                    
	            echo "     </status>"                      
	            
	        ### CHECK CreateCellTypeOverview HAS BEEN SUBMITTED BUT DID NOT PRODUCE OUTPUT FILES YET
	        elif [ $NEWERSVMFILECOUNT -gt 0 ] && [ ! -e $CELLTYPEOVERVIEWFILE ] && [ -e $PROJECTDIR/CreateCellTypeOverview.submitted ] && [ $CELLTYPEOVERVIEWRESULTCOUNT -eq 0 ]; then
	            
	            echo "     <status action=\"celltype-overview-generation\">waiting"
	            echo "      <output>"                    
	
	            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
	            if [ $PLATEJOBCOUNT -eq 0 ]; then
	                echo "    ALERT: iBRAIN IS WAITING FOR CreateCellTypeOverview, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
	                rm -f $PROJECTDIR/CreateCellTypeOverview.submitted
	            fi
	            
	            echo "      </output>"                    
	            echo "     </status>"                     
	            
	        ### CHECK CreateCellTypeOverview HAS BEEN COMPLETED BUT FAILED TO PRODUCE OUTPUT FILES
	        elif [ $NEWERSVMFILECOUNT -gt 0 ] && [ ! -e $CELLTYPEOVERVIEWFILE ] && [ -e $PROJECTDIR/CreateCellTypeOverview.submitted ] && [ $CELLTYPEOVERVIEWRESULTCOUNT -gt 0 ]; then
	            
	            echo "     <status action=\"celltype-overview-generation\">failed"
	            echo "      <warning>"
	            echo "    ALERT: celltype overview generation FAILED"
	            echo "      </warning>"
	            echo "      <output>"                    
	
	            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
	            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "CreateCellTypeOverview_" $PROJECTDIR/CreateCellTypeOverview.submitted
	                                
	            ## TEMP BS_BUGFIX. RESET ALL CRASHED CELLTYPEOVERVIEWS!
	            # echo "APPLYING TEMPORARY BUGFIX. RESETTING ALL CRASHED CreateCellTypeOverview JOBS"
	            # rm -vf $PROJECTDIR/CreateCellTypeOverview.submitted
	            # rm -vf $BATCHDIR/CreateCellTypeOverview_*.results
	                                
	            echo "      </output>"                    
	            echo "     </status>"                     
	
	            
	        ### IF CreateCellTypeOverview FILE IS PRESENT, FLAG AS COMPLETED
	        
	        elif [ $NEWERSVMFILECOUNT -eq 0 ] && [ -e $CELLTYPEOVERVIEWFILE ]; then
	     
	            echo "     <status action=\"celltype-overview-generation\">completed"
	            #echo "      <message>"
	            # (This was a request from Pauli... Disabled now)
	            #TIMELASTMODIFIEDRESULTS=$(stat -c %y ${BATCHDIR}Measurements_Nuclei_CellType_Overview.mat)	            
	            #echo "    Measurements_Nuclei_CellType_Overview.mat created on $TIMELASTMODIFIEDRESULTS"
	            #echo "      </message>"	            
 	            echo "     </status>"   
	
	        elif [ $NEWERSVMFILECOUNT -eq 0 ] && [ ! -e $CELLTYPEOVERVIEWFILE ]; then
	            
	            # nothing going on, moving on...
	            echo " "   
	            
	        else
	            
	            echo "     <status action=\"celltype-overview-generation\">unknown"
	            echo "      <warning>"
	            echo "  UNKNOWN STATUS FOR celltype-overview-generation ACTION"
	            #echo "  APPLYING TEMPORARY BUGFIX TO RERUN CRASHED GATHERCELLTYPE OVERVIEW STUFF"                
	            echo "      </warning>"
	            echo "      <output>"
	            ### TEMPORARY BS HACK TO FIX BUG IN CellypeOVERVIEW GENERATION... ###
	            # rm -v $PROJECTDIR/CreateCellTypeOverview.submitted
	            #####################################################################
	            if [ -e $PROJECTDIR/CreateCellTypeOverview.submitted ]; then
	            echo "    CreateCellTypeOverview.submitted IS PRESENT"
	            else
	            echo "    CreateCellTypeOverview.submitted IS NOT PRESENT"   
	            fi
	            if [ -e $CELLTYPEOVERVIEWFILE ]; then
	            echo "    $CELLTYPEOVERVIEWFILE IS PRESENT"
	            else
	            echo "    $CELLTYPEOVERVIEWFILE IS NOT PRESENT"   
	            fi                
	            echo "    NEWERSVMFILECOUNT = $NEWERSVMFILECOUNT"
	            echo "    CELLTYPEOVERVIEWRESULTCOUNT = $CELLTYPEOVERVIEWRESULTCOUNT"
	            
	
	            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
	            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "CreateCellTypeOverview_" $PROJECTDIR/CreateCellTypeOverview.submitted
	                                
	            echo "      </output>"                    
	            echo "     </status>"     
	                            
	        fi
		fi




        
        
        fi # end check if stage 1 has been completed. end of stage 2.
        
        
        
        ##########################################
        ### DISPLAY DEBUG IF WARNING FLAG IS 1 ###
        
        if [ $WARNINGFLAG -eq 1 ]; then
        	echo " <!--"
            echo "      DEBUG: PROJECTDIR=$PROJECTDIR"
            echo "      DEBUG: BATCHDIR=$BATCHDIR"
            echo "      DEBUG: TIFFDIR=$TIFFDIR"
            echo "      DEBUG: COMPLETEFILECHECK=$(($COMPLETEFILECHECK))"
            echo "      DEBUG: PRECLUSTERCHECK=$(($PRECLUSTERCHECK))"
            echo "      DEBUG: BATCHJOBCOUNT=$(($BATCHJOBCOUNT))"
            echo "      DEBUG: OUTPUTCOUNT=$(($OUTPUTCOUNT))"
            echo "      DEBUG: CPCLUSTERRESULTCOUNT=$(($CPCLUSTERRESULTCOUNT))"
            echo "      DEBUG: DATAFUSIONRESULTCOUNT=$(($DATAFUSIONRESULTCOUNT))"
            echo "      DEBUG: EXPECTEDMEASUREMENTS=$(($EXPECTEDMEASUREMENTS))"
            echo "      DEBUG: FAILEDDATACHECKRESULTCOUNT=$(($FAILEDDATACHECKRESULTCOUNT))"
            echo "      DEBUG: DATAFUSIONCHECKRESULTCOUNT=$(($DATAFUSIONCHECKRESULTCOUNT))"
            echo "      DEBUG: INFECTIONCOUNT=$(($INFECTIONCOUNT))"
            echo "      DEBUG: INFECTIONRESULTCOUNT=$(($INFECTIONRESULTCOUNT))"
            echo "      DEBUG: OUTOFFOCUSCOUNT=$(($OUTOFFOCUSCOUNT))"
            echo "      DEBUG: OUTOFFOCUSRESULTCOUNT=$(($OUTOFFOCUSRESULTCOUNT))"
            echo "      DEBUG: PLATEOVERVIEWCOUNT=$(($PLATEOVERVIEWCOUNT))"
            echo "      DEBUG: PLATEOVERVIEWRESULTCOUNT=$(($PLATEOVERVIEWRESULTCOUNT))"
            echo "      DEBUG: NORMALIZATIONCOUNT=$(($NORMALIZATIONCOUNT))"
            echo "      DEBUG: NORMALIZATIONRESULTCOUNT=$(($NORMALIZATIONRESULTCOUNT))"
            echo "      DEBUG: SVMSETTINGSFILE=$SVMSETTINGSFILE"
            echo "      DEBUG: SVMCOUNT=$(($SVMCOUNT))"
            echo "      DEBUG: SVMRESULTCOUNT=$(($SVMRESULTCOUNT))"
            echo " -->"
        fi
        
        #PLATEJOBCOUNT=$(~/iBRAIN/countjobs.sh $PROJECTDIR)
        PLATEJOBCOUNT=$(grep "$PROJECTDIR" $JOBSFILE -c)
        # substract one job count if the PROJECTDIR equals the INCLUDEDPATH
        if [ $(echo $PROJECTDIR | sed 's|/|__|g') == $(echo $INCLUDEDPATH | sed 's|/|__|g') ]; then
            PLATEJOBCOUNT=$(( $PLATEJOBCOUNT - 1 ))
        fi             
        echo "     <job_count_total>$PLATEJOBCOUNT</job_count_total>"            
        
        echo "    </plate>"
    done # end loop over TIFF folders
    echo "   </plates>"
    
    #######################################################
    ### SUBMIT FUSE_BASIC_DATA IF FUSEBASICDATAFLAG > 0 ###
    SEARCHSTRING="fuse_basic_data_v4('${INCLUDEDPATH}')"
    #FUSEBASICDATAJOBCOUNT=$(($(~/iBRAIN/countjobs.sh $SEARCHSTRING) + 0))
    FUSEBASICDATAJOBCOUNT=$(($(grep $SEARCHSTRING $JOBSFILE -c) + 0))
    if [ ! -w $INCLUDEDPATH ]; then
    	
        echo "     <status action=\"fuse-basic-data\">paused"
        echo "      <message>"
        echo "  NOT SUBMITTING FUSE_BASIC_DATA ON $SEARCHTARGET, DIRECTORY IS NOT WRITABLE BY iBRAIN"
        echo "      </message>"
        echo "     </status>"              	
    	

    else
        if [ $FUSEBASICDATAFLAG -gt 0 ]; then

            if [ ! -e $INCLUDEDPATH/FuseBasicData.submitted ] && [ $FUSEBASICDATAJOBCOUNT -eq 0 ]; then

                echo "     <status action=\"fuse-basic-data\">cleaning-up"
                #echo "      <message>"
                #echo "  CLEANING UP OLD FUSE_BASIC_DATA RESULT FILES IN $SEARCHTARGET"
                #echo "      </message>"
                echo "      <output>"                    
                find $INCLUDEDPATH -maxdepth 1 -type f -cmin +120 -name "FuseBasicData_*.results" -exec rm {} \;
                echo "      </output>"                    
                echo "     </status>"               

                echo "     <status action=\"fuse-basic-data\">submitting"
                #echo "      <message>"
                #echo "  SUBMITTING FUSE_BASIC_DATA ON $SEARCHTARGET"
                #echo "      </message>"
                echo "      <output>"                    
                #echo "  FOUND $FUSEBASICDATAFLAG BASICDATA FILES NEWER THAN $PROJECTBASICDATAFILE"      
                bsub -W 8:00 -o "$INCLUDEDPATH/FuseBasicData_$(date +"%y%m%d%H%M%S").results" "matlab -singleCompThread -nodisplay -nojvm << M_PROG
fuse_basic_data_v4('${INCLUDEDPATH}');
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
        #else
        #
            #if [ -e $INCLUDEDPATH/FuseBasicData.submitted ]; then
            #    echo "     <status action=\"fuse-basic-data\">resetting"
            #    echo "      <output>"                    
            #    rm $INCLUDEDPATH/FuseBasicData.submitted
            #    echo "      </output>"                    
            #    echo "     </status>"                
            #fi                 
        fi
    fi
    
    #PROJECTJOBCOUNT=$(~/iBRAIN/countjobs.sh $INCLUDEDPATH)
    ALLPROJECTJOBCOUNT=$(grep "$INCLUDEDPATH" $JOBSFILE -c)
    echo "<!-- ALLPROJECTJOBCOUNT=$ALLPROJECTJOBCOUNT -->"
    IBRAINPROJECTJOBCOUNT=$(grep "$PROJECTXMLDIR" $JOBSFILE -c)
    echo "<!-- IBRAINPROJECTJOBCOUNT=$IBRAINPROJECTJOBCOUNT-->"    
    PROJECTJOBCOUNT=$(($ALLPROJECTJOBCOUNT - $IBRAINPROJECTJOBCOUNT))
    echo "   <job_count_total>$PROJECTJOBCOUNT</job_count_total>"
    
    # clean up jobsfile
    echo "   <!-- cleaning up jobsfile"
    rm -f $JOBSFILE >& /dev/null
    echo "   -->"
        
else # if [ -d $INCLUDEDPATH ]; then
    #echo "*** ERROR: $INCLUDEDPATH: DOES NOT EXIST"
    echo "   <path>$INCLUDEDPATH</path>"
    echo "   <warning type=\"InvalidPath\">$INCLUDEDPATH DOES NOT EXIST</warning>"
fi



echo "  </project>"
echo " "


exit 0;
