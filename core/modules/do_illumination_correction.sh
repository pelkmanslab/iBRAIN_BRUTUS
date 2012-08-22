#! /bin/bash
#
# illuminationcorrection.sh

############################
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh #
############################


function main {

    ### VARIABLE CHECKING

    # ILLUMINATION CORRECTION MEASUREMENTS
    # CHECK HOW MANY ILLUMINATION CORRECTION SETTINGS FILES ARE PRESENT. IF THIS IS BIGGER THAN 0,
    # AND FOR EACH EXISTS AN OUTPUT FILE, THAN CONSIDER STEP COMPLETE
    TOTALILLCORJOBCOUNT=$(~/iBRAIN/countjobs.sh batch_measure_illcor_stats)
    ALLILLCORSETTINGSFILESCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "batch_illcor_*.mat" | wc -l)
    if [ $ALLILLCORSETTINGSFILESCOUNT -gt 0 ]; then
        COMPLETEDILLCORMEASUREMENTCHECK=1;
        for ILLCORSETTINGSFILE in $(find $BATCHDIR -maxdepth 1 -type f -name "batch_illcor_*.mat"); do
            ILLCOROUTPUTFILE="${BATCHDIR}Measurements_$(basename $ILLCORSETTINGSFILE)"
            ILLCOROVERVIEWPDFFILE="${POSTANALYSISDIR}Measurements_$(basename $ILLCORSETTINGSFILE .mat).pdf"
            if [ ! -e $ILLCOROUTPUTFILE ]; then
                COMPLETEDILLCORMEASUREMENTCHECK=0;
                break
            fi
        done
    else
        COMPLETEDILLCORMEASUREMENTCHECK=0;
    fi



    ###
    ### ILLUMINATION CORRECTION BATCHED PER CHANNEL AND Z-STACK
    ###

    ### IF THERE ARE NO SETTINGS FILE PRESENT, RUN MATLAB LOCALLY TO CREATE BATCH SETTINGS FILES FOR ILLUMINATION CORRECTION
    ### PER INDIVIDUAL CHANNEL AND Z-STACK
    ILLCORSETTINGSFILE=$(find $BATCHDIR -maxdepth 1 -type f -name "batch_illcor_*.mat" | wc -l)
    if [ $ILLCORSETTINGSFILE -eq 0 ] && [ ! -e ${PROJECTDIR}/IllumCorrectionSettingsFileCreation.submitted ]; then
        echo "<!-- STARTING MATLAB CREATION OF BATCH ILLUMINATION CORRECTION SETTINGS FILES"
        echo $(matlab -singleCompThread -nodisplay -nojvm << M_PROG
        prepare_batch_measure_illcor_stats('${TIFFDIR}');
        M_PROG)
        touch ${PROJECTDIR}/IllumCorrectionSettingsFileCreation.submitted
        echo "-->"
        ILLCORSETTINGSFILE=$(find $BATCHDIR -maxdepth 1 -type f -name "batch_illcor_*.mat" | wc -l)
    fi

    if [ $ILLCORSETTINGSFILE -eq 0 ] && [ -e ${PROJECTDIR}/IllumCorrectionSettingsFileCreation.submitted ]; then
        echo "     <status action=\"${MODULENAME}\">skipping"
        echo "      <message>"
        echo "    $ILLCORSETTINGSFILE illumination correction settings files produced by matlab."
        echo "      </message>"
        echo "     </status>"
        # Report module is finished
        COMPLETEDILLCORMEASUREMENTCHECK=1
    fi

    if [ $ILLCORSETTINGSFILE -gt 0 ]; then

        if [ $COMPLETEDILLCORMEASUREMENTCHECK -eq 1 ]; then
            echo "     <status action=\"${MODULENAME}\">completed"
        else
            echo "     <status action=\"${MODULENAME}\">"
        fi
        echo "      <message>"
        echo "    $ILLCORSETTINGSFILE illumination correction settings files found"
        echo "      </message>"

        # GET A LIST OF ALL ILLUM COR SETTINGS FILES
        ALLILLCORSETTINGSFILES=$(find $BATCHDIR -maxdepth 1 -type f -name 'batch_illcor_*.mat')

        for ILLCORSETTINGSFILE in $ALLILLCORSETTINGSFILES; do

            ILLCOROUTPUTFILE="${BATCHDIR}Measurements_$(basename $ILLCORSETTINGSFILE)"
            ILLCOROVERVIEWPDFFILE="${POSTANALYSISDIR}Measurements_$(basename $ILLCORSETTINGSFILE .mat).pdf"
            ILLCORRESULTFILEBASE="IllumCorrection_$(basename $ILLCORSETTINGSFILE .mat)_"
            ILLCORSUBMITTEDFILE="${PROJECTDIR}/IllumCorrection_$(basename $ILLCORSETTINGSFILE .mat).submitted"
            ILLCORRESULTFILECOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "$ILLCORRESULTFILEBASE*.results" | wc -l)
            ILLCORJOBCOUNT=$(grep $ILLCORSETTINGSFILE $JOBSFILE -c)
            if [ ! -d $POSTANALYSISDIR ]; then
                mkdir -p $POSTANALYSISDIR
            fi

            if [ ! -e $ILLCORSUBMITTEDFILE ] && [ ! -e $ILLCOROUTPUTFILE ]; then


                # TOTALILLCORJOBCOUNT=$(grep batch_measure_illcor_stats $JOBSFILE -c)
                if [ $TOTALILLCORJOBCOUNT -lt 100 ]; then
                    echo "     <status action=\"$(basename $ILLCORSETTINGSFILE)\">submitting"
                    #echo "      <message>"
                    #echo "      SUBMITTING: $(basename $ILLCORSETTINGSFILE)"
                    #echo "      </message>"
                    echo "      <output>"
                    ILLCORRESULTFILE="$ILLCORRESULTFILEBASE$(date +"%y%m%d%H%M%S").results"
bsub -W 8:00 -o "${BATCHDIR}$ILLCORRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
batch_measure_illcor_stats('${TIFFDIR}','${ILLCORSETTINGSFILE}');
M_PROG"
                    touch $ILLCORSUBMITTEDFILE
                    echo "      </output>"
                    echo "     </status>"
                else
                    echo "     <status action=\"$(basename $ILLCORSETTINGSFILE)\">waiting"
                    echo "      <message>"
                    echo "      WAITING with submission of $(basename $ILLCORSETTINGSFILE) job because there are too many ($TOTALILLCORJOBCOUNT) illumination correction jobs present now."
                    echo "      </message>"
                    echo "     </status>"
                fi

            # no output yet                has been submitted          has jobs present        no output jet
            elif [ ! -e $ILLCOROUTPUTFILE ] && [ -e $ILLCORSUBMITTEDFILE ] && [ $ILLCORJOBCOUNT -gt 0 ] && [ $ILLCORRESULTFILECOUNT -eq 0 ]; then

                echo "     <status action=\"$(basename $ILLCORSETTINGSFILE)\">waiting"
                #echo "      <message>"
                #echo "      WAITING: $(basename $ILLCORSETTINGSFILE): $ILLCORJOBCOUNT JOB(S) PRESENT"
                #echo "      </message>"
                echo "     </status>"

            # no output yet                has been submitted          no jobs present           results never produced
            elif [ ! -e $ILLCOROUTPUTFILE ] && [ -e $ILLCORSUBMITTEDFILE ] && [ $ILLCORJOBCOUNT -eq 0 ] && [ $ILLCORRESULTFILECOUNT -eq 0 ]; then

                echo "     <status action=\"$(basename $ILLCORSETTINGSFILE)\">failed"
                echo "      <warning>"
                echo "      FAILED: $(basename $ILLCORSETTINGSFILE): RETRYING ILLUMINATION CORRECTION. PREVIOUS JOB DID NOT PRODUCE OUTPUT (?!)"
                echo "      </warning>"
                echo "      <output>"
                rm -fv $ILLCORSUBMITTEDFILE
                echo "      </output>"
                echo "     </status>"

            # no output yet                has been submitted          no jobs present           results produced once
            elif [ ! -e $ILLCOROUTPUTFILE ] && [ -e $ILLCORSUBMITTEDFILE ] && [ $ILLCORJOBCOUNT -eq 0 ] && [ $ILLCORRESULTFILECOUNT -eq 1 ]; then

                echo "     <status action=\"$(basename $ILLCORSETTINGSFILE)\">failed"
                echo "      <warning>"
                echo "      FAILED: $(basename $ILLCORSETTINGSFILE): RETRYING ILLUMINATION CORRECTION"
                echo "      </warning>"
                echo "      <output>"
                ### check resultfiles for known errors, reset/resubmit jobs if appropriate
                ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "$ILLCORRESULTFILEBASE" $ILLCORSUBMITTEDFILE
                rm -fv $ILLCORSUBMITTEDFILE
                echo "      </output>"
                echo "     </status>"

            # no output yet                has been submitted          no jobs present           results produced twice
            elif [ ! -e $ILLCOROUTPUTFILE ] && [ -e $ILLCORSUBMITTEDFILE ] && [ $ILLCORJOBCOUNT -eq 0 ] && [ $ILLCORRESULTFILECOUNT -eq 2 ]; then

                echo "     <status action=\"$(basename $ILLCORSETTINGSFILE)\">failed"
                echo "      <warning>"
                echo "      ABORTED: $(basename $ILLCORSETTINGSFILE): FAILED TWICE"
                echo "      </warning>"
                echo "      <output>"
                ### check resultfiles for known errors, reset/resubmit jobs if appropriate
                ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "$ILLCORRESULTFILEBASE" $ILLCORSUBMITTEDFILE
                echo "      </output>"
                echo "     </status>"


            # output present
            elif [ -e $ILLCOROUTPUTFILE ] ; then

                echo "     <status action=\"$(basename $ILLCORSETTINGSFILE)\">completed"
                #echo "      <message>"
                #echo "      COMPLETED: $(basename $ILLCORSETTINGSFILE)"
                #echo "      </message>"
                if [ -e $ILLCOROVERVIEWPDFFILE ]; then
                    echo "     <file type=\"pdf\">$ILLCOROVERVIEWPDFFILE</file>"
                fi
                echo "     </status>"

            else

                echo "     <status action=\"$(basename $ILLCORSETTINGSFILE)\">unknown"
                echo "      <warning>"
                echo "      UNKNOWN STATUS: $(basename $ILLCORSETTINGSFILE)"
                if [ -e $ILLCORSETTINGSFILE ]; then
                    echo "        DEBUG: ILLCORSETTINGSFILE=$ILLCORSETTINGSFILE (present)"
                else
                    echo "        DEBUG: ILLCORSETTINGSFILE=$ILLCORSETTINGSFILE (missing)"
                fi
                if [ -e $ILLCOROUTPUTFILE ]; then
                    echo "        DEBUG: ILLCOROUTPUTFILE=$ILLCOROUTPUTFILE (present)"
                else
                    echo "        DEBUG: ILLCOROUTPUTFILE=$ILLCOROUTPUTFILE (missing)"
                fi
                if [ -e $ILLCORSUBMITTEDFILE ]; then
                    echo "        DEBUG: ILLCORSUBMITTEDFILE=$ILLCORSUBMITTEDFILE (present)"
                else
                    echo "        DEBUG: ILLCORSUBMITTEDFILE=$ILLCORSUBMITTEDFILE (missing)"
                fi
                echo "        DEBUG: ILLCORRESULTFILEBASE=$ILLCORRESULTFILEBASE"
                echo "        DEBUG: ILLCORRESULTFILECOUNT-SEARCH-STRING=$ILLCORRESULTFILEBASE*.results"
                echo "        DEBUG: ILLCORRESULTFILECOUNT=$ILLCORRESULTFILECOUNT"
                echo "        DEBUG: ILLCORJOBCOUNT=$ILLCORJOBCOUNT"

                echo "      </warning>"
                echo "      <output>"
                ### check resultfiles for known errors, reset/resubmit jobs if appropriate
                ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "$ILLCORRESULTFILEBASE" $ILLCORSUBMITTEDFILE
                echo "      </output>"
                echo "     </status>"

            fi

        done #LOOP OVER ILLCORSETTINGS FILES
        echo "     </status>"

    fi # end of illumination correction

    # Report module is finished
    if [ $COMPLETEDILLCORMEASUREMENTCHECK -eq 1 ] && [ ! -e ${BATCHDIR}/illuminationcorrection.complete ]; then
        touch ${BATCHDIR}/illuminationcorrection.complete
    fi

}

# run standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main
