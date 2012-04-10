#! /bin/sh

if [ -d "$1" ]; then
  echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
  echo "<project_xml_file_list>"
  # make sure the file is listed by file name!
  for xmlfile in $(ls $1/*_project.html 2>/dev/null); do
    if [ -s $xmlfile ]; then
      echo " <project_xml_file>$xmlfile</project_xml_file>"
    fi
  done
  echo "</project_xml_file_list>"
fi
