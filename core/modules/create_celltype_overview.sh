#! /bin/bash
#
# create_celltype_overview.sh

############################
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh #
############################

function main {

PLATEBASICDATACOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "BASICDATA_*.mat" | wc -l)

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
		        #    echo "     <status action=\"${MODULENAME}\">resetting"
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
		            echo "     <status action=\"${MODULENAME}\">resetting"
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
		    #            echo "     <status action=\"${MODULENAME}\">resetting"
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
	             
	            echo "     <status action=\"${MODULENAME}\">submitting"
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
	            
	            echo "     <status action=\"${MODULENAME}\">waiting"
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
	            
	            echo "     <status action=\"${MODULENAME}\">failed"
	            echo "      <warning>"
	            echo "    ALERT: celltype overview generation FAILED"
	            echo "      </warning>"
	            echo "      <output>"                    
	
	            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
	            $IBRAIN_BIN_PATH/check_resultfiles_for_known_errors.sh $BATCHDIR "CreateCellTypeOverview_" $PROJECTDIR/CreateCellTypeOverview.submitted
	                                
	            ## TEMP BS_BUGFIX. RESET ALL CRASHED CELLTYPEOVERVIEWS!
	            # echo "APPLYING TEMPORARY BUGFIX. RESETTING ALL CRASHED CreateCellTypeOverview JOBS"
	            # rm -vf $PROJECTDIR/CreateCellTypeOverview.submitted
	            # rm -vf $BATCHDIR/CreateCellTypeOverview_*.results
	                                
	            echo "      </output>"                    
	            echo "     </status>"                     
	
	            
	        ### IF CreateCellTypeOverview FILE IS PRESENT, FLAG AS COMPLETED
	        
	        elif [ $NEWERSVMFILECOUNT -eq 0 ] && [ -e $CELLTYPEOVERVIEWFILE ]; then
	     
	            echo "     <status action=\"${MODULENAME}\">completed"
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
	            
	            echo "     <status action=\"${MODULENAME}\">unknown"
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
	            $IBRAIN_BIN_PATH/check_resultfiles_for_known_errors.sh $BATCHDIR "CreateCellTypeOverview_" $PROJECTDIR/CreateCellTypeOverview.submitted
	                                
	            echo "      </output>"                    
	            echo "     </status>"     
	                            
	        fi
		fi

}

# run standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main
