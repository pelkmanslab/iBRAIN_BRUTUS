#! /bin/sh

#xmlpath="~/2NAS/Data/Code/iBRAIN/database/project_xml/__BIOL__imsb__fs2__bio3__bio3__Data__Users__Frank__iBRAIN/"

#xml=${xmlpath}081118_144516_798965000_project.xml

xml="/cluster/home/biol/bsnijder/2NAS/Data/Code/iBRAIN/database/project_xml/__BIOL__imsb__fs2__bio3__bio3__Data__Users__Frank__iBRAIN/081118_144516_798965000_project.xml"
dirs=$(grep -e '<plate_dir>.*</plate_dir>' $xml | sed 's|<[^>]*>||g' | sed 's|/share-\([23]\)|/BIOL/imsb/fs\1/bio3/bio3|g')

#dirs=$(sed 's|<plate_dir>(.*)</plate_dir>>||g' | sed 's|/share-\([23]\)|/BIOL/imsb/fs\1/bio3/bio3|g')


for dir in $dirs; do
stat $dir
done

