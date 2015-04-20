#! /bin/bash
#
# cell_tracker.sh

############################ 
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh #
############################ 

function main {

        ###
        ### TRACKER
        ###
        
        # VARIABLES:
            # to avoid double listing of settings files if $INCLUDEDPATH and $PROJECTDIR are the same... 
        	if [ $INCLUDEDPATH -ef $PROJECTDIR ]; then
	            # TRACKER
	            TRACKERSETTINGSFILE=$(find $PROJECTDIR -maxdepth 1 -type f -name "SetTracker_*.txt" | wc -l)
        	else
	            # TRACKER
	            TRACKERSETTINGSFILE=$(find $INCLUDEDPATH $PROJECTDIR -maxdepth 1 -type f -name "SetTracker_*.txt" | wc -l)
        	fi




        ### NOTE THAT TRACKERSETTINGSFILE IS THE SUM OF SetTracker FILES IN THE INCLUDEDPATH AND IN THE PROJECTDIR!
        
        ### IF ANY SETTINGS FILE IS PRESENT, SUBMIT
        
        if [ $TRACKERSETTINGSFILE -gt 0 ]; then
             
            # should we make some special XML structure for the SVM files? group them together all in the status[@action='bin-correction']/status[@action='bin-correction-file...']
            # note that in this case we group status-elements together in a parent status field!!!

            echo "     <status action=\"${MODULENAME}\">"
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
                #TRACKERJOBCOUNT=$($IBRAIN_BIN_PATH/countjobs.sh $(basename $TRACKERSETTINGSFILE))
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
bsub -W 35:00 -R "rusage[mem=5000]" -o "${BATCHDIR}$TRACKERRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
iBrainTrackerV1('${PROJECTDIR}','${TRACKERSETTINGSFILE}');
M_PROG"
#                    else
#bsub -W 8:00 -R "rusage[mem=10000]" -o "${BATCHDIR}$TRACKERRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
#iBrainTrackerV1('${PROJECTDIR}','${TRACKERSETTINGSFILE}');
#3M_PROG"
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
                    $IBRAIN_BIN_PATH/check_resultfiles_for_known_errors.sh $BATCHDIR "$TRACKERRESULTFILEBASE" $TRACKERSUBMITTEDFILE                            
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
                    $IBRAIN_BIN_PATH/check_resultfiles_for_known_errors.sh $BATCHDIR "$TRACKERRESULTFILEBASE" $TRACKERSUBMITTEDFILE
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
                    $IBRAIN_BIN_PATH/check_resultfiles_for_known_errors.sh $BATCHDIR "$TRACKERRESULTFILEBASE" $TRACKERSUBMITTEDFILE                            
                    echo "      </output>"
					if [ -e $TRACKERSETTINGSFILE ]; then
                        echo "     <file type=\"txt\">$TRACKERSETTINGSFILE</file>"
                    fi
                    echo "     </status>"
                                            
                
                
                fi
             
            done #LOOP OVER TRACKERSETTINGS FILES
            echo "     </status>"
                                
		fi # end of TRACKER

}

# run standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main
