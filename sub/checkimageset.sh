#! /bin/sh
#
# checkimageset.sh

############################
#  INCLUDE PARAMETER CHECK #
. ./sub/parameter_check.sh #
############################

###################
#### VARIABLES ####
###################

        # CHECK IF IMAGE SET IS COMPLETE
        COMPLETEFILECHECK=$(find $TIFFDIR -maxdepth 1 -type f -name "CheckImageSet_*.complete" | wc -l)
        TIFFDIRLASTMODIFIED=$(find $PROJECTDIR -maxdepth 1 -type d -mmin +30 -name "TIFF" | wc -l)

        echo "<!-- COMPLETEFILECHECK=$COMPLETEFILECHECK -->"
        echo "<!-- TIFFDIRLASTMODIFIED=$TIFFDIRLASTMODIFIED -->"

        # PNG CONVERSION (ConvertAllTiff2Png)
        if [ $COMPLETEFILECHECK -eq 0 ]; then
            TIFFCOUNT=$(find $TIFFDIR -maxdepth 1 -type f -iname "*.tif" -o -maxdepth 1 -type f -name "*.png" | wc -l)
            echo "<!-- TIFFCOUNT=$TIFFCOUNT -->"
        else
            # Ensure backward compatibility
            if [ ! -e ${BATCHDIR}/checkimageset.complete ]; then            
                echo "      <!--"                
                touch ${BATCHDIR}/checkimageset.complete
                echo "      -->"
            fi
        fi



        ### CHECK IF IMAGE FOLDER IS COMPLETE
        if [ $COMPLETEFILECHECK -eq 0 ] && [ $TIFFCOUNT -eq 0 ]; then

            echo "     <status action=\"check-image-set\">paused"
            echo "      <message>"
            echo "    Paused because the TIFF directory contains no tif images."
            echo "      </message>"
            echo "     </status>"

        elif [ $COMPLETEFILECHECK -eq 0 ] && [ $TIFFDIRLASTMODIFIED -eq 0 ]; then

            echo "     <status action=\"check-image-set\">waiting"
            echo "      <message>"
            echo "    Waiting because the TIFF directory has been modified in the last 30 minutes."
            echo "      </message>"

            echo "      <output>"
            ### [091208 BS] Add a TIMEOUT progress bar!
                TIMELASTMODIFIED=$(stat -c %Y iBRAIN_project.sh)
                TIMENOW=$(date +%s)
                TIME_DIFF=$(expr $TIMENOW - $TIMELASTMODIFIED)
                # calculate as time in seconds since last modified date / 1800 (1800 sec = 30 min)
                        PROGRESSBARVALUE=$(echo "scale=2; (${TIME_DIFF} / 1800) * 100;" | bc)
                if [ "$PROGRESSBARVALUE" ]; then
                        echo "       <progressbar text=\"waiting for data timeout\">$PROGRESSBARVALUE</progressbar>"
                fi
                echo "TIMELASTMODIFIED=$TIMELASTMODIFIED"
                echo "TIMENOW=$TIMENOW"
                echo "TIME_DIFF=$TIME_DIFF"
            echo "      </output>"



            echo "     </status>"

        #elif [ $COMPLETEFILECHECK -eq 0 ] && [ $TIFFDIRLASTMODIFIED -eq 1 ]; then
        elif [ $COMPLETEFILECHECK -eq 0 ] && [ ! -e $BATCHDIR/ConvertAllTiff2Png.complete ]; then


            if [ ! -e $TIFFDIR/CheckImageSet_${TIFFCOUNT}.complete ]; then

                echo "     <status action=\"check-image-set\">failed"
                echo "      <warning>"
                echo "       check-image-set FAILED: CAN NOT WRITE TO TIFF DIRECTORY!"
                echo "      </warning>"
                echo "       <output>"
                touch $TIFFDIR/CheckImageSet_${TIFFCOUNT}.complete
                touch ${BATCHDIR}/checkimageset.complete
                echo "       </output>"
                echo "     </status>"
            else
                echo "     <status action=\"check-image-set\">submitting"
                echo "      <message>"
                echo "    TIFF directory has passed waiting fase. Creating BATCH directory and starting iBRAIN analysis."
                echo "      </message>"
                echo "      <output>"
                touch ${TIFFDIR}/CheckImageSet_${TIFFCOUNT}.complete
                touch ${BATCHDIR}/checkimageset.complete
                if [ ! -e $BATCHDIR ]; then
                    mkdir -p $BATCHDIR
                fi
                if [ ! -d $POSTANALYSISDIR ]; then
                    mkdir -p $POSTANALYSISDIR
                fi
                echo "      </output>"
                echo "     </status>"
            fi
        elif [ $COMPLETEFILECHECK -eq 1 ] && [ -e $BATCHDIR/ConvertAllTiff2Png.complete ]; then

            # create this for backward compatibility (i.e. to bring old datasetups up to date.
            if [ ! -e ${BATCHDIR}/checkimageset.complete ]; then
                touch ${BATCHDIR}/checkimageset.complete
            fi
            echo "     <status action=\"check-image-set\">completed</status>"
       
fi
