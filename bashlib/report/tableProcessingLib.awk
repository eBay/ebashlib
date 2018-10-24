# awk function battery for pretty-printing tables
# (introduced here to minimize redundancy)
#
# note that, if files are included in awk via -f <file>
# then awk does no longer read in additional commands from '<direct input>'
# so the other code has to be placed within a file as well.

# initialize global values, to be on the safe side
function initTable() {
  maxColumn=0
  header=0
}

# reads in table lines, stores cells and tracks maximum number of columns
function readTableLine() {
  # note that we assume that all lines start and end with delimiter,
  # i.e. number of entries equal to fields minus 2
  if (NF-2 > maxColumn) {
    for (i=maxColumn;i < (NF-2); i++) {
      maxColumn += 1
      maxColumnSize[maxColumn]=0
      align[maxColumn]="left"
    }
  }
  # we simply read in the fields in here so that they can be evaluated
  # for highest/lowest value etc. at the end of the list. 
  # Note that awk does not truly support array of arrays (gawk does, though),
  # so to be on the safe side we use "fake" multi-dimensional arrays
  for (i=2; i<NF; i++) { 
    field[NR,(i-1)]=$i 
    actualSize=$i
    gsub(/^[ *_]*/, "", actualSize)
    gsub(/[ *_]*$/, "", actualSize)
    if (maxColumnSize[(i-1)] < length(actualSize)) {
      maxColumnSize[(i-1)] = length(actualSize)
    }
  } # for i
} # end function

# function to parse table options
#
# those options are given as a variable to awk.
# They are separated by ";" and can be assigned to all 
# columns (default) or selected ones, in which case you can write:
#   <columnNr>,<columnNr>,...:OPTION
#
# For example, a table could have the options:
#   HEADER;2,3:RIGHT;1:CENTER
function parseOptions(tableOptions) {
  nOptions=split(tableOptions, options, ";")
  for (currentOption=1; currentOption<=nOptions; currentOption++) {
    # is the option set for specific columns or globally?
    if ( split(options[currentOption], optionSplit, ":") > 1 ) {
      split(optionSplit[1], affectedColumns, ",")
    } else {
      for (i=1;i<=maxColumn;i++) {
        affectedColumns[i]=i
      }
    } # if

    # now we now which columns should be affected by the current option
    # .. let's go through them
    for (currentColumnIndex in affectedColumns) {
      currentColumn=affectedColumns[currentColumnIndex]

      # it's not the best way to set the global header again for all columns
      # but in future releases this behavior might change, so we'll leave it in
      if ( match(options[currentOption], /HEADER/) != 0) {
        header=1
      }
      if ( match(options[currentOption], /LEFT/) != 0) {
        align[currentColumn]="left"
      }
      if ( match(options[currentOption], /RIGHT/) != 0) {
        align[currentColumn]="right"
      }
      if ( match(options[currentOption], /CENTER/) != 0) {
        align[currentColumn]="center"
      } 
    } # for currentColumnIndex
  } # for currentOption
} # end function
