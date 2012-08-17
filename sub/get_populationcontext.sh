#! /bin/bash
#
# get_populationcontext.sh


############################
#  INCLUDE PARAMETER CHECK #
. ./sub/parameter_check.sh #
############################


function main {

        ###
        ### GET LOCAL CELL DENSITY PER WELL AUTO
        ###
        
        ### variables:
            # LOCAL CELL DENSITY
            LCDCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_Nuclei_LocalCellDensity.mat" | wc -l)
            LCDRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "getLocalCellDensityPerWell_auto_*.results" | wc -l)



        if [ ! -e $PROJECTDIR/GetLocalCellDensityPerWell_Auto.submitted ]; then
                echo "     <status action=\"get-local-cell-density-per-well\">submitting"
                #echo "      <message>"
                #echo "    PROCESSING: submitting plate normalization calculations"
                #echo "      </message>"
                echo "      <output>"           
                LCDRESULTFILE="getLocalCellDensityPerWell_auto_$(date +"%y%m%d%H%M%S").results"
            	if [ -e $PROJECTDIR/GetLocalCellDensityPerWell_Auto.runlimit ]; then
bsub -W 34:00 -o "${BATCHDIR}$LCDRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
getLocalCellDensityPerWell_auto('${BATCHDIR}');
Detect_BorderCells('${BATCHDIR}');
M_PROG" 2> /dev/null
                	else
bsub -W 8:00 -o "${BATCHDIR}$LCDRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
getLocalCellDensityPerWell_auto('${BATCHDIR}');
Detect_BorderCells('${BATCHDIR}');
M_PROG" 2> /dev/null
		        fi
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
        
}

# run standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main
