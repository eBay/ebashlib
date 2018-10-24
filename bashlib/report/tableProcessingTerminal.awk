# pretty-prints tables in ANSI terminal format
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

  for (row=1; row <= NR; row++) {
    printf("%s", indent);
    for (column=1; column <= maxColumn; column++) {
      if (header && row==1) {
        currentCellColor=colorHeader
      } else {
        if (row%2==0) { 
          currentCellColor=colorRow1
        } else {
          currentCellColor=colorRow2
        }
      } 
      if ( ( match(field[row,column], "\\*[^*]*\\*") != 0 ) || 
           ( match(field[row,column], "_[^_]*_") != 0)) {
        currentCellColor=colorEmphasis
      }
      if ( ( match(field[row,column], "\\*{2}[^*]*\\*{2}") != 0 ) || 
           ( match(field[row,column], "__[^_]*__") != 0)) {
        currentCellColor=colorStrong
      }
      gsub("^[ *_]*", "", field[row,column])
      gsub("[ *_]*$", "", field[row,column])

      if (align[column] == "center") {
        padLeft=int((maxColumnSize[column] - length(field[row,column])) / 2)
        padRight=int((maxColumnSize[column] - length(field[row,column])) / 2 + 0.5)
        printf("%s %*s%s%*s %s", currentCellColor, padLeft, "", field[row,column], padRight, "", colorReset)
      } else if (align[column] == "right") {
        printf("%s %*s %s", currentCellColor, maxColumnSize[column], field[row,column], colorReset)
      } else { 
        padRight=maxColumnSize[column] - length(field[row,column]) 
        printf("%s %s%*s %s", currentCellColor, field[row,column], padRight, "", colorReset)
      }
   }
   print ""
 } 
}
