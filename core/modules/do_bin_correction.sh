#! /bin/bash
#
# bin_correction.sh

############################ 
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh #
############################ 

function main {

        ###
        ### BIN CORRECTION
        ###
        
        # VARIABLES:
            # to avoid double listing of settings files if $INCLUDEDPATH and $PROJECTDIR are the same... 
        	if [ $INCLUDEDPATH -ef $PROJECTDIR ]; then
	            # BIN-CORRECTION
	            BINSETTINGSFILE=$(find $PROJECTDIR -maxdepth 1 -type f -name "BIN_*.txt" | wc -l)
        	else
	            # BIN-CORRECTION
	            BINSETTINGSFILE=$(find $INCLUDEDPATH $PROJECTDIR -maxdepth 1 -type f -name "BIN_*.txt" | wc -l)
        	fi



        ### NOTE THAT BINCORRECTIONSETTINGSFILE IS THE SUM OF BIN-CORRECTION FILES IN THE INCLUDEDPATH AND IN THE PROJECTDIR!
        ### WE DO NOT WANT TO RUN ANY BIN CORRECTION AS LONG AS THERE ARE SVMS WAITING TO BE DONE (BOOLSVMSWAITING==1)
        
        ### IF ANY SETTINGS FILE IS PRESENT, SUBMIT
        
        if [ $BINSETTINGSFILE -gt 0 ]; then
             
            # should we make some special XML structure for the SVM files? group them together all in the status[@action='bin-correction']/status[@action='bin-correction-file...']
            # note that in this case we group status-elements together in a parent status field!!!

            echo "     <status action=\"${MODULENAME}\">"
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
	                    if [ -e $BINRUNLIMITFILE ]; then
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

}

# run standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main
