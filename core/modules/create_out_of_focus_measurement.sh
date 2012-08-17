#! /bin/sh
#
# score_out_of_focus.sh

############################ 
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh #
############################ 
       
function main {
 
        ###
        ### CHECK OUTOFFOCUS
        ###

            # OUT OF FOCUS SCORING
            OUTOFFOCUSCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "*Measurements_*OutOfFocus.mat" | wc -l)
            OUTOFFOCUSRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "CheckOutOfFocus_*.results" | wc -l)


        
        ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT SUBMIT INFECTION SCORING
        
        OUTOFFOCUSSETTINGFILECOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_*BlueSpectrum.mat" | wc -l)
        
        if [ ! -e $PROJECTDIR/CheckOutOfFocus.submitted ] && [ $OUTOFFOCUSSETTINGFILECOUNT -gt 0 ]; then
             
            echo "     <status action=\"${MODULENAME}\">submitting"
            #echo "      <message>"
            #echo "    PROCESSING: submitting outoffocus checking"
            #echo "      </message>"
            echo "      <output>"                    
            ~/iBRAIN/checkoutoffocus.sh $BATCHDIR
            echo "      </output>"                    
            echo "     </status>"                     
            
            
        ### CHECK OUTOFFOCUS HAS BEEN SUBMITTED BUT DID NOT PRODUCE OUTPUT FILES YET
        elif [ $OUTOFFOCUSCOUNT -lt 1 ] && [ -e $PROJECTDIR/CheckOutOfFocus.submitted ] && [ $OUTOFFOCUSRESULTCOUNT -lt 1 ]; then
            
            echo "     <status action=\"${MODULENAME}\">waiting"
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
            
            echo "     <status action=\"${MODULENAME}\">failed"
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
            
            echo "     <status action=\"${MODULENAME}\">completed"
            #echo "      <message>"
            #echo "    COMPLETED: checkoutoffocus"
            #echo "      </message>"
            echo "     </status>"   
                                
            
            
        elif [ $OUTOFFOCUSSETTINGFILECOUNT -eq 0 ]; then

            echo "     <status action=\"${MODULENAME}\">skipping"
            #echo "      <message>"
            #echo "    SKIPPING: checkoutoffocus"
            #echo "      </message>"
            echo "     </status>" 
            
            
            
        else

            echo "     <status action=\"${MODULENAME}\">unknown"
            echo "      <warning>"
            echo "    UNKNOWN STATUS: checkoutoffocus"
            echo "      </warning>"
            echo "      <output>"                    
            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "CheckOutOfFocus" $PROJECTDIR/CheckOutOfFocus.submitted
            echo "      </output>"                    
            echo "     </status>" 
            
        fi
        
}

# run standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main
