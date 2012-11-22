#! /bin/bash
#
# create_jpgs.sh

############################
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh
############################

function main {
        #TIFFDIR
        #PROJECTDIR

        # Report any plate overview files for linking on the website
        echo "     <files>"
        if [ -d $JPGDIR ]; then
            for file in $(find $JPGDIR -maxdepth 1 -type f -name "*PlateOverview.jpg"); do
            echo "     <file type=\"plate_overview_jpg\">$file</file>"
            done
        fi
        echo "     </files>"
       
 
        if [ ! -d $JPGDIR ]; then
            echo "     <status action=\"${MODULENAME}\">preparing"
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
            CREATEJPGRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "CreateJPGs*.results" | wc -l)
        else
            JPGPLATEOVERVIEWCOUNT=0
            JPGCOUNT=0
            CREATEJPGRESULTCOUNT=0
        fi
        
        if [ -d $JPGDIR ] && [ ! -w $JPGDIR ]; then
        
            echo "     <status action=\"${MODULENAME}\">skipping"
            echo "      <message>"
            echo "    ALERT: JPG DIRECTORY NOT WRITABLE BY iBRAIN"
            echo "      </message>"
            echo "      <output>"
            echo "  NOT SUBMITTING JPG-CREATION IN $JPGDIR, DIRECTORY IS NOT WRITABLE BY iBRAIN"
            echo "      </output>"                                        
            echo "     </status>"                  
        
        elif [ -d $JPGDIR ] && [ ! -e $PROJECTDIR/CreateJPGs.submitted ] && [ $JPGCOUNT -eq 0 ]; then
                
            echo "     <status action=\"${MODULENAME}\">submitting"
            #echo "      <message>"
            #echo "    PROCESSING: submitting jpg creation"
            #echo "      </message>"
            echo "      <output>"
			REPORTFILE=CreateJPGs_$(date +"%y%m%d%H%M%S").results
			if [ -e $PROJECTDIR/CreateJPGs.runlimit ]; then
bsub -W 36:00 -o $BATCHDIR/$REPORTFILE "matlab -singleCompThread -nodisplay -nojvm << M_PROG;
create_jpgs('${TIFFDIR}','${JPGDIR}');
merge_jpgs_per_plate('${JPGDIR}');
M_PROG"
			else
bsub -W 08:00 -o $BATCHDIR/$REPORTFILE "matlab -singleCompThread -nodisplay -nojvm << M_PROG;
create_jpgs('${TIFFDIR}','${JPGDIR}');
merge_jpgs_per_plate('${JPGDIR}');
M_PROG"
        	fi            
            #$IBRAIN_BIN_PATH/createjpgs.sh $TIFFDIR $JPGDIR
            touch $PROJECTDIR/CreateJPGs.submitted
            echo "      </output>"                                        
            echo "     </status>"
            
        elif [ -e $PROJECTDIR/CreateJPGs.submitted ] && [ ! -e $PROJECTDIR/CreateJPGs.resubmitted ] && ([ $JPGCOUNT -eq 0 ] || [ $JPGPLATEOVERVIEWCOUNT -eq 0 ]) && [ $CREATEJPGRESULTCOUNT -eq 0 ]; then
                
            echo "     <status action=\"${MODULENAME}\">waiting"
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

            echo "     <status action=\"${MODULENAME}\">resubmitting"
            #echo "      <message>"
            #echo "    PROCESSING: resubmitting jpg creation"
            #echo "      </message>"
            echo "      <output>"
REPORTFILE=CreateJPGs_$(date +"%y%m%d%H%M%S").results
			if [ -e $PROJECTDIR/CreateJPGs.runlimit ]; then
bsub -W 36:00 -o $BATCHDIR/$REPORTFILE "matlab -singleCompThread -nodisplay -nojvm << M_PROG;
create_jpgs('${TIFFDIR}','${JPGDIR}');
merge_jpgs_per_plate('${JPGDIR}');
M_PROG"
			else
bsub -W 08:00 -o $BATCHDIR/$REPORTFILE "matlab -singleCompThread -nodisplay -nojvm << M_PROG;
create_jpgs('${TIFFDIR}','${JPGDIR}');
merge_jpgs_per_plate('${JPGDIR}');
M_PROG"
        	fi     
        	#$IBRAIN_BIN_PATH/createjpgs.sh $TIFFDIR $JPGDIR
            touch $PROJECTDIR/CreateJPGs.resubmitted
            echo "      </output>"                                        
            echo "     </status>"

        elif [ -e $PROJECTDIR/CreateJPGs.submitted ] && [ -e $PROJECTDIR/CreateJPGs.resubmitted ] && ([ $JPGCOUNT -eq 0 ] || [ $JPGPLATEOVERVIEWCOUNT -eq 0 ]) && [ $CREATEJPGRESULTCOUNT -eq 1 ]; then
               
            echo "     <status action=\"${MODULENAME}\">waiting"
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
            
            echo "     <status action=\"${MODULENAME}\">failed"
            echo "      <warning>"
            echo "    ALERT: JPG CREATION FAILED TWICE"
            echo "      </warning>"
            echo "      <output>"
            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
            $IBRAIN_BIN_PATH/check_resultfiles_for_known_errors.sh $BATCHDIR "CreateJPGs" $PROJECTDIR/CreateJPGs.resubmitted
            echo "      </output>"                                        
            echo "     </status>"                    
            
        elif [ $JPGCOUNT -gt 0 ]; then
            

            echo "     <status action=\"${MODULENAME}\">completed"
            #echo "      <message>"
            #echo "    COMPLETED: jpg creation"
            #echo "      </message>"
            echo "     </status>"                    
            
        fi
      
}

# run standardized bash-error handling of iBRAIN
#execute_ibrain_module

# clear main module function
#unset -f main
