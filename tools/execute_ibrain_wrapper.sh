#! /bin/sh

# note that sedTransformLogPc actually makes the XML valid, by removing erroneous/aaccidental XML outputted by bsub, such as the job id: "<1235523>" and queue "<ether.m>"

LOGFILENAME="$(date +"%y%m%d%H%M%S")"_wrapper_brutus.xml
LOGFILENAME_PC="$(date +"%y%m%d%H%M%S")"_wrapper_brutus_pc.xml

# run iBRAIN and store results locally
~/iBRAIN_wrapper.sh > ~/logs/$LOGFILENAME 2>&1

# check if iBRAIN actually ran, or if it was already running
if [ $(cat ~/logs/$LOGFILENAME | grep "^Aborting:" | wc -l) -eq 0 ]; then

# if it actually did a full run, execute script (on brutus) that does XML-fixing, and possibly url-fixing for PC
./iBRAIN/sedTransformLogWeb.sed ~/logs/$LOGFILENAME > ~/logs/$LOGFILENAME_PC

# or calculate directly on login-node
xsltproc -o ~/logs/wrapper.html /BIOL/imsb/fs2/bio3/bio3/Data/Code/iBRAIN/database/wrapper.xsl ~/logs/$LOGFILENAME_PC
xsltproc -o ~/logs/home.html /BIOL/imsb/fs2/bio3/bio3/Data/Code/iBRAIN/database/home.xsl ~/logs/$LOGFILENAME_PC

# copy the sed transformed log file (XML fixing and URL parsing) and the HTML file to the public iBRIAN log directory
cp ~/logs/$LOGFILENAME_PC /BIOL/imsb/fs2/bio3/bio3/Data/Code/iBRAIN/database/wrapper_xml/$LOGFILENAME
cp -f ~/logs/wrapper.html /BIOL/imsb/fs2/bio3/bio3/Data/Code/iBRAIN/database/wrapper_xml/wrapper.html
cp -f ~/logs/home.html /BIOL/imsb/fs2/bio3/bio3/Data/Code/iBRAIN/database/wrapper_xml/home.html

else

echo "iBRAIN is already running"

fi

# clean up log file
rm ~/logs/$LOGFILENAME 2>/dev/null
rm ~/logs/$LOGFILENAME_PC 2>/dev/null

exit 0

