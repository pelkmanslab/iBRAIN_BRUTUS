#! /bin/sh

# We can process everything at once, but I find it takes quite a bit longer. Better grep first for patterns of interest ('.sh' and 'matlab') and sed, sort and unique count afterwards.
#bjobs -w | sed 's|  *| |g' | cut -d " " -f7- | sed -e 's|\(.*\)\.sh.*|\1\.sh|g' -e 's|.*M_PROG;\(.*\)(.*|\1|g' | sort | uniq -i -c

# Expect first input to be a valid file with bjobs information to parse
if [ ! "$1" ] || [ ! -f $1 ]; then
echo "<!-- INPUT FOR $0 SHOULD BE A VALID FILE -->"
exit 0
fi

# Count all unique shell scripts queued
sed 's|  *| |g' $1 | cut -d " " -f7- | grep -i -e '.*\.sh' | sed -e 's|\(.*\)\.sh.*|\1\.sh|g' | sort | uniq -i -c | awk '{printf "<job type=\"shell_script\" count=\""$1"\" name=\""$2"\"/>\n"}'

# sed 's|  *| |g' $1 | cut -d " " -f7- | grep -i -e '.*\.sh' | sed -e 's|\(.*\)\.sh.*|\1\.sh|g' | sort | uniq -i -c | xargs grep $0 | sed -e 's|Data/Users/\(.*\)/.*|\1|g' | sort | uniq -i -c 

# count all unique matlab programs queued
sed 's|  *| |g' $1 | cut -d " " -f7- | grep -i -e 'matlab' | sed -e 's|.*M_PROG;\(.*\)(.*|\1|g' | sed -e 's|(.*)||g'  | sed -e 's|;||g' | sort | uniq -i -c | awk '{printf "<job type=\"matlab\" count=\""$1"\" name=\""$2"\"/>\n"}'

# sed 's|  *| |g' $1 | cut -d " " -f7- | grep -i -e 'matlab' | sed -e 's|.*M_PROG\(.*\)M_PROG.*|\1|g' -e 's|(.*)||g' | sort | uniq -i -c | awk '{printf "<job type=\"matlab\" count=\""$1"\" name=\""$2"\"/>\n"}'

# sed 's|  *| |g' $1 | cut -d " " -f7- | grep -i -e 'matlab' | sed -e 's|.*M_PROG\(.*\)M_PROG.*|\1|g' | sed -e 's|(.*)||g' | sort | uniq -i -c 

