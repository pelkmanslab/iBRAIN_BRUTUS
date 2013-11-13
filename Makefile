CURR_FOLDER=.
INSTALL_FOLDER=~/iBRAIN

all:
		@echo 'iBRAIN Makefile'

install:
               echo 'Installing into ${INSTALL_FOLDER}'
               [ -d ${INSTALL_FOLDER} ] || mkdir ${INSTALL_FOLDER}
               cp ${CURR_FOLDER}/*.sh ${INSTALL_FOLDER}/
               cp ${CURR_FOLDER}/*.py ${INSTALL_FOLDER}/
               [ -d ${INSTALL_FOLDER}/bin ] || ln -s ${CURR_FOLDER}/bin ${INSTALL_FOLDER}/bin
               [ -d ${INSTALL_FOLDER}/core ] || ln -s ${CURR_FOLDER}/core ${INSTALL_FOLDER}/core
               [ -d ${INSTALL_FOLDER}/lib ] || ln -s ${CURR_FOLDER}/lib ${INSTALL_FOLDER}/lib
               [ -d ${INSTALL_FOLDER}/etc ] || mkdir ${INSTALL_FOLDER}/etc
               [ -d ${INSTALL_FOLDER}/var ] || mkdir ${INSTALL_FOLDER}/var
               [ -d ${INSTALL_FOLDER}/var/html ] || ln -s ${CURR_FOLDER}/var/html ${INSTALL_FOLDER}/var/html\
               #[ -d ${INSTALL_FOLDER}/var/database ] || ln -s ${CURR_FOLDER}/var/database ${INSTALL_FOLDER}/var/database

