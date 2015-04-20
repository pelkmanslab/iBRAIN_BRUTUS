iBRAIN
======

iBRAiN is an acronym for image-Based RNAi and was developed as a middle ware
between image analysis software, content management of siRNA libraries, the
storage of large sets of microscopy images, the distribution of computation
jobs on large computer clusters, and the harvesting and visualization of
obtained results. It contains numerous meta-information on genes and proteins,
obtained from ontology databases and STRING. It also incorporates probabilistic
algorithms to determine the true loss-of-function phenotype of a gene from
measurements of multiple siRNAs targeting the same gene. Some of these
algorithms have been developed in Lucas Pelkmans group by Berend Snijder, and
will be published in the near future. iBRAIN also provides a webbrowser-
compatible user interface with which the progress in computational analysis
can be easily monitored for each running project.

author: Berend Snijder
version: 2009-08-03
date_last_modified: 2011-08-24 14:36:07.683457953


 Installation
 ------------

1. Clone the repository and point your current folder to it. At next you should run:

make install

This will by default install (symlink) the copy of iBRAIN files into ~/iBRAIN folder.
Next time you update the repository, do

make update

2. The context of ~/iBRAIN/etc should look like

config
paths.txt -> /BIOL/sonas/biol_uzh_pelkmans_s4/Data/Code/iBRAINmaster/etc/paths.txt
sedTransformLogWebUser.sed

where a sample config is:

#---start-of-config---
#! /bin/sh
if [ ! -d $IBRAIN_ROOT ]; then
    echo "Error, missing ROOT folder definition.." >/dev/stderr
    exit
fi

export IBRAIN_BIN_PATH=$IBRAIN_ROOT/bin
export IBRAIN_ETC_PATH=$IBRAIN_ROOT/etc
export IBRAIN_VAR_PATH=$IBRAIN_ROOT/var
export IBRAIN_LOG_PATH=$IBRAIN_VAR_PATH/log
export IBRAIN_DATABASE_PATH=$IBRAIN_VAR_PATH/database

export IBRAIN_MATLAB_PATH=/cluster/home/biol/ibrain/code/dep

export IBRAIN_USER=$(whoami)
export IBRAIN_ADMIN_EMAIL=yauhen.yakimovich@uzh.ch


export PATH=$PATH:$IBRAIN_BIN_PATH
#---end-of-config---


and a sample sedTransformLogWebUser.sed

#---start-of-config---
#!/bin/sed -f
s|/BIOL/imsb/fs|/share-|g
s|/cluster/home/biol/ibrain/iBRAIN/var/database|..|g
s|/BIOL/sonas/biol_uzh_pelkmans_s|/share-|g
s|/bio3/bio3||g
s| -- | - |g
s|---------------------------------------------------------------------|- |g
s|\.xml|\.html|g
#---end-of-config---

Don't forget to set permissions for execution

  chmod +x sedTransformLogWebUser.sed


Crontab
-------



Please put the following into the crontab of iBRAIN cluster user:


$ crontab -l
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=bsnijder
MAIL=/var/spool/mail/bsnijder

# Minute   Hour   Day of Month       Month          Day of Week        Command
# (0-59)  (0-23)     (1-31)    (1-12 or Jan-Dec)  (0-6 or Sun-Sat)
    */3        *          *             *               *           ~/scripts/crontab-wrapper ~/execute_ibrain_wrapper.sh
    *       */1          *             *               *            ~/scripts/crontab-wrapper ~/iBRAIN/report_disk_usage.sh
##    */1       *          *             *               *          ~/scripts/crontab-wrapper printenv > ~/berendwashere.txt
    */20       *          *             *               *           ~/scripts/crontab-wrapper ~/iBRAIN/run_temp_parse_ibrain_jobcount.sh > /dev/null 2>&1



$ cat scripts/crontab-wrapper
#!/bin/bash
[ $(id -gn) = nas_bio3 ] || exec sg nas_bio3 "$0 $@"
#[ -r $HOME/.bashrc ] && . $HOME/.bashrc
# .bash_profile can contian statements like 'load module matlab'
[ -r $HOME/.bash_profile ] && . $HOME/.bash_profile
[ -r $HOME/.profile ] && . $HOME/.profile
#export IBRAIN_ROOT=$HOME/iBRAIN
exec "$@"


Example of .bashrc

# .bashrc

#newgrp nas_bio3
[ $(id -gn) = nas_bio3 ] || exec newgrp nas_bio3

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific aliases and functions
ulimit -t 3600
ulimit -u 50

# Set group access by default to full access for the owner and the group on newly created files
umask 0007

# According to brutus wiki, module load commands should be here
#module load matlab/7.8
module load matlab/7.12 ffmpeg/0.8.2


Tests
-----


To run nose tests navigate into

cd test/unit

