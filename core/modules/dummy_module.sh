#! /bin/bash
#
# dummy_module.sh


############################
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh #
############################

function main {
       
    echo "     <status action=\"${MODULENAME}\">skipping"
    echo "      <message>"
    echo "       This is a dummy module that does not do anything."
    echo "      </message>"
    echo "     </status>"                  
}

execute_ibrain_module

unset -f main
