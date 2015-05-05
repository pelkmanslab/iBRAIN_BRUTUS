#! /bin/bash
#
# svm_classification.sh

############################
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh #
############################

function main {

    ###
    ### SVM CLASSIFICATION
    ###

    # VARIABLES:
    # to avoid double listing of settings files if $INCLUDEDPATH and $PROJECTDIR are the same...
    if [ $INCLUDEDPATH -ef $PROJECTDIR ]; then
        # SVM CLASSIFICATION
        SVMSETTINGSFILE=$(find $PROJECTDIR -maxdepth 1 -type f -name "SVM_*.mat" | wc -l)
    else
        # SVM CLASSIFICATION
        SVMSETTINGSFILE=$(find $INCLUDEDPATH $PROJECTDIR -maxdepth 1 -type f -name "SVM_*.mat" | wc -l)
    fi

    NORMALIZATIONCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_Mean_Std.mat" | wc -l)

    ### NOTE THAT SVMSETTINGSFILE IS THE SUM OF CLASSIFICATION FILES IN THE INCLUDEDPATH AND IN THE PROJECTDIR!

    ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT SUBMIT SVM CLASSIFICATION
    BOOLSVMSWAITING=0;

    if [ $NORMALIZATIONCOUNT -gt 0 ] && [ $SVMSETTINGSFILE -gt 0 ]; then

        # should we make some special XML structure for the SVM files? group them together all in the status[@action='svm-classification']/status[@action='svm-file...']
        # note that in this case we group status-elements together in a parent status field!!!

        echo "     <status action=\"svm-classifications\">"
        echo "      <message>"
        echo "    $SVMSETTINGSFILE SVM classifications found"
        echo "      </message>"

        # to avoid double listing of settings files if $INCLUDEDPATH and $PROJECTDIR are the same...
        if [ $INCLUDEDPATH -ef $PROJECTDIR ]; then
            ALLSVMSETTINGSFILES=$(find $PROJECTDIR -maxdepth 1 -type f -name 'SVM_*.mat')
        else
            # otherwise settings files can be stored both in the project directory ($INCLUDEDPATH) and in the plate directory ($PROJECTDIR) (ugly variable names...)
            ALLSVMSETTINGSFILES=$(find $INCLUDEDPATH $PROJECTDIR -maxdepth 1 -type f -name 'SVM_*.mat')
        fi

        for SVMSETTINGSFILE in $ALLSVMSETTINGSFILES; do

            SVMOUTPUTFILE="${BATCHDIR}Measurements_$(basename $SVMSETTINGSFILE)"
            SVMOVERVIEWPDFFILE="${POSTANALYSISDIR}Measurements_$(basename $SVMSETTINGSFILE .mat)_overview.pdf"
            SVMOVERVIEWCSVFILE="${POSTANALYSISDIR}Measurements_$(basename $SVMSETTINGSFILE .mat)_overview.csv"
            SVMRESULTFILEBASE="SVMClassification_$(basename $SVMSETTINGSFILE .mat)_"
            SVMSUBMITTEDFILE="${PROJECTDIR}/SVMClassification_$(basename $SVMSETTINGSFILE .mat).submitted"
            SVMRUNLIMITFILE="${PROJECTDIR}/SVMClassification_$(basename $SVMSETTINGSFILE .mat).runlimit"
            SVMRESULTFILECOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "$SVMRESULTFILEBASE*.results" | wc -l)
            #SVMJOBCOUNT=$($IBRAIN_BIN_PATH/countjobs.sh $(basename $SVMSETTINGSFILE))
            SVMJOBCOUNT=$(grep $(basename $SVMSETTINGSFILE) $JOBSFILE -c)
            if [ ! -d $POSTANALYSISDIR ]; then
                mkdir -p $POSTANALYSISDIR
            fi

            if [ ! -e $SVMSUBMITTEDFILE ] && [ ! -e $SVMOUTPUTFILE ]; then
                BOOLSVMSWAITING=1;

                echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">submitting"
                #echo "      <message>"
                #echo "      SUBMITTING: $(basename $SVMSETTINGSFILE)"
                #echo "      </message>"
                echo "      <output>"
                SVMRESULTFILE="$SVMRESULTFILEBASE$(date +"%y%m%d%H%M%S").results"
                # do a 8h submission in case of timeout, otherwise do a 1h submission.
                 if [ -e $SVMRUNLIMITFILE ]; then
bsub -W 36:00 -R 'rusage[mem=4096]' -o "${BATCHDIR}$SVMRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
SVM_Classify_with_Probabilities_iBRAIN('${SVMSETTINGSFILE}','${BATCHDIR}');
M_PROG"
                else
bsub -W 8:00 -R 'rusage[mem=2048]' -o "${BATCHDIR}$SVMRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
SVM_Classify_with_Probabilities_iBRAIN('${SVMSETTINGSFILE}','${BATCHDIR}');
M_PROG"
                fi
# bsub -W 36:00 -R 'rusage[mem=16384]' -o "${BATCHDIR}$SVMRESULTFILE" "matlab -singleCompThread -nodisplay << M_PROG
# SVM_Classify_with_Probabilities_iBRAIN('${SVMSETTINGSFILE}','${BATCHDIR}');
# M_PROG"
                touch $SVMSUBMITTEDFILE
                echo "      </output>"
                echo "     </status>"


            # no output yet                has been submitted          has jobs present        no output jet
            elif [ ! -e $SVMOUTPUTFILE ] && [ -e $SVMSUBMITTEDFILE ] && [ $SVMJOBCOUNT -gt 0 ] && [ $SVMRESULTFILECOUNT -eq 0 ]; then
                BOOLSVMSWAITING=1;

                echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">waiting"
                #echo "      <message>"
                #echo "      WAITING: $(basename $SVMSETTINGSFILE): $SVMJOBCOUNT JOB(S) PRESENT"
                #echo "      </message>"
                echo "     </status>"

            # no output yet                has been submitted          no jobs present           results never produced
            elif [ ! -e $SVMOUTPUTFILE ] && [ -e $SVMSUBMITTEDFILE ] && [ $SVMJOBCOUNT -eq 0 ] && [ $SVMRESULTFILECOUNT -eq 0 ]; then
                BOOLSVMSWAITING=1;

                echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">failed"
                echo "      <warning>"
                echo "      FAILED: $(basename $SVMSETTINGSFILE): RETRYING CLASSIFICATION. PREVIOUS JOB DID NOT PRODUCE OUTPUT (?!)"
                echo "      </warning>"
                echo "      <output>"
                rm -fv $SVMSUBMITTEDFILE
                echo "      </output>"
                echo "     </status>"

            # no output yet                has been submitted          no jobs present           results produced once
            elif [ ! -e $SVMOUTPUTFILE ] && [ -e $SVMSUBMITTEDFILE ] && [ $SVMJOBCOUNT -eq 0 ] && [ $SVMRESULTFILECOUNT -eq 1 ]; then
                BOOLSVMSWAITING=1;

                echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">failed"
                echo "      <warning>"
                echo "      FAILED: $(basename $SVMSETTINGSFILE): RETRYING CLASSIFICATION"
                echo "      </warning>"
                echo "      <output>"
                ### check resultfiles for known errors, reset/resubmit jobs if appropriate
                $IBRAIN_BIN_PATH/check_resultfiles_for_known_errors.sh $BATCHDIR "$SVMRESULTFILEBASE" $SVMSUBMITTEDFILE
                rm -fv $SVMSUBMITTEDFILE
                echo "      </output>"
                echo "     </status>"

            # no output yet                has been submitted          no jobs present           results produced twice
            elif [ ! -e $SVMOUTPUTFILE ] && [ -e $SVMSUBMITTEDFILE ] && [ $SVMJOBCOUNT -eq 0 ] && [ $SVMRESULTFILECOUNT -eq 2 ]; then

                echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">failed"
                echo "      <warning>"
                echo "      ABORTED: $(basename $SVMSETTINGSFILE): FAILED TWICE"
                echo "      </warning>"
                echo "      <output>"
                ### check resultfiles for known errors, reset/resubmit jobs if appropriate
                $IBRAIN_BIN_PATH/check_resultfiles_for_known_errors.sh $BATCHDIR "$SVMRESULTFILEBASE" $SVMSUBMITTEDFILE
                echo "      </output>"
                echo "     </status>"

            # output present
            elif [ -e $SVMOUTPUTFILE ] ; then

                echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">completed"
                #echo "      <message>"
                #echo "      COMPLETED: $(basename $SVMSETTINGSFILE)"
                #echo "      </message>"
                if [ -e $SVMOVERVIEWPDFFILE ]; then
                    echo "     <file type=\"pdf\">$SVMOVERVIEWPDFFILE</file>"
                fi
                if [ -e $SVMOVERVIEWCSVFILE ]; then
                    echo "     <file type=\"csv\">$SVMOVERVIEWCSVFILE</file>"
                fi

                echo "     </status>"

            else

                echo "     <status action=\"$(basename $SVMSETTINGSFILE)\">unknown"
                echo "      <warning>"
                echo "      UNKNOWN STATUS: $(basename $SVMSETTINGSFILE)"
                if [ -e $SVMSETTINGSFILE ]; then
                    echo "        DEBUG: SVMSETTINGSFILE=$SVMSETTINGSFILE (present)"
                else
                    echo "        DEBUG: SVMSETTINGSFILE=$SVMSETTINGSFILE (missing)"
                fi
                if [ -e $SVMOUTPUTFILE ]; then
                    echo "        DEBUG: SVMOUTPUTFILE=$SVMOUTPUTFILE (present)"
                else
                    echo "        DEBUG: SVMOUTPUTFILE=$SVMOUTPUTFILE (missing)"
                fi
                if [ -e $SVMSUBMITTEDFILE ]; then
                    echo "        DEBUG: SVMSUBMITTEDFILE=$SVMSUBMITTEDFILE (present)"
                else
                    echo "        DEBUG: SVMSUBMITTEDFILE=$SVMSUBMITTEDFILE (missing)"
                fi
                echo "        DEBUG: SVMRESULTFILEBASE=$SVMRESULTFILEBASE"
                echo "        DEBUG: SVMRESULTFILECOUNT-SEARCH-STRING=$SVMRESULTFILEBASE*.results"
                echo "        DEBUG: SVMRESULTFILECOUNT=$SVMRESULTFILECOUNT"
                echo "        DEBUG: SVMJOBCOUNT=$SVMJOBCOUNT"

                echo "      </warning>"
                echo "      <output>"
                ### check resultfiles for known errors, reset/resubmit jobs if appropriate
                $IBRAIN_BIN_PATH/check_resultfiles_for_known_errors.sh $BATCHDIR "$SVMRESULTFILEBASE" $SVMSUBMITTEDFILE
                echo "      </output>"

                echo "     </status>"

            fi

        done #LOOP OVER SVMSETTINGS FILES
        echo "     </status>"

    fi # end of svms

}

# run standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main
