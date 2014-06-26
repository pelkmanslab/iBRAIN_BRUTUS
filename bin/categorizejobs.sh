#! /bin/sh

# Waddowedo here? we list all jobs, running and non-running, extract job-type (currently only) matlab or shell script and try to extract from which user they come. All this returned in XML format.

# Expect first input to be a valid file with bjobs information to parse
if [ ! "$1" ] || [ ! -f $1 ]; then
echo "<!-- INPUT FOR $0 SHOULD BE A VALID FILE -->"
exit 0
fi

# No jobs found
if [ -s $1 ]; then
echo "<!-- NO JOBS WERE FOUND -->"
exit 0
fi

# Count all unique shell scripts
for procesName in $(sed 's|  *| |g' $1 | cut -d " " -f7- | grep -i -e '.*\.sh' | sed -e 's|\(.*\)\.sh.*|\1\.sh|g' | sort | uniq -i); do
JOBCOUNT=$(grep $procesName $1 -c)
echo "<job type=\"shell_script\" count=\"${JOBCOUNT}\" name=\"$procesName\">"
if [ $JOBCOUNT -lt 500 ]; then
grep "$procesName" $1 | sed -e 's|.*/Data/Users/\([^/]*\)/.*|\1|g' | sort | uniq -i -c  | awk '{printf " <job_count_per_user count=\""$1"\" username=\""$2"\"/>\n"}'
#else
#echo  "<job_count_per_user count=\"${JOBCOUNT}\" username=\"not parsed\"/>"
fi
echo "</job>"
done

# count all unique matlab programs
for procesName2 in $(sed 's|  *| |g' $1 | cut -d " " -f7- | grep -i -e 'matlab' | sed -e 's|.*M_PROG;\(.*\)(.*|\1|g' | sed -e 's|(.*)||g'  | sed -e 's|;||g' | sort | uniq -i); do
JOBCOUNT=$(grep $procesName2 $1 -c)
echo "<job type=\"matlab\" count=\"${JOBCOUNT}\" name=\"$procesName2\">"
# check if there is a NAS-path in the job description
if [ $JOBCOUNT -lt 500 ]; then
grep "$procesName2" $1 | sed -e 's|.*/Data/Users/\([^/]*\)/.*|\1|g' | sort -i | uniq -i -c  | awk '{printf " <job_count_per_user count=\""$1"\" username=\""$2"\"/>\n"}'
#else
#echo  "<job_count_per_user count=\"${JOBCOUNT}\" username=\"not parsed\"/>"
fi
echo "</job>"
done
