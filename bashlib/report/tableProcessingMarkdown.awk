# pretty-prints tables in Markdown format
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
    for (column=1; column <= maxColumn; column++) {
      printf("| %s", field[row,column])
    }
    printf("|\n")
    if (header && row==1) {
      for (column=1; column <= maxColumn; column++) {
        if (align[column] == "center") {
          printf("| :---: ")
        } else if (align[column] == "right") {
          printf("| ---: ")
        } else { 
          printf("| --- ")
        }
      }
      printf("|\n")
    }
  } 
}
