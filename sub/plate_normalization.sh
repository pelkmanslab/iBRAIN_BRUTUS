#! /bin/bash
#
# plate_normalization.sh

############################ 
#  INCLUDE PARAMETER CHECK #
. ./sub/parameter_check.sh #
############################ 

function main {
        
        ###
        ### PLATE NORMALIZATION
        ###

            # PLATE NORMALIZATION
            NORMALIZATIONCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_Mean_Std.mat" | wc -l)
            NORMALIZATIONRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "MeasurementsMeanStd_*.results" | wc -l)


        
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
        
       
}

# run standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main 
