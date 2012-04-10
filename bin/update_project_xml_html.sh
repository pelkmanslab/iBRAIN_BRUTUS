#! /bin/sh
PROJECTXMLDIR=$1
BOOLDELETED=0
if [ -d "$PROJECTXMLDIR" ]; then
  # update the html of the project, check for errors and remove older html files
  echo "<!-- Updating the HTML of all project.xml files" 
  for oldprojectxmlfile in $(ls $PROJECTXMLDIR/*_project.xml 2>/dev/null); do
    if [ "$(find $(dirname $oldprojectxmlfile) -maxdepth 1 -type f -cmin +5 -mmin +5 -name $(basename $oldprojectxmlfile))" ]; then

      OLDPROJECTXMLBASE=$(basename $oldprojectxmlfile .xml)
      echo "OLDPROJECTXMLBASE=$OLDPROJECTXMLBASE"
      XSLTPROCOUTPUT=$(xsltproc -o "$PROJECTXMLDIR/${OLDPROJECTXMLBASE}.html" "$oldprojectxmlfile" 2>&1)
      if [ "$XSLTPROCOUTPUT" ]; then
        #echo "$XSLTPROCOUTPUT"
        if [ "$(xmllint --noout $oldprojectxmlfile 2>&1)" ]; then
          echo "  $OLDPROJECTXMLBASE was probably corrupt."
          #rm -f "$oldprojectxmlfile"
          mv $oldprojectxmlfile $(dirname $oldprojectxmlfile)/$(basename $oldprojectxmlfile .xml).invalid_xml
          rm $oldprojectxmlfile $(dirname $oldprojectxmlfile)/$(basename $oldprojectxmlfile .xml).html
          # if we have removed a html file, we should actually update teh project_html_file_list and rebuild all html files!!!
          BOOLDELETED=1
        fi 
      fi
    fi
  done
  echo " -->"         
fi
if [ ! $BOOLDELETED -eq 0 ]; then
echo "<!-- Corrupt xml files found, updating all html"
~/iBRAIN/create_project_html_file_list.sh $PROJECTXMLDIR | ~/iBRAIN/sedTransformLogWeb.sed > $PROJECTXMLDIR/project_xml_file_list.xml >&/dev/null;
~/iBRAIN/update_project_xml_html.sh $PROJECTXMLDIR >&/dev/null;
echo "-->"
fi 
