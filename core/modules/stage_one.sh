#! /bin/bash
#
# stage_one.sh
        
############################ 
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh #
############################ 

function main {

    ###################
    #### VARIABLES ####
    ###################

    ### CHECK FOR PLATE SPECIFIC PRECLUSTER SETTINGS FILE
    # By defauls a plate will be analyzed by the project-wide PreCluster_*.mat file.
    # However, if there is a plate-specific PreCluster_*.mat file, this overrules the the project-wide file.

    # set by default to project wide precluster file
    PLATEPRECLUSTERSETTINGS="$PRECLUSTERSETTINGS"
    # then look for plate settings files, if present, use this. All precluster.sh calls should use $PLATEPRECLUSTERSETTINGS
    for FOUNDSETTINGSFILE in `find $PROJECTDIR -maxdepth 1 -type f -iname 'PreCluster*.mat'`
    do
            PLATEPRECLUSTERSETTINGS="$FOUNDSETTINGSFILE"
    done
    echo "   <pipeline>$PLATEPRECLUSTERSETTINGS</pipeline>"

    # CHECK IF IMAGE SET IS COMPLETE
    COMPLETEFILECHECK=$(find $TIFFDIR -maxdepth 1 -type f -name "CheckImageSet_*.complete" | wc -l)
    TIFFDIRLASTMODIFIED=$(find $PROJECTDIR -maxdepth 1 -type d -mmin +30 -name "TIFF" | wc -l)

    # SEE IF THERE IS A Measurements_Image_ObjectCount.mat FILE
    OBJECTCOUNTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_Image_ObjectCount.mat" | wc -l)

    echo "<!-- COMPLETEFILECHECK=$COMPLETEFILECHECK -->"
    echo "<!-- TIFFDIRLASTMODIFIED=$TIFFDIRLASTMODIFIED -->"


    # PNG CONVERSION (ConvertAllTiff2Png)
    if [ $COMPLETEFILECHECK -eq 0 ]; then
        TIFFCOUNT=$(find $TIFFDIR -maxdepth 1 -type f -iname "*.tif" -o -maxdepth 1 -type f -name "*.png" | wc -l)
        echo "<!-- TIFFCOUNT=$TIFFCOUNT -->"
    fi


    PRECLUSTERCHECK=$(find $BATCHDIR -maxdepth 1 -type f -name "PreCluster_*.results" | wc -l)

    CPCLUSTERRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Batch_*.results" | wc -l)

    BATCHJOBCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Batch_*.txt" | wc -l)
    echo "     <total_batch_job_count>$BATCHJOBCOUNT</total_batch_job_count>"

    OUTPUTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Batch_*_OUT.mat" | wc -l)
    echo "     <completed_batch_job_count>$OUTPUTCOUNT</completed_batch_job_count>"

    #################### BATCHDIR CLEANUP ####################
    # Some projects are big, let's delete all Batch_*_to_*.mat, Batch_*_to_*.txt & Batch_*_to_*.results files
    if [ $OUTPUTCOUNT -gt 1 ] && [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then
        echo "<!-- cleaning up BATCH directory a bit..."
    rm -f $BATCHDIR/Batch_*_to_*.mat
    rm -f $BATCHDIR/Batch_*_to_*.txt
    rm -f $BATCHDIR/Batch_*_to_*.results
        echo "-->"
    fi
        ################ END OF BATCHDIR CLEANUP ################

    # DATAFUSION
    DATAFUSIONRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_*.mat" | wc -l)
    EXPECTEDMEASUREMENTS=$(find $BATCHDIR -maxdepth 1 -type f -name "Batch_2_to_*_Measurements_*.mat" | wc -l)


    #DATAFUSION CHECK AND CLEANUP
    FAILEDDATACHECKRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "Measurements_*.datacheck-*"| wc -l)
    DATAFUSIONCHECKRESULTCOUNT=$(find $BATCHDIR -maxdepth 1 -type f -name "DataFusionCheckAndCleanup_*.results" | wc -l)


    ##################
    ### PRECLUSTER ###

    ### CHECK IF IT HAS BEEN PRECLUSTERED ALREADY
    if [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && ( [ ! -d $BATCHDIR ] || [ $BATCHJOBCOUNT -eq 0 ] ) && [ ! -e $PROJECTDIR/PreCluster.submitted ]; then

        # LOOK FOR SETTINGS FILE IN PROJECTDIR
        # PLATEPRECLUSTERSETTINGS=$(~/iBRAIN/searchforpreclusterfile.sh ${PROJECTDIR} ${PLATEPRECLUSTERSETTINGS} ${PRECLUSTERBACKUPPATH})

        if [ "$PLATEPRECLUSTERSETTINGS" ] && [ "$PLATEPRECLUSTERSETTINGS" != " " ] && [ -f $PLATEPRECLUSTERSETTINGS ]; then
            #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): submitting precluster with $(basename $PLATEPRECLUSTERSETTINGS)"
            echo "     <status action=\"precluster\">submitting"
            echo "      <output>"
            if [ ! -e $BATCHDIR ]; then
                mkdir -p $BATCHDIR
            fi
            if [ ! -d $POSTANALYSISDIR ]; then
                mkdir -p $POSTANALYSISDIR
            fi
            ~/iBRAIN/precluster.sh $PROJECTDIR $PLATEPRECLUSTERSETTINGS
            echo "      </output>"
            echo "     </status>"
        else
            echo "     <status action=\"precluster\">paused"
            echo "      <message>"
            echo " Plate processing is paused. No CellProfiler pipeline provided for this project, please add one to the root of this project or to the root of this plate. Make sure that the PreCluster file starts with PreCluster_ and ends with .mat"
            echo "      </message>"
            echo "     </status>"
        fi

    ### IF HAS BEEN SUBMITTED FOR PRECLUSTER BUT NO PRECLUSTERRESULTS ARE PRESENT DO NOTHING
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $PRECLUSTERCHECK -eq 0 ]  && [ -e $PROJECTDIR/PreCluster.submitted ]; then

        echo "     <status action=\"precluster\">waiting"
        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): waiting for precluster to finish"

        ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
        if [ $PLATEJOBCOUNT -eq 0 ]; then
            echo "      <warning>"
                echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
                rm -f $PROJECTDIR/PreCluster.submitted
            echo "      </warning>"
        fi
        echo "     </status>"

    ### IF PreCluster_*.results EXISTS AND NO BATCHJOBS ARE FOUND, PRECLUSTER FAILED
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $BATCHJOBCOUNT -eq 0 ] && [ $PRECLUSTERCHECK -gt 0 ] && [ ! -e $PROJECTDIR/PreCluster.resubmitted ]; then

        echo "     <status action=\"precluster\">resubmitting"
        echo "      <warning>"
        echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): PreCluster failed. Submitting PreCluster again"
        echo "      </warning>"
        # LOOK FOR SETTINGS FILE

        #for FOUNDSETTINGSFILE2 in `find $PROJECTDIR -maxdepth 1 -type f -iname 'PreCluster*.mat'`
        #do
        #    PRECLUSTERSETTINGS="$FOUNDSETTINGSFILE2"
        #done

        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): submitting precluster with $(basename $PRECLUSTERSETTINGS)"

        echo "      <output>"
        touch $PROJECTDIR/PreCluster.resubmitted
        ~/iBRAIN/precluster.sh $PROJECTDIR $PLATEPRECLUSTERSETTINGS
        echo "      </output>"
        echo "     </status>"

    ### IF PRECLUSTER RESUBMITTED BUT NOT FINISHED YET
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $BATCHJOBCOUNT -eq 0 ] && [ $PRECLUSTERCHECK -eq 1 ] && [ -e $PROJECTDIR/PreCluster.resubmitted ]; then


        echo "     <status action=\"precluster\">waiting"
        echo "      <warning>"
        echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Waiting for second PreCluster attempt"
        echo "      </warning>"
        echo "      <output>"
        if [ $PLATEJOBCOUNT -eq 0 ]; then
            echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. CHECKING RESULT FILES FOR KNOWN ERRORS"
            # check resultfiles for known errors, reset/resubmit jobs if appropriate
            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "PreCluster_" $PROJECTDIR/PreCluster.resubmitted
        fi
        echo "      </output>"
        echo "     </status>"

    ### IF PRECLUSTER RESUBMITTED FAILED AGAIN, ABORT DIRECTORY
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $BATCHJOBCOUNT -eq 0 ] && [ $PRECLUSTERCHECK -gt 1 ] && [ -e $PROJECTDIR/PreCluster.resubmitted ]; then

        echo "     <status action=\"precluster\">failed"
        echo "      <warning>"
        echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Second PreCluster attempt failed. Aborting directory"
        echo "      </warning>"
        echo "      <output>"
        if [ $PLATEJOBCOUNT -eq 0 ]; then
            #echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. CHECKING RESULT FILES FOR KNOWN ERRORS"
            # check resultfiles for known errors, reset/resubmit jobs if appropriate
            ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR "PreCluster_" $PROJECTDIR/PreCluster.resubmitted
        fi
        echo "      </output>"
        echo "     </status>"

    #################
    ### CPCLUSTER ###

    ### IF BATCHJOBS ARE FOUND AND HAVE NOT YET BEEN SUBMITTED, SUBMIT THEM
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $BATCHJOBCOUNT -gt 0 ] && [ ! -e $PROJECTDIR/SubmitBatchJobs.submitted ] && [ $OUTPUTCOUNT -eq 0 ]; then

        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): submitting CPCluster batch jobs"
        echo "     <status action=\"cpcluster\">submitting"
        echo "      <output>"
        ~/iBRAIN/submitbatchjobs.sh $BATCHDIR
        echo "      </output>"
        echo "     </status>"

    ### IF BATCHJOBS HAVE NOT BEEN SUBMITTED VIA iBRAIN AND NOT ALL JOBS HAVE FINISHED
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $BATCHJOBCOUNT -gt 0 ] && [ ! -e $PROJECTDIR/SubmitBatchJobs.submitted ] && [ $OUTPUTCOUNT -lt $BATCHJOBCOUNT ]; then

        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): submitting batch jobs"
        echo "     <status action=\"cpcluster\">submitting"
        echo "      <output>"
        ~/iBRAIN/submitbatchjobs.sh $BATCHDIR
        echo "      </output>"
        echo "     </status>"


    ### IF BATCHJOBS HAVE BEEN SUBMITTED BUT NOT ALL JOBS HAVE FINISHED DO NOTHING
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $CPCLUSTERRESULTCOUNT -lt $BATCHJOBCOUNT ] && [ $OUTPUTCOUNT -lt $BATCHJOBCOUNT ]; then



        # ##########
        # ### [091208 BS] A more detailed analysis progress bar:
        # Here we could do a SEGMENTATION filecount check to see the actual
        #	progress of analysis (of course depends on SaveObjectSegmentation
        #   like modules in the cellprofiler pipeline...
        if [ -d ${PROJECTDIR}/SEGMENTATION/ ]; then
            BATCHSIZE=$( find $BATCHDIR -name "Batch_2_to_*.mat" | head -n 1 | sed 's/.*Batch_2_to_\([0-9]*\).*\.mat/\1/')
            SEGMENTATIONCOUNT=$(find ${PROJECTDIR}/SEGMENTATION/ -maxdepth 1 -type f -name "*_SegmentedNuclei.png" | wc -l)
            if [ $SEGMENTATIONCOUNT -eq 0 ]; then
                SEGMENTATIONCOUNT=$(find ${PROJECTDIR}/SEGMENTATION/ -maxdepth 1 -type f -name "*_SegmentedCells.png" | wc -l)
            fi
            PROGRESSVALUE=$(echo "scale=2; (${SEGMENTATIONCOUNT} / (${BATCHSIZE} * ${BATCHJOBCOUNT})) * 100;" | bc)
        fi
        ##########

        echo "     <status action=\"cpcluster\">waiting"

        #echo "      <message>"
        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): waiting for batchjobs to finish"
        #echo "      </message>"

        echo "      <output>"

        ### DRAW PROGRESSBAR IF APPROPRIATE (Note: expected to be at /plates/plate/status/output/progressbar ... all others are ignored
        if [ "$PROGRESSVALUE" ]; then
            echo "       <progressbar text=\"CellProfiler batch jobs\">$PROGRESSVALUE</progressbar>"
        fi


        ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
        if [ $PLATEJOBCOUNT -eq 0 ]; then
            echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
            rm -f $PROJECTDIR/SubmitBatchJobs.submitted
        fi
        echo "      </output>"
        echo "     </status>"



    ### IF ALL JOBS HAVE FINISHED BUT NOT ALL OUTPUT IS THERE, RESUBMIT
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $CPCLUSTERRESULTCOUNT -ge $BATCHJOBCOUNT ] && [ $OUTPUTCOUNT -lt $BATCHJOBCOUNT ] && [ ! -e $PROJECTDIR/SubmitBatchJobs.resubmitted ]; then

        echo "     <status action=\"cpcluster\">resubmitting"
        #echo "      <message>"
        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): re-submitting batch jobs"
        #echo "      </message>"
        echo "      <output>"
        touch $PROJECTDIR/SubmitBatchJobs.resubmitted

        for BATCHJOBFILE in `find ${BATCHDIR} -name 'Batch_*.txt'`
        do
          if [ ! -r ${BATCHDIR}/$(basename $BATCHJOBFILE .txt)_OUT.mat ]; then
            REPORTFILE=$(basename $BATCHJOBFILE .txt)_%J_$(date +"%y%m%d%H%M%S").results
            if [ -e $PROJECTDIR/SubmitBatchJobs.runlimit ] || [ -e $PROJECTDIR/SubmitBatchJobs.resubmitted.runlimit ]; then
bsub -W 34:00 -o ${BATCHDIR}/$REPORTFILE -R 'rusage[mem=3000]' "matlab -singleCompThread -nodisplay -nojvm << M_PROG
CPCluster('${BATCHDIR}/Batch_data.mat','${BATCHDIR}/$(basename $BATCHJOBFILE .txt).mat');
M_PROG"
            else
bsub -W 8:00 -o ${BATCHDIR}/$REPORTFILE -R 'rusage[mem=2000]' "matlab -singleCompThread -nodisplay -nojvm << M_PROG
CPCluster('${BATCHDIR}/Batch_data.mat','${BATCHDIR}/$(basename $BATCHJOBFILE .txt).mat');
M_PROG"
            fi
            touch $PROJECTDIR/SubmitBatchJobs.submitted
          fi
        done

        #~/iBRAIN/submitbatchjobs.sh $BATCHDIR
        echo "      </output>"
        echo "     </status>"




    ### IF ALL JOBS HAVE FINISHED, AND SOME HAVE FINISHED MORE THEN ONCE, BUT NOT ALL OUTPUT IS THERE, FLAG FOLDER AS FAILED
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && ( [ $CPCLUSTERRESULTCOUNT -ge $BATCHJOBCOUNT ] || [ $BATCHJOBCOUNT -eq $CPCLUSTERRESULTCOUNT ] ) && [ $OUTPUTCOUNT -lt $BATCHJOBCOUNT ] && [ -e $PROJECTDIR/SubmitBatchJobs.resubmitted ]; then

        echo "     <status action=\"cpcluster\">waiting"
        #echo "      <message>"
        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Waiting for Batchjob resubmission to finish"
        #echo "      </message>"
        echo "      <output>"

        # ##########
        # ### [091208 BS] A more detailed analysis progress bar:
        # Here we could do a SEGMENTATION filecount check to see the actual
        #   progress of analysis (of course depends on SaveObjectSegmentation
        #   like modules in the cellprofiler pipeline...
        if [ -d ${PROJECTDIR}/SEGMENTATION/ ]; then
            BATCHSIZE=$( find $BATCHDIR -name "Batch_2_to_*.mat" | head -n 1 | sed 's/.*Batch_2_to_\([0-9]*\).*\.mat/\1/')
            SEGMENTATIONCOUNT=$(find ${PROJECTDIR}/SEGMENTATION/ -maxdepth 1 -type f -name "*_SegmentedNuclei.png" | wc -l)
            if [ $SEGMENTATIONCOUNT -eq 0 ]; then
                    SEGMENTATIONCOUNT=$(find ${PROJECTDIR}/SEGMENTATION/ -maxdepth 1 -type f -name "*_SegmentedCells.png" | wc -l)
            fi
            PROGRESSVALUE=$(echo "scale=2; (${SEGMENTATIONCOUNT} / (${BATCHSIZE} * ${BATCHJOBCOUNT})) * 100;" | bc)
            ### DRAW PROGRESSBAR IF APPROPRIATE (Note: expected to be at /plates/plate/status/output/progressbar ... all others are ignored
            if [ "$PROGRESSVALUE" ]; then
                        echo "       <progressbar text=\"CellProfiler batch jobs\">$PROGRESSVALUE</progressbar>"
            fi
        fi


        if [ $PLATEJOBCOUNT -eq 0 ]; then
            echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. CHECKING RESULT FILES FOR KNOWN ERRORS"
            #rm -f $PROJECTDIR/SubmitBatchJobs.submitted
            # check resultfiles for known errors, reset/resubmit jobs if appropriate
            # instead of checking all result files at the same time, we should loop over the individual batch jbos and check input/output. if missing,
            # only then check the result files. this will make the error-reporting much more informative/accurate
            for batchJob in $(find $BATCHDIR -maxdepth 1 -type f -name "Batch_*.txt"); do
               JOBBASENAME=$(basename $batchJob .txt)
               #echo "checking $JOBBASENAME"
               EXPECTEDOUTPUT=$(dirname $batchJob)/"${JOBBASENAME}_OUT.mat"
               if [ ! -e $EXPECTEDOUTPUT ]; then
                 echo "no output found for $JOBBASENAME"
                  ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR $JOBBASENAME $PROJECTDIR/SubmitBatchJobs.resubmitted
               fi
            done
        fi
        echo "      </output>"
        echo "     </status>"

    ### IF ALL JOBS HAVE FINISHED, AND SOME HAVE FINISHED MORE THEN ONCE, BUT NOT ALL OUTPUT IS THERE, FLAG FOLDER AS FAILED
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $CPCLUSTERRESULTCOUNT -ge $BATCHJOBCOUNT ] && [ $OUTPUTCOUNT -lt $BATCHJOBCOUNT ] && [ -e $PROJECTDIR/SubmitBatchJobs.resubmitted ]; then

        echo "     <status action=\"cpcluster\">failed"
        echo "      <warning>"
        echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Batch job file has failed repeatedly. Aborting folder"
        echo "      </warning>"
        echo "      <output>"
        ### check resultfiles for known errors, reset/resubmit jobs if appropriate
        if [ $PLATEJOBCOUNT -eq 0 ]; then
            echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. CHECKING RESULT FILES FOR KNOWN ERRORS"
            #rm -f $PROJECTDIR/SubmitBatchJobs.submitted
            # check resultfiles for known errors, reset/resubmit jobs if appropriate
            # instead of checking all result files at the same time, we should loop over the individual batch jbos and check input/output. if missing,
            # only then check the result files. this will make the error-reporting much more informative/accurate
            for batchJob in $(find $BATCHDIR -maxdepth 1 -type f -name "Batch_*.txt"); do
               JOBBASENAME=$(basename $batchJob .txt)
               #echo "checking $JOBBASENAME"
               EXPECTEDOUTPUT="${JOBBASENAME}_OUT.mat"
               if [ ! -e $EXPECTEDOUTPUT ]; then
                  #echo "no output found for $JOBBASENAME"
                  ~/iBRAIN/check_resultfiles_for_known_errors.sh $BATCHDIR $JOBBASENAME $PROJECTDIR/SubmitBatchJobs.resubmitted
               fi
            done
        fi
        echo "      </output>"
        echo "     </status>"


    ########################################
    ### DATAFUSION AND CHECK AND CLEANUP ###

    ### IF ALL BATCHJOB OUTPUT EQUALS BATCHJOBS THEN SUBMIT DATAFUSION
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $BATCHJOBCOUNT -eq $OUTPUTCOUNT ] && [ ! -e $PROJECTDIR/DataFusion.submitted ]; then

        echo "     <status action=\"datafusion\">submitting"
        #echo "      <message>"
        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Submitting datafusion"
        #echo "      </message>"
        echo "      <output>"

        echo DATAFUSIONRESULTCOUNT=$DATAFUSIONRESULTCOUNT
        echo EXPECTEDMEASUREMENTS=$EXPECTEDMEASUREMENTS
        touch $PROJECTDIR/DataFusion.submitted
        ~/iBRAIN/datafusion.sh $BATCHDIR

        echo "      </output>"
        echo "     </status>"





    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $DATAFUSIONRESULTCOUNT -lt $EXPECTEDMEASUREMENTS ] && [ -e $PROJECTDIR/DataFusion.submitted ]; then

        echo "     <status action=\"datafusion\">waiting"
        #echo "      <message>"
        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): waiting for datafusion to finish"
        #echo "      </message>"
        echo "      <output>"
        ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
        if [ $PLATEJOBCOUNT -eq 0 ]; then
            echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
            rm -f $PROJECTDIR/DataFusion.submitted
        fi

        ### [091208 BS] Add a DATAFUSION progress bar!
        PROGRESSBARVALUE=$(echo "scale=2; (${DATAFUSIONRESULTCOUNT} / ${EXPECTEDMEASUREMENTS}) * 100;" | bc)
        if [ "$PROGRESSBARVALUE" ]; then
            echo "       <progressbar text=\"datafusion\">$PROGRESSBARVALUE</progressbar>"
        fi


        echo "      </output>"
        echo "     </status>"






    ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT CHECK DATAFUSION AND CLEANUP BATCH FILES
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ -e $PROJECTDIR/DataFusion.submitted ] && [ ! -e $PROJECTDIR/DataFusionCheckAndCleanup.submitted ]; then

        ### ONLY SUBMIT datafusioncheckandcleanup IF THERE ARE LESS THAN 60 DATAFUSION-CHECK JOBS PRESENT, OTHERWISE THE NAS WILL FREAK OUT BECAUSE OF HIGH I/O
        DATAFUSIONCHECKJOBCOUNT=$(~/iBRAIN/countjobs.sh datafusioncheckandcleanup)
        #DATAFUSIONCHECKJOBCOUNT=$(grep "datafusioncheckandcleanup" $JOBSFILE -c)
        if [ $DATAFUSIONCHECKJOBCOUNT -lt 60 ]; then

        echo "     <status action=\"datafusion-check-and-cleanup\">submitting"
        #echo "      <message>"
        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Submitting datafusion check and cleanup of batch files ($DATAFUSIONCHECKJOBCOUNT similar jobs present)"
        #echo "      </message>"
        echo "      <output>"

           ~/iBRAIN/submitdatafusioncheckandcleanup.sh $BATCHDIR

        echo "      </output>"
        echo "     </status>"

        else

        echo "     <status action=\"datafusion-check-and-cleanup\">waiting"
        #echo "      <message>"
        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Not submitting datafusion check and cleanup of batch files: too many ($DATAFUSIONCHECKJOBCOUNT) similar jobs present"
        #echo "      </message>"
        echo "     </status>"

        fi

    ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT CHECK DATAFUSION AND CLEANUP BATCH FILES
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ -e $PROJECTDIR/DataFusionCheckAndCleanup.submitted ] && [ $DATAFUSIONCHECKRESULTCOUNT -eq 0 ]; then

        echo "     <status action=\"datafusion-check-and-cleanup\">waiting"
        #echo "      <message>"
        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Waiting for datafusion check and cleanup to finish"
        #echo "      </message>"


        echo "      <output>"
        ### EXPERIMENTAL: IF NO JOBS ARE FOUND FOR THIS PROJECT, WAITING IS SENSELESS. REMOVE .submitted FILE AND TRY AGAIN
        if [ $PLATEJOBCOUNT -eq 0 ]; then
            echo "  ALERT: iBRAIN IS WAITING, BUT THERE ARE NO JOBS (PENDING OR RUNNING) FOR THIS PROJECT. RETRYING THIS FOLDER"
            rm -f $PROJECTDIR/DataFusionCheckAndCleanup.submitted
        fi
        echo "      </output>"
        echo "     </status>"

    ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT CHECK DATAFUSION AND CLEANUP BATCH FILES

    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ -e $PROJECTDIR/DataFusionCheckAndCleanup.submitted ] && [ $DATAFUSIONCHECKRESULTCOUNT -gt 0 ] && [ $EXPECTEDMEASUREMENTS -eq 1 ]; then

        echo "     <status action=\"datafusion-check-and-cleanup\">datafusion finished once, but did not remove all Batch measurements... resubmitting"
        #echo "      <message>"
        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Waiting for datafusion check and cleanup to finish"
        #echo "      </message>"


        echo "      <output>"
        echo "  RESETTING DATAFUSIONCHECKANDCLEANUP (UNORTHODOX :-)"
        # rm -f $PROJECTDIR/DataFusionCheckAndCleanup.submitted
        rm -f $BATCHDIR/DataFusionCheckAndCleanup_*.results
        ~/iBRAIN/submitdatafusioncheckandcleanup.sh $BATCHDIR
        echo "      </output>"
        echo "     </status>"


    ### CHECK IF ALL DATAFUSION FILES PASSED THE CHECK; IF NOT, RESUBMIT DATAFUSION AS A FIRST ATTEMPT
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $FAILEDDATACHECKRESULTCOUNT -gt 0 ] && [ ! -e $PROJECTDIR/DataFusion.resubmitted ]; then

        echo "     <status action=\"datafusion\">resubmitting"
        echo "      <message>"
        echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Re-submitting datafusion, corrupt datafusion files found"
        echo "      </message>"
        echo "      <output>"
        touch $PROJECTDIR/DataFusion.resubmitted
        ~/iBRAIN/datafusion.sh $BATCHDIR
        echo "      </output>"
        echo "     </status>"

    ### CHECK IF ALL DATAFUSION FILES PASSED THE CHECK; IF NOT, RESUBMIT DATAFUSION AS A FIRST ATTEMPT
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $FAILEDDATACHECKRESULTCOUNT -eq 0 ] && [ $EXPECTEDMEASUREMENTS -gt 0 ] && [ ! -e $PROJECTDIR/DataFusion.resubmitted ]; then

        echo "     <status action=\"datafusion\">resubmitting"
        echo "      <message>"
        echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Re-submitting datafusion, still found BATCH measurements to process"
        echo "      </message>"
        echo "      <output>"
        touch $PROJECTDIR/DataFusion.resubmitted
        ~/iBRAIN/datafusion.sh $BATCHDIR
        echo "      </output>"
        echo "     </status>"

    ### IF ALL EXPECTED MEASUREMENTS ARE PRESENT CHECK DATAFUSION AND CLEANUP BATCH FILES
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ -e $PROJECTDIR/DataFusion.resubmitted ] && [ $FAILEDDATACHECKRESULTCOUNT -eq 0 ] && [ $EXPECTEDMEASUREMENTS -gt 0 ] && [ ! -e $PROJECTDIR/DataFusionCheckAndCleanup.resubmitted ]; then

        echo "     <status action=\"datafusion-check-and-cleanup\">resubmitting"
        #echo "      <message>"
        #echo "  PROCESSING $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Re-submitting datafusion check and cleanup of batch files"
        #echo "      </message>"
        echo "      <output>"
        touch $PROJECTDIR/DataFusionCheckAndCleanup.resubmitted
        ~/iBRAIN/submitdatafusioncheckandcleanup.sh $BATCHDIR
        echo "      </output>"
        echo "     </status>"

    ### IF RESUBMIT DATAFUSION STILL FAILED, FLAG IT AS SUCH
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $FAILEDDATACHECKRESULTCOUNT -gt 0 ] && [ -e $PROJECTDIR/DataFusion.resubmitted ] && [ ! -e $PROJECTDIR/InfectionScoring.submitted ]; then

        echo "     <status action=\"datafusion-check-and-cleanup\">failed"
        echo "      <warning>"
        echo "  $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): Corrupt datafusion files found after second datafusion attempt."

        # [BS-TEMP-BUGFIX] ONE TIME DEBUG, TO RESUBMIT ALL DATAFUSIONCHECK JOBS, TO FORCE
        # A RERUN WITH THE NEW AND MORE RELAXED DATAFUSIONCHECKANDCLEANUP FUNCTION IN MATLAB
        # echo "  APPLYING TEMPORARY FIX BY BEREND -- REMOVE THE LINE BELOW!!! "
        # rm -v $PROJECTDIR/DataFusionCheckAndCleanup.resubmitted
        # [END OF TEMP BUGFIX]

        echo "      </warning>"
        echo "     </status>"

    ### FLAG STAGE 1 AS COMPLETED
    elif [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $FAILEDDATACHECKRESULTCOUNT -eq 0 ] && [ $EXPECTEDMEASUREMENTS -eq 0 ] && [ $DATAFUSIONCHECKRESULTCOUNT -gt 0 ]; then

        echo "     <status action=\"${MODULENAME}\">completed"
        if [ $OBJECTCOUNTCOUNT -eq 0 ]; then
            echo "      <message>"
            echo "  NOTE, You did not create any objects in your CellProfiler pipeline, as Measurements_Image_ObjectCount.mat is missing."
            echo "      </message>"
        fi
        echo "     </status>"

        #echo "  COMPLETED STAGE 1 $(basename $PROJECTDIR)"
        if [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then
            touch $PROJECTDIR/iBRAIN_Stage_1.completed
        fi

    ### FLAG STAGE 1 AS COMPLETED, BECAUSE IT WAS PREVIOUSLY FLAGGED AS COMPLETED
    elif [ -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then

        echo "     <status action=\"${MODULENAME}\">completed"
        if [ $OBJECTCOUNTCOUNT -eq 0 ]; then
            echo "      <message>"
            echo "  NOTE, You did not create any objects in your CellProfiler pipeline, as Measurements_Image_ObjectCount.mat is missing."
            echo "      </message>"
        fi
        echo "     </status>"

    else

        echo "     <status action=\"${MODULENAME}\">unknown"
        echo "      <warning>"
        echo "  UNKNOWN STATUS $(basename $PROJECTDIR) ($PLATEJOBCOUNT JOBS): but most likely finished"
        echo "      </warning>"
        echo "     </status>"

        if [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ]; then
            touch $PROJECTDIR/iBRAIN_Stage_1.completed
        fi

        WARNINGFLAG=1

    fi # if [ ! -e $PROJECTDIR/iBRAIN_Stage_1.completed ] && [ $COMPLETEFILECHECK -eq 0 ]; then

}

# run standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main
