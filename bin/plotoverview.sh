#! /bin/sh

if [ ! -d /hreidar/extern/bio3/Data/Code/iBRAIN/logs/old ]; then
mkdir -p /hreidar/extern/bio3/Data/Code/iBRAIN/logs/old
fi

for logfile in $(find /hreidar/extern/bio3/Data/Code/iBRAIN/logs -maxdepth 1 -type f -mtime +7 -name '*.log' -type f -mtime +7 -maxdepth 1); do
echo removing old logfile $logfile
rm $logfile
done

# OLDPREVIEWCOUNT=$( find /hreidar/extern/bio3/Data/iBRAIN/logs -name 'overview.pdf' -cmin +60 | wc -l )
# PREVIEWCOUNT=$( find /hreidar/extern/bio3/Data/iBRAIN/logs -name 'overview.pdf' | wc -l )
# if [ $OLDPREVIEWCOUNT -gt 0 ] || [ $PREVIEWCOUNT -eq 0 ]; then
# ~/MATLAB/plot_ibrain_overview/plot_ibrain_overview.command
# fi
