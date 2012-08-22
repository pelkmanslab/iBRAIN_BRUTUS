#! /bin/sh
OLDPREVIEWCOUNT=$( find /hreidar/extern/bio3/Data/iBRAIN/logs -name 'overview.pdf' -cmin +60 | wc -l )
PREVIEWCOUNT=$( find /hreidar/extern/bio3/Data/iBRAIN/logs -name 'overview.pdf' | wc -l )
if [ $OLDPREVIEWCOUNT -gt 0 ] || [ $PREVIEWCOUNT -eq 0 ]; then
~/MATLAB/plot_ibrain_overview/plot_ibrain_overview.command
fi
