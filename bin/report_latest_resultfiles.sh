#! /bin/sh


grep -A3 "Output File" ~/logs/bjobslr.txt | awk -v RS="\n" -v ORS="" {print} | sed -e 's|<|\n|g' -e 's| ||g' | grep "/BIOL/imsb/fs" | sed -e 's|>.*$||g' >> ~/logs/recent_result_files.txt

# make sorted version, with only unique rows
sort -u ~/logs/recent_result_files.txt > ~/logs/recent_result_files2.txt
mv -f ~/logs/recent_result_files2.txt ~/logs/recent_result_files.txt

for resultFile in $(cat ~/logs/recent_result_files.txt); do

if [ -e $resultFile ]; then
# if file is found, remove it from recent_result_files.txt, append it to latest_result_files.txt

# delete all references from recent_result_files.txt
sed -ie "\|^$resultFile\$|d" ~/logs/recent_result_files.txt
sed -ie "\|^$resultFile\$|d" ~/logs/latest_result_files.txt

# append reference to latest_result_files.txt
echo $resultFile >> ~/logs/latest_result_files.txt

fi

done


# let's shorten ~/logs/latest_result_files.txt to keep processing etc. quick.
tail -n 50 ~/logs/latest_result_files.txt > ~/logs/latest_result_files2.txt
mv -f ~/logs/latest_result_files2.txt ~/logs/latest_result_files.txt

# now let's list the latest 20 (?) present result files, and make them linkable on the iBRAIN website :-D
echo "<latest_result_files>"
for resultFile in $(tail ~/logs/latest_result_files.txt -n 10); do
dateLastMod=$(stat $resultFile | grep Modify | awk '{print $2,$3}')
echo "<result_file date_last_modified=\"${dateLastMod}\">$resultFile</result_file>"
done
echo "</latest_result_files>"
