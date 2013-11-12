CURR_FOLDER=.
INSTALL_FOLDER=~/iBRAIN

all:
		@echo 'iBRAIN Makefile'

install:
		[ -d ${INSTALL_FOLDER} ] || mkdir ${INSTALL_FOLDER}
		cp ${CURR_FOLDER}/*.sh ${INSTALL_FOLDER}/
		cp ${CURR_FOLDER}/*.py ${INSTALL_FOLDER}/
		[ -d ${INSTALL_FOLDER}/bin ] || ln -s bin ${INSTALL_FOLDER}/bin
		[ -d ${INSTALL_FOLDER}/core ] || ln -s core ${INSTALL_FOLDER}/core
		[ -d ${INSTALL_FOLDER}/lib ] || ln -s lib ${INSTALL_FOLDER}/lib
		[ -d ${INSTALL_FOLDER}/etc ] || mkdir ${INSTALL_FOLDER}/etc
		[ -d ${INSTALL_FOLDER}/var ] || mkdir ${INSTALL_FOLDER}/var

