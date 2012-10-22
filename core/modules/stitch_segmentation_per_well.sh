#! /bin/bash
#
# stitch_segmentation_per_well.sh


############################
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh #
############################


function main {

    ###
    ### SEGMENTATION STITCHING PER WELL
    ###

    ### IF THERE ARE SEGMENTATION FILES, SUBMIT SEGMENTATION STITCHING PER WELL
    if [ -d $PROJECTDIR/SEGMENTATION ]; then

        STITCHINGMEASUREMENTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_*_StitchedWellObjectIds.mat" | wc -l)
        STITCHINRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "StitchSegmentationPerWell_*.results" | wc -l)

        if [ ! -e $PROJECTDIR/StitchSegmentationPerWell.submitted ]; then

            currentjobcount=$($IBRAIN_BIN_PATH/countjobs.sh "stitchSegmentationPerWell")

            if [ $currentjobcount -lt 30 ]; then

                echo "     <status action=\"${MODULENAME}\">submitting"
                #echo "      <message>"
                #echo "    PROCESSING: submitting plate segmentation stitching"
                #echo "      </message>"
                echo "      <output>"
                STITCHRESULTFILE="StitchSegmentationPerWell_$(date +"%y%m%d%H%M%S").results"
                bsub -W 8:00 -o "${BATCHDIR}$STITCHRESULTFILE" "matlab -singleCompThread -nodisplay -nojvm << M_PROG
                stitchSegmentationPerWell('${BATCHDIR}');
                M_PROG"
                touch $PROJECTDIR/StitchSegmentationPerWell.submitted
                echo "      </output>"
                echo "     </status>"

            else

                echo "     <status action=\"${MODULENAME}\">waiting"
                echo "      <message>"
                echo "    WAITING: not yet submitting segmentation stitching per well, too many jobs of this kind present"
                echo "      </message>"
                echo "     </status>"


            fi

        ### SEGMENTATION STITCHING HAS BEEN SUBMITTED BUT DID NOT PRODUCE OUTPUT FILES YET
        elif [ $STITCHINGMEASUREMENTCOUNT -lt 1 ] && [ -e $PROJECTDIR/StitchSegmentationPerWell.submitted ] && [ $STITCHINRESULTCOUNT -lt 1 ]; then

            echo "     <status action=\"${MODULENAME}\">waiting"
            #echo "      <message>"
            #echo "    PROCESSING: waiting for SEGMENTATION STITCHING to finish"
            #echo "      </message>"
            echo "      <output>"
            ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
            if [ $PLATEJOBCOUNT -eq 0 ]; then
                echo "    ALERT: iBRAIN IS WAITING FOR SEGMENTATION STITCHING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                rm -f $PROJECTDIR/StitchSegmentationPerWell.submitted
            fi
            echo "      </output>"
            echo "     </status>"


        ### PLATE NORMALIZATION HAS BEEN COMPLETED BUT FAILED TO PRODUCE OUTPUT FILES
        elif [ $STITCHINGMEASUREMENTCOUNT -lt 1 ] && [ -e $PROJECTDIR/StitchSegmentationPerWell.submitted ] && [ $STITCHINRESULTCOUNT -gt 0 ]; then

            echo "     <status action=\"${MODULENAME}\">failed"
            echo "      <warning>"
            echo "    ALERT: segmentation stitching FAILED"
            echo "      </warning>"
            echo "      <output>"
            ### check resultfiles for known errors, reset/resubmit jobs if appropriate
            $IBRAIN_BIN_PATH/check_resultfiles_for_known_errors.sh $BATCHDIR "StitchSegmentationPerWell" $PROJECTDIR/StitchSegmentationPerWell.submitted
            echo "      </output>"
            echo "     </status>"


        ### IF PLATE NORMALIZATION FILE IS PRESENT, FLAG AS COMPLETED
        elif [ $STITCHINGMEASUREMENTCOUNT -gt 0 ]; then

            echo "     <status action=\"${MODULENAME}\">completed"
            echo "     </status>"

        fi

    fi #end of check if there's a segmentation directory present
        
}

# standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main
