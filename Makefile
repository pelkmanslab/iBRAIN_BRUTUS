CURR_FOLDER=.
INSTALL_FOLDER=~/iBRAIN

all:
		@echo 'iBRAIN Makefile'

install:
		[ -d ${INSTALL_FOLDER} ] || mkdir ${INSTALL_FOLDER}
		cp ${CURR_FOLDER}/*.sh ${INSTALL_FOLDER}/
		
