#! /bin/bash

#
# create_jpgs.sh

############################
#  INCLUDE PARAMETER CHECK #
. ./core/modules/parameter_check.sh 
############################

function main {

        DO_ZSTACK_CHECK="$1"

        # Check if image filenames contain "z000", i.e. are z-stacks
        if [ "$DO_ZSTACK_CHECK" == "check_zstacks" ]; then
            # we consider only PNGs..
            ZSTACKCOUNT=$( find $TIFFDIR -maxdepth 1 -type f -regex ".*_z[0-9]+.*\.png$" | wc -l )
            if [ $ZSTACKCOUNT -eq 0 ]; then
                touch $BATCHDIR/CreateMIPs.complete
            else   
                touch ${BATCHDIR}/has_zstacks
                return
            fi
        fi

        # Exit if no z-stack flag found.
        if [ ! -e ${BATCHDIR}/has_zstacks ]; then
            return
        fi


BRAINYDIR="$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")/lib/python"
TIFFDIR="./"
BATCHSIZE=10 # Number of MIPs per BATCH
python - <<PYTHON
# Import iBRAIN environment.
import sys
sys.path = ['$BRAINYDIR'] + sys.path
from brainy import BrainyModule, NORM_QUEUE, LONG_QUEUE
import os
import re


class CreateMIPs(BrainyModule):
    
    def __init__(self, env):
        BrainyModule.__init__(self, 'CreateMIPs', env)
        self.files = os.listdir(self.env['tiff_dir'])
        self.__wanted_mips = None
        self.__found_mips = None
        self.__zstacks = None
        self.zstack_regex = re.compile('.+(_z\d+)[^\.]*\.(tiff|png)$')

    def get_zstacks(self):
        if self.__zstacks is None:
            self.__zstacks = list()
            for filename in self.files:
                match = self.zstack_regex.search(filename)
                if match:
                    zstack_part = match.group(1)
                    mip = filename.replace(zstack_part, '')
                    if not mip in self.__zstacks:
                        self.__zstacks[mip] = list()
                    self.__zstacks[mip].append(filename)
        return self.__zstacks

    @property
    def wanted_mips(self):
        if self.__wanted_mips is None:
            self.__wanted_mips = self.get_zstacks().keys()
        return self.__wanted_mips

    @property
    def found_mips(self):
        if self.__found_mips is None:
            for filename in self.files:
                match = self.zstack_regex.search(filename)
                if not match and filename in self.wanted_mips:
                    # Consider this to be a MIPs
                    self.__found_mips.append(filename)
        return self.__found_mips

    @property
    def is_missing_projections(self):
        return len(self.wanted_mips) < len(self.found_mips)


    def submit_batch(self, batch):
        # Prepare script.
        tiff_dir = self.env['tiff_dir']
        batch = [
            '[ -d %s ] || exit' % tiff_dir,
            'cd ' + tiff_dir] + batch
        batch_script = '\n'.join(batch)

        # Submit job.
        if not self.has_runlimit:
            self.submit_job(batch_script)
        else:
            # Put job into longer queue.
            self.submit_job(batch_script, NORM_QUEUE)

    def submit_mips(self, mips):
        zstacks = self.get_zstacks()
        batch = list()
        for mip in mips:
            # TODO: use parallel!
            input_images = ' '.join(zstasks[mip])
            batch.append('$IBRAIN_BIN_PATH/mip.py %s --output %s' % \
                        (input_images, mip))
            if len(batch) >= $BATCHSIZE:
                self.submit_batch(batch)
                batch = list()
        if len(batch) > 0:
            self.submit_batch(batch)

    def submit_jobs(self):
        # Submit jobs blindly (even for existing MIPs).
        self.submit_mips(self.wanted_mips)

    def resubmit_jobs(self):
        # Do not resubmit jobs for existing MIPs.
        mips = [mip for mip in self.wanted_mips if mip not in self.found_mips]
        self.submit_mips(mips)

create_mips = CreateMIPs(dict(
    'tiff_dir' : '$TIFFDIR',
    'project_dir': '$PROJECTDIR',
    'batch_dir': '$BATCHDIR',
    'postanalysis_dir': '$POSTANALYSISDIR',
    'jpg_dir': '$JPGDIR',
))


# Do we want to submit?
if create_mips.is_submitted is False and create_mips.is_resubmitted is False \
    and create_mips.is_missing_projections:
    
    print('''
     <status action="${MODULENAME}">submitting
     <output>%(submission_result)s</output>
     </status>
    ''' % {'submission_result': create_mips.submit_jobs()})

# Submitted but no job results yet?
elif (create_mips.is_submitted or create_mips.is_resubmitted) \
    and len(create_mips.found_mips) == 0 and create_mips.results_count in (0,1):

    if create_mips.has_runlimit:
        # TODO: Job count?
        print('''
         <status action="${MODULENAME}">resetting
         <output>%s</output>
         </status>
        ''') % create_mips.reset_submitted()
    else:
        print('''
         <status action="${MODULENAME}">waiting
         </status>
        ''')

# Resubmit if no MIPs but job results found.
elif create_mips.is_submitted and create_mips.is_resubmitted is False \
    and len(create_mips.found_mips) == 0 and create_mips.results_count > 0:
    
    print('''
     <status action="${MODULENAME}">submitting
     <output>%(submission_result)s</output>
     </status>
    ''' % {'submission_result': create_mips.resubmit_jobs()})
           
elif create_mips.is_submitted and create_mips.is_resubmitted \
    and len(create_mips.found_mips) == 0 and create_mips.results_count > 1:

    # Check resultfiles for known errors, reset/resubmit jobs if appropriate .
    print('''
     <status action=\"${MODULENAME}\">failed
      <warning>ALERT: MIPS CREATION FAILED TWICE</warning>
      <output>
          $($IBRAIN_BIN_PATH/check_resultfiles_for_known_errors.sh $BATCHDIR "CreateMIPs" $PROJECTDIR/CreateMIPs.resubmitted)
      </output>
     </status>
    ''')

elif create_mips.is_submitted and not create_mips.is_missing_projections:

    print('     <status action=\"${MODULENAME}\">completed</status>')

PYTHON

}
     

# run standardized bash-error handling of iBRAIN
execute_ibrain_module "$@"

# clear main module function
unset -f main
