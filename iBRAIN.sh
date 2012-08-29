#!/bin/bash
#
# iBRAIN.sh
# 
# 120822: renamed into iBRAIN.sh
#
# 081009: udpate: split iBRAIN.sh (wrapper) and iBRAIN_project.sh, and store iBRAIN_project.sh output as project specific XML
#   Preferably, we only store the per project output if the data has changed, so we must do a 'diff -b -i -B old.xml new.xml'
#	to check for this, and only store differences. Note that we should therefore not include any now-dates etc. in the project.xml 
#   output.
#
# 081023: update: We can actually submit the ibrain_project.sh as a job to the nodes. This way, we parrallelize the checking, and 
#   we loose the annoying problem that bigger projects block the analysis of smaller projects. Gotta think what the consequences 
#   are for the wrapper.html creation... Let's see.   


#############################################
### INCLUDE IBRAIN CONFIGURATION

# Best case scenario if we stay inside ROOT (thus relative pathnames will work).
if [ -d "$IBRAIN_ROOT" ]; then
    cd $IBRAIN_ROOT
else
    echo "Aborting $(basename $0) ($IBRAIN_ROOT folder does not exists)"
    exit 1
fi

# Find and include configuration.
if [ ! "$IBRAIN_ROOT" ]; then 
    echo "!$IBRAIN_ROOT"
    IBRAIN_ROOT=$(dirname `readlink -m $0`)
    if [ -f $IBRAIN_ROOT/etc/config ]; then
        . $IBRAIN_ROOT/etc/config
    else
        echo "Aborting $(basename $0) (missing configuration at $IBRAIN_ROOT/etc/config)"
        exit 1
    fi
fi
# Assume configuration is set by this point.
# TODO: implement and run configuration check function here. 


#############################################
### CHECK IF IBRAIN IS ALREADY RUNNING. 
### ONLY START IF NO INSTANCES ARE PRESENT
#INSTANCES=$( ps -u $IBRAIN_USER | grep $(basename $0 .sh) -c )
INSTANCES=$( pidof $(basename $0) | wc -w )

### current instance will be 2 for some reason, so more than 2 will be other iBRAIN.sh instances
### this should not be XML since this will never be included in the log files.
### (The iBRAIN cronjob checks for this output, if it starts with "Aborting:" it will not process further to prevent
### the login nodes from getting overloaded with requests/actions... which happened to the Hreidar nodes once)
if [ $INSTANCES -gt 2 ]; then
    echo "Aborting: $(basename $0) is already running (total: $INSTANCES instances)"
    echo "  INSTANCES: $INSTANCES"
    echo "  HOSTNAME: $HOSTNAME"    
    exit 1
fi
#############################################


########################
### START iBRAIN RUN ###

# initialize XML and reference xsl file for formatting
echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
echo "<?xml-stylesheet type=\"text/xsl\" href=\"../wrapper.xsl\"?>"
echo "<ibrain_log>"

### GET OVERVIEW OF JOBS ONLY ONCE, AND RE-PARSE PER PROJECT, 
### IN STEAD OF QUERYING ALL JOBS FOR EACH PROJECT.
PRESENTJOBS=$(bjobs -w 1> $IBRAIN_LOG_PATH/bjobsw.txt)
RUNNINGJOBS=$(bjobs -rw 1> $IBRAIN_LOG_PATH/bjobsrw.txt)
ALLJOBS=$(bjobs -aw 1> $IBRAIN_LOG_PATH/bjobsaw.txt)

echo " <ibrain_meta>"
echo "  <author>Berend Snijder</author>"
echo "  <version>2012-03-27</version>"
echo "  <date_last_modified>$(stat $0 | grep Modify | awk '{print $2,$3}')</date_last_modified>"
echo "  <start>$(date +"%y%m%d %H:%M:%S")</start>"
echo "  <host_name>$HOSTNAME</host_name>"
echo "  <script_name>$(basename $0)</script_name>"

TOTALJOBS=`busers | grep $IBRAIN_USER | awk '{print $4}'`
RUNNINGJOBS=`busers | grep $IBRAIN_USER | awk '{print $6}'`
JOBCOUNTFILE="$IBRAIN_DATABASE_PATH/jobs.txt"
INCLUDEDPATHSFILE="$IBRAIN_ETC_PATH/paths.txt"
LOGFILEPATH="$IBRAIN_ETC_PATH/"
PROJECTXMLPATH="$IBRAIN_DATABASE_PATH/project_xml"
WRAPPERXMLPATH="$IBRAIN_DATABASE_PATH/wrapper_xml"
PRECLUSTERBACKUPPATH="$IBRAIN_ROOT/pipelines/"
MATLABCODEPATH="$IBRAIN_ROOT/bin/matlab/"
PROJECTXMLXSLFILE="$IBRAIN_DATABASE_PATH/project.xsl"

echo "  <job_count_running>$RUNNINGJOBS</job_count_running>"
echo "  <job_count_total>$TOTALJOBS</job_count_total>"
echo "  <logfile_path>$LOGFILEPATH</logfile_path>"
echo "  <pipeline_backup_path>$PRECLUSTERBACKUPPATH</pipeline_backup_path>"
echo "  <included_paths_file>$INCLUDEDPATHSFILE</included_paths_file>"
echo "  <project_xml_path>$PROJECTXMLPATH</project_xml_path>"
echo "  <wrapper_xml_path>$WRAPPERXMLPATH</wrapper_xml_path>"
echo "  <projext_xml_xsl_file>$PROJECTXMLXSLFILE</projext_xml_xsl_file>"

###
# Check if included paths file is present, error if not..
if [ -e $INCLUDEDPATHSFILE ]; then
    echo "  <cfg_path_file>$INCLUDEDPATHSFILE</cfg_path_file>"	
else
    echo "  <error type=\"CouldNotReadCgfPathsFile\">"
	echo "ABORTING iBRAIN $INCLUDEDPATHSFILE COULD NOT BE READ"
	echo "  PATHS.CFG COULD NOT BE READ FROM $INCLUDEDPATHSFILE"
	echo "  Is the NAS not mounted properly on the cluster perhaps?"
    echo "  </error>"
    echo " </ibrain_meta>"
    echo "</ibrain_log>"    
	exit 1
fi
###

###
# check if there are output files that are bigger than 1G big... if so, kill corresponding job
for iOutputFile in $(find ~/.lsbatch/ -size +1G 2> /dev/null); do
	FILEJOBID=$(echo $iOutputFile | sed 's/[0-9]*\.\([0-9]*\)\.out/\1/g')
    echo "  <error type=\"TooBigOutputFile\">"
	echo "KILLING JOB $FILEJOBID, BECAUSE OUTPUT FILE $iOutputFile WAS GETTING BIGGER THAN 1GB!"
	mail -s "iBRAIN: $(basename $0): KILLED JOB $FILEJOBID, OUTPUT FILE TOO BIG!" "snijder@imsb.biol.ethz.ch" < bjobs -l $FILEJOBID	
	JOBDESCRIPTION:
	bjobs -w $FILEJOBID
	bkill $FILEJOBID
	echo "</output>"
    echo "  </error>"
done
###

###
# report disk space free for share-2 & share-3, and set panic 
# switch ALLOWSUBMISSION to 0 if there is not enough space 
# left free.
ALLOWSUBMISSION=1
if [ -e $IBRAIN_LOG_PATH/diskusage.txt ]; then
	SHARE2FREE=$(grep "/BIOL/imsb/fs2/bio3/bio3" $IBRAIN_LOG_PATH/diskusage.txt | awk '{print $4}')
	SHARE2TOTAL=$(grep "/BIOL/imsb/fs2/bio3/bio3" $IBRAIN_LOG_PATH/diskusage.txt | awk '{print $2}')
	echo "  <share_2_free>$SHARE2FREE</share_2_free>"
	echo "  <share_2_total>$SHARE2TOTAL</share_2_total>"
	SHARE3FREE=$(grep "/BIOL/imsb/fs3/bio3/bio3" $IBRAIN_LOG_PATH/diskusage.txt | awk '{print $4}')
	SHARE3TOTAL=$(grep "/BIOL/imsb/fs3/bio3/bio3" $IBRAIN_LOG_PATH/diskusage.txt | awk '{print $2}')
	echo "  <share_3_free>$SHARE3FREE</share_3_free>"
	echo "  <share_3_total>$SHARE3TOTAL</share_3_total>"

	# check if there is enough free space
	if [ $SHARE2FREE -lt 100000000 -o $SHARE3FREE -lt 100000000 ]; then
	    echo "  <error type=\"NotEnoughDiskSpace\">"
		echo "ABORTING iBRAIN BECAUSE THERE IS NOT ENOUGH DISK SPACE FREE!"
		echo "  KBYTES FREE ON SHARE-2-$ = $SHARE2FREE."
		echo "  KBYTES FREE ON SHARE-3-$ = $SHARE3FREE."
		echo "  PLEASE CLEAR UP SOME SPACE BEFORE IBRAIN CAN CONTINUE."
		echo "  iBRAIN WILL NOW KILL ALL CURRENT JOBS... (well I say, that's rather extreme old chap!)"
		echo "<output>"
		bkill 0

		# if this flag is not present, sent a mail to the entire lab at once!
		if [ ! -e $IBRAIN_LOG_PATH/sentmailtoentirelab.submitted ]; then
			touch $IBRAIN_LOG_PATH/sentmailtoentirelab.submitted
			echo -e "Hi all,\n\nThere is not enough free space on our NAS shares. Here is how it breaks down:\n\nKBYTES FREE ON SHARE-2-$ = $SHARE2FREE.\nKBYTES FREE ON SHARE-3-$ = $SHARE3FREE.\n\nThis is an automatically generated message. See http://www.ibrain.ethz.ch/explorer for more details.\n\nKind regards,\nBerend." | mail -s "iBRAIN: PANIC! NOT ENOUGH FREE SPACE ON NAS SHARES!" pelkmans_lab@imls.lists.uzh.ch 
		fi

		echo "empty mail." | mail -s "iBRAIN: $(basename $0): PANIC! NOT ENOUGH FREE SPACE ON NAS SHARES!" snijder@imsb.biol.ethz.ch
		echo "</output>"
	    echo "  </error>"
	    #echo " </ibrain_meta>"
	    #echo "</ibrain_log>"    
		#exit 1
		ALLOWSUBMISSION=0
	elif [ -e $IBRAIN_LOG_PATH/sentmailtoentirelab.submitted ]; then
		# if there is enough free space, remove this flag if it exists, so that next time we run out of space, the e-mail will to the entire pelkmans_group will be sent ones.
		rm $IBRAIN_LOG_PATH/sentmailtoentirelab.submitted
	fi
fi
###

### PARSE ALL QUEUED JOBS FOR UNIQUE JOB NAMES/PROCESSES/ETC.
echo "  <job_overview>"
echo "   <running>"
~/iBRAIN/categorizejobs2.sh $IBRAIN_LOG_PATH/bjobsrw.txt
echo "   </running>"
echo "   <all>"
~/iBRAIN/categorizejobs2.sh $IBRAIN_LOG_PATH/bjobsw.txt
echo "   </all>"
echo "  </job_overview>"

### Let's add a little block that links to the latest result files ran on the Brutus cluster. 
### Note, this is experimental as of 090803, and should be checked later on, to see if it's still working...
# ~/iBRAIN/report_latest_resultfiles.sh

echo " </ibrain_meta>"
echo " <projects>"




### USE SED TO FILTER OUT CONTROL CHARACTERS FROM FOREING FILE FORMATS
### AND LOOP OVER EACH ENTRY IN THE INCLUDEDPATHSFILE
for INCLUDEDPATH in $(sed -e 's/[[:cntrl:]]//g' $INCLUDEDPATHSFILE); do

    # REMOVE TRAILING SLASH IF PRESENT 
    INCLUDEDPATH=$(echo $INCLUDEDPATH | sed 's|/$||g')

    # Start project output
    echo "  <project>"
    echo "   <path>$INCLUDEDPATH</path>"
   
   # IF INCLUDEDPATH IS A VALID DIRECTORY
    if [ -d $INCLUDEDPATH ]; then
        
        # create the project xml output directory
        PROJECTXMLDIR="$PROJECTXMLPATH/$(echo $INCLUDEDPATH | sed 's|/|__|g')"
        if [ ! -d $PROJECTXMLDIR ]; then
        	mkdir -p $PROJECTXMLDIR
        fi 
        
        # unique and stable identifier for each project, use the inode number of the projectxmldirectory
        PROJECTID=$(stat $PROJECTXMLDIR -c '%i')
        echo "   <project_id>$PROJECTID</project_id>"
        
        # get the number of ibrain_project.sh jobs running for this projectxmldir
        # add forward slash to end of grep string to prevent partial job-name matches from being counted 
        IBRAINPROJECTJOBCOUNT=$(grep ${PROJECTXMLDIR} $IBRAIN_LOG_PATH/bjobsw.txt -c)
        ALLIBRAINPROJECTJOBCOUNTS=$(grep ${PROJECTXMLDIR} $IBRAIN_LOG_PATH/bjobsaw.txt -c)
        RUNNINGIBRAINPROJECTJOBCOUNT=$(grep ${PROJECTXMLDIR} $IBRAIN_LOG_PATH/bjobsrw.txt -c)        
        
        # store the last modified date of the project
        echo "   <date_last_modified>$(stat $INCLUDEDPATH | grep Modify | awk '{print $2,$3}')</date_last_modified>"        
        
        # find the SECOND most recent project.xml file
        # (NOTE, THERE'S A RISK HERE THAT WE ARE CHECKING THE .XML FILE THAT IS CURRENTLY BEING PRODUCED! AVOID THIS!!)
        if [ $RUNNINGIBRAINPROJECTJOBCOUNT -eq 0 ]; then
        	LATESTPROJECTXMLOUTPUT=$(ls $PROJECTXMLDIR/*_project.xml 2>/dev/null | tail -1)
        else
            LATESTPROJECTXMLOUTPUT=$(ls $PROJECTXMLDIR/*_project.xml 2>/dev/null | tail -2 | head -n 1)
        fi

        if [ -e "$PROJECTXMLDIR/index.html" ]; then
            LATESTPROJECTHTMLOUTPUT="$PROJECTXMLDIR/index.html"
            echo "   <latest_project_html_file>$LATESTPROJECTHTMLOUTPUT</latest_project_html_file>"
        else
            LATESTPROJECTHTMLOUTPUT=""
        fi

        BOOLCHECKINGSEEMSFUTILE=0
        if [ "$LATESTPROJECTXMLOUTPUT" ] && [ -e "$LATESTPROJECTXMLOUTPUT" ]; then 
	        ERRORCOUNT=$(grep "<warning>" "$LATESTPROJECTXMLOUTPUT" -c)
	        PLATECOUNT=$(grep "<plate>" "$LATESTPROJECTXMLOUTPUT" -c)

            # [NEW BS THOUGHT]: To prevent endless resubmission of checking on iBRAIN projects that have errors, we can see if there are more than 4 project.xml files, if the oldest and newest were checked within 1h of each other, and if all of them reported 0 jobs running. If so, do not check this project again...
            # The following line will be empty if all project.xml reported no jobs running anywhere.
            if [ $(ls $PROJECTXMLDIR/*_project.xml 2>/dev/null | wc -l) -gt 4 ] && [ $(find $PROJECTXMLDIR -maxdepth 1 -type f -mmin +90 -name "*_project.xml" | wc -l) -eq 0 ]; then
                if [ $(grep "<job_count_total>" $PROJECTXMLDIR/*_project.xml | grep -v "<job_count_total>0</job_count_total>" -c) -eq 0 ]; then
                    BOOLCHECKINGSEEMSFUTILE=1
                fi
            fi

        else
           ERRORCOUNT=0;
           PLATECOUNT=0;
        fi
        
        echo "   <warning_count>$ERRORCOUNT</warning_count>"
        echo "   <plate_count>$PLATECOUNT</plate_count>"
        echo "   <current_project_xml_file>$LATESTPROJECTXMLOUTPUT</current_project_xml_file>"
                
        
        # store job_counts: running, present within last hour, and present. Note adding a slash to the searchstring would make it more specific...
        # Currently Running
        echo "   <job_count_running>$(( $(grep $INCLUDEDPATH $IBRAIN_LOG_PATH/bjobsrw.txt -c) - $RUNNINGIBRAINPROJECTJOBCOUNT ))</job_count_running>"
        # Total present within last hour
        echo "   <job_count_total>$(( $(grep $INCLUDEDPATH $IBRAIN_LOG_PATH/bjobsaw.txt -c) - $ALLIBRAINPROJECTJOBCOUNTS ))</job_count_total>"
        # Total currently present
        CURRENTJOBCOUNT=$(($(grep $INCLUDEDPATH $IBRAIN_LOG_PATH/bjobsw.txt -c) - $IBRAINPROJECTJOBCOUNT))
        echo "   <job_count_present>$CURRENTJOBCOUNT</job_count_present>"
        

        ########## DISCUSSION        
        # thought of another case where we should check a project: if in the previous project_xml there were jobs running or created!
    	# it might happen that jobs fail without creating output, causing the last modified date on the project_dir not to be changed, 
    	# but a new ibrain check would see that there are no jobs present, and restart those failed jobs
    	# (of course most jobs will fail and output results to the BATCH dir, causing the last-mod. time to be changed and a new ibrain
    	# check to be triggered)
    	# (!!!) WHAT ABOUT THE RESETTING OF DATAFUSION JOBS... WILL THEY STILL RUN? (!!!) (yes, they need to be updated only if new files
    	# have been written to the directory. The resetting itself is by now obsolete! :-)
    	#
    	# run ibrain_project.sh if the previous project_xml says there were jobs running! or if ibrain was waiting.
    	
    	
    	if [ "$LATESTPROJECTXMLOUTPUT" ]; then
    		
    		# check for number of jobs present, or keywords that indicate activity on a certain project.
            PREVIOUSJOBCOUNTMATCHES=$(grep -i -e 'checking' -e 'resetting' -e 'waiting' -e '\[KNOWN ERROR FOUND\]' -e 'is submitted to queue' -e '<job_count_total>[1-9]*</job_count_total>' $LATESTPROJECTXMLOUTPUT)
            echo "<!-- PREVIOUSJOBCOUNTMATCHES: (escaping html/xml characters)"
            echo "$(echo $PREVIOUSJOBCOUNTMATCHES | sed 's|[<>!]| |g')"
            echo "    END OF PREVIOUSJOBCOUNTMATCHES -->"
            
            if [ $IBRAINPROJECTJOBCOUNT -eq 0 ]; then
	            # check if the xml is valid (--noout will only produce (error) output if there are parsing errors)
	            # but only do it if there is no current job running, otherwise we may be checking incomplete output
	            PREVIOUSXMLVALIDATION=$(xmllint --noout $LATESTPROJECTXMLOUTPUT 2>&1)
            else
                PREVIOUSXMLVALIDATION="";  
            fi
            
            ##################
            # EXPERIMENTAL: 'DATE MODIFIED' IS ONLY CHANGED IF SOMETHING DIRECTLY IN THE DIRECTORY CHANGES. 
            # SO TO BE MORE ACCURATE IN DETECTING DATA CHANGES, WE CAN EXTRACT PLATE PATHS FROM LATESTPROJECTXMLOUTPUT, 
            # AND CHECK THOSE FOR DATA CHANGES.
            # EXTRACT PLATE PATHS FROM $LATESTPROJECTXMLOUTPUT, TRANSFORM BACK TO NAS-PATHS, AND LOOP UNTIL NEWER FOUND
            BOOLDATACHANGE=0; # Set to 1 if we want to run because of data change
            if [ "$LATESTPROJECTXMLOUTPUT" ] && [ -e "$LATESTPROJECTXMLOUTPUT" ]; then
                echo "<!-- checking for data changes"            	
	            if [ "$INCLUDEDPATH" -nt "$LATESTPROJECTXMLOUTPUT" ]; then
					# Mark data change and stop further checking.
					BOOLDATACHANGE=1
	            else
	                # Get all plate paths and check for newer.
		            PROJECTPLATEDIRS=$(grep -e '<plate_dir>.*</plate_dir>' $LATESTPROJECTXMLOUTPUT | sed 's|<[^>]*>||g' | sed 's|/share-\([23]\)|/BIOL/imsb/fs\1/bio3/bio3|g')
					for PLATEDIR in $PROJECTPLATEDIRS; do
						if [ "$PLATEDIR" ] && [ -d "$PLATEDIR" ]; then
							#echo "checking $PLATEDIR"
							if [ "$PLATEDIR" -nt "$LATESTPROJECTXMLOUTPUT" -o "${PLATEDIR}/TIFF" -nt "$LATESTPROJECTXMLOUTPUT" ]; then
								# Set BOOLDATACHANGE to 1
								BOOLDATACHANGE=1
								echo "$PLATEDIR (or TIFF) is newer than $(basename $LATESTPROJECTXMLOUTPUT)"
								break  # We have found a data-change, so skip rest of loop.
						    elif [ -d "$PLATEDIR/BATCH" ] && [ "${PLATEDIR}/BATCH" -nt "$LATESTPROJECTXMLOUTPUT" ]; then
				                #echo "checking $PLATEDIR/BATCH"
                                BOOLDATACHANGE=1
                                echo "$PLATEDIR/BATCH is newer than $(basename $LATESTPROJECTXMLOUTPUT)"
                                break  # We have found a data-change, so skip rest of loop.
							fi
						else
						    echo "error: $PLATEDIR does not exist!"
						fi					
					done
				fi
				echo "BOOLDATACHANGE=$BOOLDATACHANGE"
				echo "checking for data changes -->"
    	   fi
    	   ##################
    	   
            
    	fi	
        ##########

        # set to 1 if we want to run ibrain_project.sh
        BOOLRUN=0
        if [ $ALLOWSUBMISSION -eq 0 ]; then
            echo "<update_info update=\"no\" reason=\"ibrain_error\">"
            echo "No submission, because mayor ibrain errors occured"
            echo "</update_info>"
            BOOLRUN=0
        else        	
	        if [ $IBRAINPROJECTJOBCOUNT -eq 0 ]; then
		        if [ ! "$LATESTPROJECTXMLOUTPUT" ] || [ ! "$LATESTPROJECTHTMLOUTPUT" ]; then
		            echo "<update_info update=\"yes\" reason=\"first_run\">"
		            echo "No previous project_xml found (run)"
		            echo "</update_info>"
		            BOOLRUN=1
		        elif [ "$PREVIOUSXMLVALIDATION" ]; then
		            echo "<update_info update=\"yes\" reason=\"previous_xml_invalid\">"
		            echo "The previous project_xml file was invalid (run)"
		            echo "</update_info>"
		            BOOLRUN=1            
		        elif [ $BOOLDATACHANGE -eq 1 ]; then
		           # previous code was:
		           # [ "$LATESTPROJECTXMLOUTPUT" ] && [ "$INCLUDEDPATH" -nt "$LATESTPROJECTXMLOUTPUT" ]; then 
		            echo "<update_info update=\"yes\" reason=\"data_change\">"
		            echo "$INCLUDEDPATH is newer than $LATESTPROJECTXMLOUTPUT, and there are fewer than 200 jobs present (run)"
		            echo "</update_info>"
		            BOOLRUN=1
		        elif [ "$IBRAIN_ROOT/iBRAIN.sh" -nt "$LATESTPROJECTXMLOUTPUT" ] || [ "$IBRAIN_ROOT/iBRAIN_project.sh" -nt "$LATESTPROJECTXMLOUTPUT" ] || [ "$IBRAIN_ROOT/core" -nt "$LATESTPROJECTXMLOUTPUT" ] || [ "$MATLABCODEPATH" -nt "$LATESTPROJECTXMLOUTPUT" ] || [ "$IBRAIN_ROOT/core/functions" -nt "$LATESTPROJECTXMLOUTPUT" ] || [ "$IBRAIN_ROOT/core/modules" -nt "$LATESTPROJECTXMLOUTPUT" ]; then
		            echo "<update_info update=\"yes\" reason=\"ibrain_update\">"
		            echo "iBRAIN (and components) has been updated (run)"
		            echo "</update_info>"
		            BOOLRUN=1
                elif [ $BOOLCHECKINGSEEMSFUTILE -eq 1 ]; then
                    echo "<update_info update=\"no\" reason=\"five_last_attempts_were_futile\">"
                    echo "All five last checks of this projects did not result in any jobs being submitted. Checking is therefore deemed futile."
                    echo "</update_info>"
                    BOOLRUN=0
		        elif [ $CURRENTJOBCOUNT -lt 200 ] && [ $CURRENTJOBCOUNT -gt 0 ] || ([ "$LATESTPROJECTXMLOUTPUT" ] && [ "$PREVIOUSJOBCOUNTMATCHES" ]); then 
		            echo "<update_info update=\"yes\" reason=\"expecting_new_jobs\">"
		            echo "Previous check indicated jobs present, but $INCLUDEDPATH is older than $LATESTPROJECTXMLOUTPUT (run)"
		            #echo "$PREVIOUSJOBCOUNTMATCHES"
		            echo "</update_info>"
		            BOOLRUN=1
		        else
		            echo "<update_info update=\"no\" reason=\"nothing_new\">"
		            echo "Skipping project for iBRAIN check (skip)"            
		            echo "- A previous version of project_xml is found."
		            echo "- Project_dir is not newer than the last project_xml_file."
		            echo "- The latest project_xml_file is newer than ibrain (components)."
		            echo "- There are currently more than 200 jobs scheduled for this project, skip intermediate checking."
		            echo "</update_info>"
		            BOOLRUN=0
		        fi
	        elif [ $IBRAINPROJECTJOBCOUNT -gt 0 ] && [ $RUNNINGIBRAINPROJECTJOBCOUNT -eq 0 ]; then
	            echo "<update_info update=\"no\" reason=\"scheduled\">"
	            echo "Skipping project for iBRAIN check (skip)"            
	            echo "- A check has been queued"
	            echo "</update_info>"
	            BOOLRUN=0        
	        elif [ $IBRAINPROJECTJOBCOUNT -gt 0 ] && [ $RUNNINGIBRAINPROJECTJOBCOUNT -gt 0 ]; then  
	            echo "<update_info update=\"no\" reason=\"running\">"
	            echo "Skipping project for iBRAIN check (skip)"            
	            echo "- It is currently being checked"
	            echo "</update_info>"
	            BOOLRUN=0
	    	fi
		fi

        # Do a quick cleanup of old project xml files for each project.
        echo "<!-- CLEANING UP OLDER PROJECT_XML FILES: MAXIMUM NUMBER ALLOWED IS 5"
		counter=0
		deletedcounter=0
		for projectxmlfilename in $(ls -r $PROJECTXMLDIR/*_project.xml 2>/dev/null); do
		    counter=$(( $counter + 1 ))
		    if [ $counter -gt 5 ]; then
		        rm -f $PROJECTXMLDIR/$(basename $projectxmlfilename .xml).*
		        deletedcounter=$(( $deletedcounter + 1 ))
		    fi
		done
		echo "-->"         
        
        # Submit ibrain_project.sh if BOOLRUN is bigger than 0
        if [ ! $BOOLRUN -eq 0 ]; then
        	
	        # the new ibrain_project output should be stored here
	        OUTPUTBASENAME=$(date +"%y%m%d_%H%M%S_%N")
            NEWPROJECTXMLOUTPUT="$PROJECTXMLDIR/${OUTPUTBASENAME}_project.xml"
	        NEWPROJECTHTMLOUTPUT="$PROJECTXMLDIR/index.html"
	        
	        if [ $IBRAINPROJECTJOBCOUNT -eq 0 ]; then
	            # We could make it a 1 hour job if not many plates are present, and an 8 hour job if there are many plates or if the last ibrain_project.sh timed out...
	        	PROJECTPLATECOUNT=${#PROJECTPLATEDIRS[@]}
	            if [ $PROJECTPLATECOUNT -eq 0 ] || [ $PROJECTPLATECOUNT -gt 50 ] || [ $(cat $PROJECTXMLDIR/ibrain_project_sh_output.results | grep "TERM_RUNLIMIT" | wc -l ) -gt 0 ]; then
	            	echo "<!-- submitting 8h (long) ibrain_project.sh on $INCLUDEDPATH"
		        	# submit job: run ibrain_project. sed-transform the xml to be web-friendly. store output in new XML output file
bsub -W 08:00 -oo $PROJECTXMLDIR/ibrain_project_sh_output.results "
./iBRAIN_project.sh "$INCLUDEDPATH" "$PRECLUSTERBACKUPPATH" "$PROJECTXMLDIR" "$NEWPROJECTXMLOUTPUT" 2>&1 | ./iBRAIN/sedTransformLogWeb.sed > $NEWPROJECTXMLOUTPUT 2>&1;
xsltproc -o $NEWPROJECTHTMLOUTPUT $NEWPROJECTXMLOUTPUT;
"
                	echo "-->"
	            else
	            	echo "<!-- submitting 1h (short) ibrain_project.sh on $INCLUDEDPATH"
        			# submit job: run ibrain_project. sed-transform the xml to be web-friendly. store output in new XML output file
bsub -W 01:00 -oo $PROJECTXMLDIR/ibrain_project_sh_output.results "
./iBRAIN_project.sh "$INCLUDEDPATH" "$PRECLUSTERBACKUPPATH" "$PROJECTXMLDIR" "$NEWPROJECTXMLOUTPUT" 2>&1 | ./iBRAIN/sedTransformLogWeb.sed > $NEWPROJECTXMLOUTPUT 2>&1;
xsltproc -o $NEWPROJECTHTMLOUTPUT $NEWPROJECTXMLOUTPUT;
"
                	echo "-->"	            
        		fi

                
	        else
	           echo "<!-- NOT submitting ibrain_project.sh on $INCLUDEDPATH... already running -->"
	        fi
	        
        fi
        
        
        # If a project needs to be checked again, and it has not been checked within the last hour, prioritize the checking. 
        # Otherwise, leave the job in the queue first-in-first-out.
        if [ $IBRAINPROJECTJOBCOUNT -gt 0 ] && [ $RUNNINGIBRAINPROJECTJOBCOUNT -eq 0 ]; then
	        if [ $(find $PROJECTXMLDIR -maxdepth 1 -type f -mmin +10 -name "ibrain_project_sh_output.results" | wc -l) -gt 0 ]; then
	            echo "<!-- ibrain project needs to be checked, and has not been checked within one hour. Prioritizing ibrain_project checking job."
	            # Prioritize ibrain_project.sh job on PROJECTXMLDIR
	            ~/iBRAIN/prioritizejobs.sh "$PROJECTXMLDIR/"
                # If prioritizing job, touch the ibrain_project_sh_output.results file to prevent repeated prioritization
                touch -cm $PROJECTXMLDIR/ibrain_project_sh_output.results
	            echo "-->"  
	        fi
        fi
        

    else # if [ -d $INCLUDEDPATH ]; then

        echo "   <warning type=\"InvalidPath\">$INCLUDEDPATH DOES NOT EXIST</warning>"

    fi
    
    echo "  </project>"
        
done # end loop over lines in paths.txt

#echo "FINISHED CHECKING FOLDERS"
echo " </projects>"

echo "<!-- cleaning up the 5th oldest wrapper_xml files (log-file roulation)"
counter=0
for filename in $(ls -r $WRAPPERXMLPATH/*_wrapper_brutus.xml 2>/dev/null); do
    counter=$(( $counter + 1 ))
    if [ $counter -gt 5 ]; then
    	rm -f $filename
    fi
done
echo "-->" 

# let's keep some statistics of job usage
echo "<!-- storing job stats for overview plotting"
echo "$(date +"%y%m%d %H:%M:%S") - $(busers 2>/dev/null | tail -n 1 )" >> $JOBCOUNTFILE
echo "-->"

# Close iBRAIN Log xml file element    
echo "</ibrain_log>"

# End of script.
exit 0;
