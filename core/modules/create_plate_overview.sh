#! /bin/bash
#
# create_plate_overview.sh

############################
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh #
############################


function main {


        ###
        ### CREATE PLATE OVERVIEW
        ###


        # Store (log) links to external files that are linked in the iBRAIN website. Note that the BASICDATA_*.mat files are logged for some matlab functions.
        echo "     <files>"
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


        
            # PLATE OVERVIEW GENERATION
            if [ -d $POSTANALYSISDIR ]; then
                PLATEOVERVIEWCOUNT=$(find $POSTANALYSISDIR -maxdepth 1 -type f -name "*_plate_overview.*" | wc -l)
            else
                PLATEOVERVIEWCOUNT=0
            fi
            PLATEOVERVIEWRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "CreatePlateOverview_*.results" | wc -l)            
            PLATEBASICDATACOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "BASICDATA_*.mat" | wc -l)



        ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT SUBMIT INFECTION SCORING
        
        # variables:
        # PLATEOVERVIEWCOUNT
        # PLATEOVERVIEWRESULTCOUNT
        # PLATEBASICDATACOUNT (actually the more important output! should adjust iBRAIN to check for the matlab output rather than the pdf/csv files...)
        
        
        ### CREATE PLATE OVERVIEW EITHER IF OUTOFFOCUS IS NOT TO BE DONE OR FINISHED, AND EITHER IF INFECTION SCORING IS COMPLETED OR NOT TO BE DONE
        
        ### if [ $OUTOFFOCUSCOUNT -gt 0 ] && [ $INFECTIONCOUNT -gt 1 ] && [ ! -e $PROJECTDIR/CreatePlateOverview.submitted ]; then
        
        # removed:
        #  && ( [ $INFECTIONCOUNT -gt 1 ] || [ $INFECTIONSETTINGFILECOUNT -eq 0 ] || [ $BOOLINFECTIONSCORINGFAILED -eq 1 ] )
        
        if [ ! -e $PROJECTDIR/CreatePlateOverview.submitted ]; then

            echo "     <status action=\"${MODULENAME}\">submitting"
            echo "      <output>"
            if [ ! -d $POSTANALYSISDIR ]; then
                mkdir -p $POSTANALYSISDIR
            fi
            ~/iBRAIN/createplateoverview.sh $BATCHDIR 2> /dev/null
            echo "      </output>"
            echo "     </status>"

        ### CHECK createplateoverview HAS BEEN SUBMITTED BUT DID NOT PRODUCE OUTPUT FILES YET
        elif [ $PLATEBASICDATACOUNT -lt 1 ] && [ -e $PROJECTDIR/CreatePlateOverview.submitted ] && [ $PLATEOVERVIEWRESULTCOUNT -lt 1 ]; then

            echo "     <status action=\"${MODULENAME}\">waiting"
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
            
            echo "     <status action=\"${MODULENAME}\">failed"
            echo "      <warning>"
            echo "    ALERT: plate overview generation FAILED"
            echo "      </warning>"
            echo "      <output>"                    
            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "CreatePlateOverview" $PROJECTDIR/CreatePlateOverview.submitted 
            echo "      </output>"                    
            echo "     </status>"                      
            
        elif [ $PLATEBASICDATACOUNT -gt 0 ]; then
            
            echo "     <status action=\"${MODULENAME}\">completed"
            #echo "      <message>"
            #echo "    COMPLETED: plate overview generation"
            #echo "      </message>"
            echo "     </status>"
            
        fi # end of plate overview 

}

# run standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main
