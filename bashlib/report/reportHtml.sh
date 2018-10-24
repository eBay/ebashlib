#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.
###############################################################################
# this function battery provides tools for standardized HTML reports
# see abstract class report.sh for definition of public functions
###############################################################################

source $( dirname ${BASH_SOURCE} )/reportHtmlStyles.sh

# private function to escape HTML characters in a given string
function REPORT_HTML_ESCAPE_() {
    sed 's/&/\&amp;/g
         s/</\&lt;/g
         s/>/\&gt;/g
         s/"/\&quot;/g
         s/'"'"'/\&#39;/g'
}

# private function which escapes all special characters within a \`code block\`
#
# essentially, we split each line by the special character, and 
# every other entry (2,4,6,...) contains characters that we escape
#
# note: this would not work across lines (which is why we group paragraphs elsewhere)
function REPORT_HTML_ESCAPE_WITHIN_CODE_WORDS_() {
    awk -v backtic="\`" '
    BEGIN {
      FS=backtic
      OFS=backtic
    } 
    {
      # every second entry we are in between quotation marks. So, we escape all markups here
      for (i=2; i <=NF; i=i+2) {  
          gsub(/\*/, "\\*", $i);
          gsub(/_/, "\\_", $i);
      } 
      print;
    }'
}

# private function to emphasize text markups for HTML
#
# mark-ups work across paraphraphs (divided by blank lines)
function REPORT_HTML_EMPHASIZE_() {
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

   # do the emphasis transformations
   :emphasis
      # exchange contents of hold and pattern space
      x

      # anything between (unescaped) double asteriks/underlines will be strong
      s#\([^\]\)\*\*\([^\*]*\)\*\*#\1<STRONG>\2</STRONG>#g
      s#\([^\]\)__\([^_]*\)__#\1<STRONG>\2</STRONG>#g

      # anything between (unescaped) single asteriks/underlines will be emphasized
      s#\([^\]\)\*\([^\*]*\)\*#\1<EM>\2</EM>#g
      s#\([^\]\)_\([^_]*\)_#\1<EM>\2</EM>#g

      # finally, anything between \` is marked as code
      s#\([^\\]\)\`\([^\`]*\)\`#\1<CODE>\2<\/CODE>#g

      # now that we are through, we un-escape special characters again
      s/[\][*]/*/g
      s/[\][_]/_/g

      # and print out (this paragraph)
      p
   "
}

# private function to properly mark/process lists and/or texts
function REPORT_HTML_PREPARE_LIST_N_TEXT_() {
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
      # does -not- start with an asteriks? Then, it is a normal paragraph
      b text

      # branch for paragraphs with lists
      :list
      # remove any newlines that do not come with a new item
      s/\n[ ]*\([^ \*]\)/\1/g

      # quote the list marks
      s/\(\n[ ]*\)\([\*]\)/\1<ULI>/g

      # remove newline from hold
      s/^\n//

      # and print
      b print

      # branch for paragraphs without lists
      :text
      # we can safely pull together consecutive lines
      s/\n/ /g

      # and print
      b print

      # final print
      :print
      
      # the whole text is already put in <P> </P> tags, but we introduce intermediates here
      s/$/<\/P> <P>/g
      p
    "  
}

# private function to nest lists properly
#
# they have been marked <ULI> in previous steps (non-HTML tag to avoid confusion)
# basically, we assume that they belong to the same level
# if the number of leading blanks stays the same. 
function REPORT_HTML_NEST_LISTS_() {
    awk 'BEGIN {
           # we split by ULI so that $1 contains the leading blanks
           FS="<ULI>"
           nestedULI=0
           indent=-1 
         } 
         /<ULI>/ {
           # is the indentation larger than before?  => new nest
           if (length($1) > indent) { 
             print "<UL>" 
             nestedULI+=1
           }
           # is the indentation smaller than before? => close nest
           if (length($1) < indent) {
             print "</UL>" 
             nestedULI-=1
           }
           indent=length($1)
           print "<LI>"$2"</LI>"
         }
         !/<ULI>/ {
           # no more items in this paragraph. Now, we close all remaining nests.
           while (nestedULI > 0) {
             print "</UL>" 
             nestedULI -= 1
             indent=-1
           }
           # ... and print the non-list line
           print $0;
         }
         END {
          while (nestedULI > 0) {
             print "</UL>" 
             nestedULI -= 1
           }
         }
         '
}

# private function to pretty-print a MarkDown-like paragraph in HTML
#
# it will:
#  - escape * and _ within `` blocks
#  - escape HTML-relevant chars like < > &
#  - prepare paragraph blocks containing lists and normal text paragraphs
#  - for lists, ensure that they are nested properly
#  - emphasize markup'd words
function REPORT_HTML_PREPARE_PARAGRAPH_() {
    REPORT_HTML_ESCAPE_WITHIN_CODE_WORDS_ | \
    REPORT_HTML_ESCAPE_ | \
    REPORT_HTML_PREPARE_LIST_N_TEXT_ | \
    REPORT_HTML_NEST_LISTS_ | \
    REPORT_HTML_EMPHASIZE_
}

# function to be called for the beginning of each report
#
# @param TITLE the title of the overall report
function REPORT_HTML_START() {
  local TITLE=$( echo ${1} | REPORT_HTML_ESCAPE_ )
cat << EOF
<HTML>
  <HEAD>
    <TITLE>${TITLE}</TITLE>
  </HEAD>
  <BODY>
EOF
  REPORT_HTML_STYLE_DEFAULT
}

# function to be called at the end of each report
function REPORT_HTML_END() {
cat << EOF
  </BODY>
</HTML>
EOF
}

# function generating a new chapter
#
# @param CHAPTER_NAME the name of the section
function REPORT_HTML_CHAPTER() {
  local CHAPTER_NAME=$( echo "${1}" | REPORT_HTML_ESCAPE_ )
  echo "<H1>${CHAPTER_NAME}</H1>"
}

# function generating a new section
#
# @param SECTION_NAME the name of the section
function REPORT_HTML_SECTION() {
  local SECTION_NAME=$( echo "${1}" | REPORT_HTML_ESCAPE_ )
  echo "<H2>${SECTION_NAME}</H2>"
}

# function generating a new paragraph of text
#
# @param PARAGRAPH_TEXT text to be displayed
function REPORT_HTML_PARAGRAPH() {
  local PARAGRAPH_TEXT=$( echo -n "${1}" | REPORT_HTML_PREPARE_PARAGRAPH_ )
  echo "<P>"
  echo "${PARAGRAPH_TEXT}"
  echo "</P>"
}

# function to include a monospaced codeblock
#
# @param CODEBLOCK text entry that contains the actual workflow, presumed to be in monospace ASCII format
# @param FORMAT    (optional) format specification, if supported
function REPORT_HTML_CODE_BLOCK() {
  local CODE_BLOCK=$( echo "${1}" | REPORT_HTML_ESCAPE_ )
  local FORMAT=${2}

  cat <<EOF
  <P>
    <CODE>
      <PRE>
${CODE_BLOCK}
      </PRE>
    </CODE>
  </P>
EOF
}

# function to output a pretty-printed table
#
# @param TABLE_INPUT   text field containing the table; assumed to be 
#     - one row per line
#     - "|" separated
# @param TABLE_OPTIONS (optional)
function REPORT_HTML_TABLE() {
  local TABLE_INPUT=$( echo -e "${1}" | REPORT_HTML_ESCAPE_ )
  local TABLE_OPTIONS=${2}
  echo -e "${TABLE_INPUT}" | \
    grep -v "^[ ]*$" | \
    awk -v tableOptions=${TABLE_OPTIONS} \
        -f "$( dirname ${BASH_SOURCE} )/tableProcessingLib.awk" \
        -f "$( dirname ${BASH_SOURCE} )/tableProcessingHtml.awk" 
}

# function to render unified diffs
#
# @param DIFF_INPUT text field processed by diff -u
function REPORT_HTML_UNIFIED_DIFF() {
  local DIFF_INPUT=$( echo -e "${1}" | REPORT_HTML_ESCAPE_ )

  echo '<DIV class="div_diff">'
  echo -e "${DIFF_INPUT}" | while read -r diffLine ; do
    # determine span class
    if    [[ "${diffLine:0:7}" == 'Only in' ]]; then 
       spanClass="diff_only"
    elif  [[ "${diffLine:0:4}" == 'diff' ]]; then 
       spanClass="diff_diff"
    elif  [[ "${diffLine:0:3}" == '---'  ]]; then 
       spanClass="diff_oldfile"
    elif  [[ "${diffLine:0:3}" == '+++'  ]]; then 
       spanClass="diff_newfile"
    elif  [[ "${diffLine:0:2}" == '@@'   ]]; then 
       spanClass="diff_statistics"
    elif  [[ "${diffLine:0:1}" == '+'    ]]; then 
       spanClass="diff_new"
    elif  [[ "${diffLine:0:1}" == '-'    ]]; then 
       spanClass="diff_old"
    else 
       spanClass="diff_default"
    fi
    echo "<SPAN class=\"${spanClass}\">$diffLine</SPAN><BR/>"
  done
  echo '</DIV>'
}

