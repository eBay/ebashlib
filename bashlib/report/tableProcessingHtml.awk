# pretty-prints tables in HTML format
# requires functions from tableProcessingLib.awk
BEGIN {
  FS="|"
  initTable()
}
{
  readTableLine()
}
END { 
  parseOptions(tableOptions)

  print "<TABLE>"
  for (row=1; row <= NR; row++) {
    if (row%2==0) { 
      print "  <TR class=\"row0\">"
    } else {
      print "  <TR class=\"row1\">"
    } 
    for (column=1; column <= maxColumn; column++) {
      currentClass="default"
      if ( ( match(field[row,column], "\\*[^*]*\\*") != 0 ) || 
             ( match(field[row,column], "_[^_]*_") != 0)) {
             currentClass="emphasis"
      }
      if ( ( match(field[row,column], "\\*{2}[^*]*\\*{2}") != 0 ) || 
           ( match(field[row,column], "__[^_]*__") != 0)) {
             currentClass="strong"
      }
      gsub("^[ *_]*", "", field[row,column])
      gsub("[ *_]*$", "", field[row,column])

      cellSetting="class=\""currentClass"\" style=\"text-align:"align[column]"\""
      if (header && row==1) {
         print "    <TH "cellSetting">" field[row,column] "</TH>"
      } else {
         print "    <TD "cellSetting">" field[row,column] "</TD>"
      }
    } # end for column
      print "  </TR>"
  } # end for row
  print "</TABLE>"
}
