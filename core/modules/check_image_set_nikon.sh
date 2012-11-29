#! /bin/bash
#
# check_image_set_nikon.sh

############################
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh #
############################

function main {

###################
#### VARIABLES ####
###################
        
        FOLDER='NIKON'
        IMGDIR="${PROJECTDIR}/${FOLDER}"
        FLAGPREFIX='CheckNikonImageSet'
        COMPLETEFLAG="${IMGDIR}/${FLAGPREFIX}.complete"

        if [ ! -d $IMGDIR ]; then
            # Nothing to do. Just jump to the next iBRAIN module.
            return
        fi

        # CHECK IF IMAGE SET IS COMPLETE
        IMGDIRLASTMODIFIED=$(find $PROJECTDIR -maxdepth 1 -type d -mmin +30 -name "$FOLDER" | wc -l)

        echo "<!-- COMPLETEFILECHECK=$COMPLETEFILECHECK -->"
        echo "<!-- IMGDIRLASTMODIFIED=$IMGDIRLASTMODIFIED -->"

        ### CHECK IF IMAGE FOLDER IS COMPLETE
        if [ ! -e $COMPLETEFLAG ] && [ $IMGCOUNT -eq 0 ]; then

            echo "     <status action=\"${MODULENAME}\">paused"
            echo "      <message>"
            echo "    Paused because the $FOLDER directory contains no images."
            echo "      </message>"
            echo "     </status>"

        elif [ ! -e $COMPLETEFLAG ] && [ $IMGDIRLASTMODIFIED -eq 0 ]; then

            echo "     <status action=\"${MODULENAME}\">waiting"
            echo "      <message>"
            echo "    Waiting because the $FOLDER directory has been modified in the last 30 minutes."
            echo "      </message>"

            echo "      <output>"
            ### Add a TIMEOUT progress bar.
                TIMELASTMODIFIED=$(stat -c %Y ${IBRAIN_ROOT}/iBRAIN_project.sh)
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

        elif [ ! -e $COMPLETEFLAG ] && [ $IMGDIRLASTMODIFIED -eq 1 ]; then
                           
            if [ ! -e $COMPLETEFLAG ]; then

                echo "     <status action=\"${MODULENAME}\">failed"
                echo "      <warning>"
                echo "       ${MODULENAME} FAILED: CAN NOT WRITE TO $FOLDER DIRECTORY!"
                echo "      </warning>"
                echo "       <output>"
                touch $COMPLETEFLAG
                echo "       </output>"
                echo "     </status>"
            else
                echo "     <status action=\"${MODULENAME}\">submitting"
                echo "      <message>"
                echo "       $FOLDER directory has passed waiting fase. Continue.."
                echo "      </message>"
                echo "      <output>"
                touch $COMPLETEFLAG
                echo "      </output>"
                echo "     </status>"
            fi
     
        fi

} 

# run standardized bash-error handling of iBRAIN
execute_ibrain_module

# clear main module function
unset -f main
