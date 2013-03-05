#! /bin/bash
#
# rename_nikon.sh

############################
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh
############################

function main {

###################
#### VARIABLES ####
###################

        NIKONDIR="${PROJECTDIR}/NIKON"
        NIKONTMPDIR="${PROJECTDIR}/TMPNKDIR"
  
 
        if [ ! -d $NIKONDIR ] || [ ! -e ${NIKONDIR}/CheckNikonImageSet.complete ] ; then
            # Nothing to do. Just jump to the next iBRAIN module.
            return
        fi

        if [ -d $NIKONDIR ] && [ ! -d $TIFFDIR ] && [ ! -d $NIKONTMPDIR ]; then
            echo "     <status action=\"${MODULENAME}\">preparing"
            echo "         creating TEMP NIKON folder"
            echo "      <output>"
            mkdir -p $NIKONTMPDIR
            echo "      </output>"
            echo "     </status>"
        fi
        
        
        
        if [ -d $TIFFDIR ]; then
            TIFFCOUNT=$(find $TIFFDIR -maxdepth 1 -type f -name "*.tif*" | wc -l)
        else
            TIFFCOUNT=0
        fi
        if [ -d $NIKONDIR ]; then
            IMGCOUNT=$(find $NIKONDIR -maxdepth 1 -type f -iregex '.*\.\(tiff?\|stk\)$' | wc -l)
        else
            IMGCOUNT=0
        fi
        if [ -d $NIKOTMPDIR ]; then
            # CHECK HOW MANY IMAGEs BEEN RENAMED
            RENAMEDIMGCOUNT=$(find $NIKONTMPDIR -maxdepth 1 -type f -name "*.tif*"  | wc -l)
            RENAMEDNIKONRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "RenameNikon_*.results" | wc -l)
        else
            RENAMEDIMGCOUNT=0
            RENAMEDNIKONRESULTCOUNT=0
        fi
 
        if [ -d $NIKONTMPDIR ] && [ ! -w $NIKONTMPDIR ]; then
        
            echo "     <status action=\"${MODULENAME}\">skipping"
            echo "      <message>"
            echo "    ALERT: NIKONTMP DIRECTORY NOT WRITABLE BY iBRAIN"
            echo "      </message>"
            echo "      <output>"
            echo "  NOT SUBMITTING NIKON-RENAMING FROM $NIKONDIR into $NIKONTMPDIR, DIRECTORY IS NOT WRITABLE BY iBRAIN"
            echo "      </output>"
            echo "     </status>"
        
        elif [ -d $NIKONTMPDIR ] && [ ! -e $PROJECTDIR/RenameNikonImages.submitted ] && [ $RENAMEDIMGCOUNT -eq 0 ]; then
                
            echo "     <status action=\"${MODULENAME}\">submitting"
            echo "      <output>"
			REPORTFILE=RenameNikon_$(date +"%y%m%d%H%M%S").results
			if [ -e $PROJECTDIR/RenameNikonImages.runlimit ]; then
bsub -W 36:00 -o $BATCHDIR/$REPORTFILE "matlab -singleCompThread -nodisplay -nojvm << M_PROG;
microscopetool.nikon.renameImages('${NIKONDIR}','${NIKONTMPDIR}');
M_PROG"
			else
bsub -W 08:00 -o $BATCHDIR/$REPORTFILE "matlab -singleCompThread -nodisplay -nojvm << M_PROG;
microscopetool.nikon.renameImages('${NIKONDIR}','${NIKONTMPDIR}');
M_PROG"
        	fi            
            touch $PROJECTDIR/RenameNikonImages.submitted
            echo "      </output>"                                        
            echo "     </status>"
            
        elif [ -e $PROJECTDIR/RenameNikonImages.submitted ] && [ ! -e $PROJECTDIR/RenameNikonImages.resubmitted ] && [ $RENAMEDIMGCOUNT -eq 0 ]  && [ $RENAMEDNIKONRESULTCOUNT -eq 0 ]; then
                
            echo "     <status action=\"${MODULENAME}\">waiting"
            echo "      <output>"
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            if [ $RENAMEDNIKONRESULTCOUNT -eq 0 ]; then
                echo "    ALERT: iBRAIN IS WAITING FOR NIKON RENAMING AND THERE ARE NO FINISHED JOBS YET. RETRYING THIS FOLDER IF NECESSARY"
                rm -f $PROJECTDIR/RenameNikonImages.submitted
            fi
            echo "      </output>"
            echo "     </status>"

        elif [ -d $NIKONTMPDIR ] && [ -e $PROJECTDIR/RenameNikonImages.submitted ] && [ ! -e $PROJECTDIR/RenameNikonImages.resubmitted ] && [ $RENAMEDIMGCOUNT -eq 0 ]  && [ $RENAMEDNIKONRESULTCOUNT -gt 0 ]; then

            echo "     <status action=\"${MODULENAME}\">resubmitting"
            echo "      <output>"
			REPORTFILE=RenameNikon_$(date +"%y%m%d%H%M%S").results
			if [ -e $PROJECTDIR/RenameNikonImages.runlimit ]; then
bsub -W 36:00 -o $BATCHDIR/$REPORTFILE "matlab -singleCompThread -nodisplay -nojvm << M_PROG;
microscopetool.nikon.renameImages('${NIKONDIR}','${NIKONTMPDIR}');
M_PROG"
			else
bsub -W 08:00 -o $BATCHDIR/$REPORTFILE "matlab -singleCompThread -nodisplay -nojvm << M_PROG;
microscopetool.nikon.renameImages('${NIKONDIR}','${NIKONTMPDIR}');
M_PROG"
        	fi     
            touch $PROJECTDIR/RenameNikonImages.resubmitted
            echo "      </output>"
            echo "     </status>"

        elif [ -e $PROJECTDIR/RenameNikonImages.submitted ] && [ -e $PROJECTDIR/RenameNikonImages.resubmitted ] && [ $RENAMEDIMGCOUNT -eq 0 ] && [ $RENAMEDNIKONRESULTCOUNT -eq 1 ]; then
               
            echo "     <status action=\"${MODULENAME}\">waiting"
            echo "      <output>"
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "    ALERT: iBRAIN IS WAITING FOR RENAMING NIKON IMAGES, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                rm -f $PROJECTDIR/RenameNikonImages.resubmitted
            fi
            echo "      </output>"
            echo "     </status>"
            
        elif [ -e $PROJECTDIR/RenameNikonImages.submitted ] && [ -e $PROJECTDIR/RenameNikonImages.resubmitted ] && [ $RENAMEDIMGCOUNT -eq 0 ] && [ $RENAMEDNIKONRESULTCOUNT -gt 1 ]; then
            
            echo "     <status action=\"${MODULENAME}\">failed"
            echo "      <warning>"
            echo "    ALERT: NIKON RENAMING FAILED TWICE"
            echo "      </warning>"
            echo "      <output>"
            ### check resultfiles for known errors, reset/resubmit jobs if appropriate 
            $IBRAIN_BIN_PATH/check_resultfiles_for_known_errors.sh $BATCHDIR "RenameNikonImages" $PROJECTDIR/RenameNikonImages.resubmitted
            echo "      </output>"
            echo "     </status>"
            
        elif ([ $RENAMEDIMGCOUNT -gt 0 ] && [ $RENAMEDIMGCOUNT -ge $IMGCOUNT ] && [ $RENAMEDNIKONRESULTCOUNT -gt 0 ]) || [ -d $TIFFDIR ]; then
            if [ -d $NIKONTMPDIR ] && [ ! -d $TIFFDIR ]; then
                # Rename TMP dir into TIFF
                mv $NIKONTMPDIR $TIFFDIR
            fi
            if [ -d $TIFFDIR ] && [ $TIFFCOUNT -gt 0 ] && [ ! -e $TIFFDIR/CheckImageSet_${TIFFCOUNT}.complete ]; then
                touch $TIFFDIR/CheckImageSet_${TIFFCOUNT}.complete
                touch ${BATCHDIR}/checkimageset.complete
            fi
            echo "     <status action=\"${MODULENAME}\">completed"
            echo "     </status>"
        fi

}

# run standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main
