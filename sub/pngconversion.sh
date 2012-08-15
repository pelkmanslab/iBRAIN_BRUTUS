#! /bin/sh
#
# pngconversion.sh

############################ 
#  INCLUDE PARAMETER CHECK #
. ./sub/parameter_check.sh #
############################ 


# TIFF 2 PNG CONVERSION
COMPLETEDPNGCONVERSIONCHECK=$(find $BATCHDIR -maxdepth 1 -type f -name "ConvertAllTiff2Png.complete" | wc -l)
CONVERTALLTIFF2PNGRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "ConvertAllTiff2Png_*.results" | wc -l)


if [ $COMPLETEDPNGCONVERSIONCHECK -eq 0 ]; then 
	            	
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
	        			echo "       <progressbar text=\"png-conversion\">$PROGRESSBARVALUE</progressbar>"
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
	        			echo "       <progressbar text=\"png-conversion\">$PROGRESSBARVALUE</progressbar>"
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
else
                        echo "     <status action=\"convert-all-tiff-2-png\">completed</status>"
	           
fi # check if png conversion was completed 
