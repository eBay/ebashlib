#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.
###############################################################################
# this function battery provides tools for standardized reports on terminal
# see abstract class report.sh for definition of public functions
###############################################################################

source $( dirname ${BASH_SOURCE} )/reportTerminalStyles.sh

REPORT_TERMINAL_WIDTH_=80
REPORT_TERMINAL_PAD_=$(printf '%0.1s' " "{1..80})

# private function which escapes all special characters within a \`code block\`
#
# essentially, we split each line by the special character, and 
# every other entry (2,4,6,...) contains characters that we escape
#
# note: this would not work across lines (which is why we group paragraphs elsewhere)
function REPORT_TERMINAL_ESCAPE_WITHIN_CODE_WORDS_() {
    awk -v backtic="\`" '
    BEGIN {
      FS=backtic
      OFS=backtic
    } 
    {
      # every second entry we are in between quotation marks. So, we escape all markups here
      for (i=2; i <= NF; i=i+2) {  
          gsub(/\*/, "\\*", $i);
          gsub(/_/, "\\_", $i);
      } 
      print;
    }'
}

# private function to emphasize text markups for terminal
#
# mark-ups work across paraphraphs (divided by blank lines)
function REPORT_TERMINAL_EMPHASIZE_() {
    sed -n "
   # on empty lines we finish one paragraph and jump to :emphasis
   /^$/ b emphasis
   # otherwise, we hold the input for further processing
   # in order to allow for matches across lines in a paragraph
   H
   # if the document reached the end, jump to :emphasis
   $ b emphasis
   # if not, jump to the end of this script
   b
   :emphasis
      # exchange contents of hold and pattern space
      x

      # anything between (unescaped) double asteriks/underlines will be strong
      s#\([^\]\)\*\*\([^\*]*\)\*\*#\1${REPORT_TERMINAL_STRONG}\2${REPORT_TERMINAL_RESET}#g
      s#\([^\]\)__\([^_]*\)__#\1${REPORT_TERMINAL_STRONG}\2${REPORT_TERMINAL_RESET}#g

      # anything between (unescaped) single asteriks/underlines will be emphasized
      s#\([^\]\)\*\([^\*]*\)\*#\1${REPORT_TERMINAL_EMPHASIS}\2${REPORT_TERMINAL_RESET}#g
      s#\([^\]\)_\([^_]*\)_#\1${REPORT_TERMINAL_EMPHASIS}\2${REPORT_TERMINAL_RESET}#g

      # finally, anything between \` is marked as code
      s#\([^\\]\)\`\([^\`]*\)\`#\1${REPORT_TERMINAL_PRE}\2${REPORT_TERMINAL_RESET}#g

      # now that we are through, we un-escape special characters again
      s/[\][*]/*/g
      s/[\][_]/_/g

      # remove new lines introduced by H
      s/[^\n]*\n//

      # and print out (this paragraph)
      p
   "
}

# private function to emphasize table cells for terminal
function REPORT_TERMINAL_EMPHASIZE_TABLE_CELLS_() {
    sed "
      # anything between (unescaped) double asteriks/underlines will be strong
      s#\([^\]\)\*\*\([^\*]*\)\*\*#\1${REPORT_TERMINAL_STRONG}\2${REPORT_TERMINAL_RESET}    #g
      s#\([^\]\)__\([^_]*\)__#\1${REPORT_TERMINAL_STRONG}\2${REPORT_TERMINAL_RESET}    #g

      # anything between (unescaped) single asteriks/underlines will be emphasized
      s#\([^\]\)\*\([^\*]*\)\*#\1${REPORT_TERMINAL_EMPHASIS}\2${REPORT_TERMINAL_RESET}  #g
      s#\([^\]\)_\([^_]*\)_#\1${REPORT_TERMINAL_EMPHASIS}\2${REPORT_TERMINAL_RESET}  #g

      # finally, anything between \` is marked as code
      s#\([^\\]\)\`\([^\`]*\)\`#\1${REPORT_TERMINAL_PRE}  \2${REPORT_TERMINAL_RESET}#g

      # now that we are through, we un-escape special characters again
      s/[\][*]/*/g
      s/[\][_]/_/g"
}


# private function to properly mark/process lists and/or texts
function REPORT_TERMINAL_PREPARE_LIST_N_TEXT_() {
    sed -n "
      # append it to the hold buffer
      H
      # if an empty line, check the paragraph
      /^[ ]*$/ b para

      # at end of file, check paragraph
      $ b para

      # if not at end of file, do not do anything
      b

      # now we have a paragraph and check whether this is 
      # - a normal text (remove lines)
      # - a list (keep lines)
      :para
        # return the entire paragraph into the pattern space
        x

        # does it start with an asteriks? Then, it is a list
        /^\n[ ]*\*/ b list
        # does not start with an asteriks? Then, it is a normal paragraph
        b text

      # branch for paragraphs with lists
      :list
        # remove any newlines that do not come with a new item
        s/\n[ ]*\([^ \*]\)/ \1/g
        # quote the list marks
        s/\(\n[ ]*\)\([\*]\)/\1\\\*/g
        # remove last newline
        s/\n$//g

        b print

      # branch for paragraphs without lists
      :text
        # we can safely pull together consecutive lines
        s/\n/ /g

        b print
      :print
      s/$/\\\n/g
      # merge more than one empty space into one
      s/ [ ]*/ /g
      p
      "
}

# private function to escape characters in a given string
#
# we want to escape certain sequences with colors and other effects
# but we are unsure at this stage if these markups will span several
# lines. This is especially important if we fold the line beforehand
# (folding it afterwards would no longer look pretty as fold also
# interpretes the terminal characters against the wrap width)
function REPORT_TERMINAL_ESCAPE_() {
  echo -e "$*" | \
    REPORT_TERMINAL_ESCAPE_WITHIN_CODE_WORDS_ | \
    REPORT_TERMINAL_PREPARE_LIST_N_TEXT_ | \
    fold -w 80 -s | \
    REPORT_TERMINAL_EMPHASIZE_
}


# function to be called for the beginning of each report
function REPORT_TERMINAL_START() {
  REPORT_TERMINAL_STYLE_DEFAULT
}

# function to be called for the beginning of each report
function REPORT_TERMINAL_END() {
  :
}

# function generating a new chapter
#
# @param CHAPTER_NAME the name of the section
function REPORT_TERMINAL_CHAPTER() {
  local CHAPTER_NAME=${1}

  printf "%s%s%*.*s%s\n\n" \
    "${REPORT_TERMINAL_H1}" \
    " ${CHAPTER_NAME}" \
    0 $(( REPORT_TERMINAL_WIDTH_ - ${#CHAPTER_NAME} - 1 )) "${REPORT_TERMINAL_PAD_}" \
    "${REPORT_TERMINAL_RESET}"
}

# function generating a new section
#
# @param SECTION_NAME the name of the section
function REPORT_TERMINAL_SECTION() {
  local SECTION_NAME=${1}

  printf "${REPORT_TERMINAL_H2}${SECTION_NAME}${REPORT_TERMINAL_RESET}\n\n"
}

# function generating a new paragraph of text
#
# @param PARAGRAPH_TEXT text to be displayed
function REPORT_TERMINAL_PARAGRAPH() {
  local PARAGRAPH_TEXT=$( REPORT_TERMINAL_ESCAPE_ "${1}" )

  echo -e "${PARAGRAPH_TEXT}"
}

# function generating a new paragraph of text
#
# @param PARAGRAPH_TEXT text to be displayed
function REPORT_TERMINAL_CODE_BLOCK() {
  local CODE_BLOCK="${1}"
  local FORMAT=${2}

  MAXIMUM_LINE_CHARACTER=$( echo "${CODE_BLOCK}" | awk '{ print (length($0) + 1); }' | sort -g | tail -n 1 )

  # does it make sense to fold the code block color?
  if [ "${MAXIMUM_LINE_CHARACTER}" -lt "${REPORT_TERMINAL_WIDTH_}" ]; then

    # folded version
    # since read removes trailing and leading white space, we have to set the IFS to zero here
    while IFS= read -r codeLine; do
    printf "  %s %s %*.*s%s\n" \
      "${REPORT_TERMINAL_CODE}" \
      "${codeLine}" \
      0 $(( MAXIMUM_LINE_CHARACTER - ${#codeLine} )) "${REPORT_TERMINAL_PAD_}" \
      "${REPORT_TERMINAL_RESET}"
    done < <( echo "${CODE_BLOCK}" )
    echo ""

  else

    # color the whole line
    echo "${REPORT_TERMINAL_CODE}"
    echo "${CODE_BLOCK}${REPORT_TERMINAL_RESET}"
    echo ""

  fi
}

# function to output a pretty-printed table
#
# @param TABLE_INPUT   text field containing the table; assumed to be 
#     - one row per line
#     - "|" separated
# @param TABLE_OPTIONS (optional)
function REPORT_TERMINAL_TABLE() {
  local TABLE_INPUT=${1}
  local TABLE_OPTIONS=${2}
  echo -e "${TABLE_INPUT}" | \
    grep -v "^[ ]*$" | \
    awk -v colorHeader="${REPORT_TERMINAL_TABLE_HEADER}" \
        -v colorRow1="${REPORT_TERMINAL_TABLE_ROW1}" \
        -v colorRow2="${REPORT_TERMINAL_TABLE_ROW2}" \
        -v colorStrong="${REPORT_TERMINAL_TABLE_STRONG}" \
        -v colorEmphasis="${REPORT_TERMINAL_TABLE_EMPHASIS}" \
        -v colorReset="${REPORT_TERMINAL_RESET}" \
        -v indent="  " \
        -v tableOptions="${TABLE_OPTIONS}" \
        -f "$( dirname ${BASH_SOURCE} )/tableProcessingLib.awk" \
        -f "$( dirname ${BASH_SOURCE} )/tableProcessingTerminal.awk" 
    echo ""
}

# function to render unified diffs
#
# @param DIFF_INPUT text field processed by diff -u
function REPORT_TERMINAL_UNIFIED_DIFF() {
  local DIFF_INPUT=${1}

  echo -e "${DIFF_INPUT}" | while IFS= read -r diffLine ; do
    # determine span class
    if    [[ "${diffLine:0:7}" == 'Only in' ]]; then 
       diffColor="${REPORT_TERMINAL_DIFF_ONLY}"
    elif  [[ "${diffLine:0:4}" == 'diff' ]]; then 
       diffColor="${REPORT_TERMINAL_DIFF_DIFF}"
    elif  [[ "${diffLine:0:3}" == '---'  ]]; then 
       diffColor="${REPORT_TERMINAL_DIFF_OLDFILE}"
    elif  [[ "${diffLine:0:3}" == '+++'  ]]; then 
       diffColor="${REPORT_TERMINAL_DIFF_NEWFILE}"
    elif  [[ "${diffLine:0:2}" == '@@'   ]]; then 
       diffColor="${REPORT_TERMINAL_DIFF_STATISTICS}"
    elif  [[ "${diffLine:0:1}" == '+'    ]]; then 
       diffColor="${REPORT_TERMINAL_DIFF_NEW}"
    elif  [[ "${diffLine:0:1}" == '-'    ]]; then 
       diffColor="${REPORT_TERMINAL_DIFF_OLD}"
    else 
       diffColor="${REPORT_TERMINAL_DIFF_DEFAULT}"
    fi
    diffLine=$( echo "${diffLine}" | fold -w 80 -s )
    while IFS= read -r currentDiffChunk; do
      printf "%s%*.*s%s\n" \
      "${diffColor}${currentDiffChunk}" \
      0 $(( REPORT_TERMINAL_WIDTH_ - ${#currentDiffChunk} )) "${REPORT_TERMINAL_PAD_}" \
      "${REPORT_TERMINAL_RESET}"
    done < <( echo -e "${diffLine}" )
  done 
  echo
}

