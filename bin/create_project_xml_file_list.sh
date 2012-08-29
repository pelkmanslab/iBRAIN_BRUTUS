#! /bin/sh

if [ -d "$1" ]; then

echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
echo "<project_xml_file_list>"

for xmlfile in $(find $1 -maxdepth 1 -type f -mmin +5 -name "*_project.xml"); do

# do a check to see if the xml is valid! do not include invalid xml!
if [ "$(xmllint --noout $xmlfile 2>&1)" ]; then 
 echo "<!-- deleting invalid file! ..."
 #touch $(dirname $xmlfile)/$(basename $xmlfile .xml).invalid_xml
 mv $xmlfile $(dirname $xmlfile)/$(basename $xmlfile .xml).invalid_xml
 #echo rm -f $xmlfile
 echo "... -->"
else
 echo " <project_xml_file>$xmlfile</project_xml_file>"
fi
done

echo "</project_xml_file_list>"

fi
