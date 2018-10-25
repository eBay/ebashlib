#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.
###############################################################################
# abstract tool which provides standardized reports for various outputs
#
# public function overview:
#
# REPORT_SET_OUTPUT_FORMAT( format: string) 
#   function to set output format.
#   currently supported output:
#   * HTML
#   * MARKDOWN
#   * TERMINAL
#
# REPORT_START( title: string ) 
#   function to be called for the beginning of each report
#   title will be used 
#    - as document name, if applicable, and 
#    - as first chapter
# REPORT_END() 
#   function to be called at the end of each report
# REPORT_CHAPTER( chapterHeader ) 
#   function generating a new chapter
# REPORT_SECTION( sectionHeader ) 
#   function generating a new section
# REPORT_PARAGRAPH( text ) 
#   function generating a new section
# REPORT_CODE_BLOCK( codeblock )
#   function to include a code block that is to be outputted in monospace
# REPORT_TABLE( tableInput, tableOptions ) 
#   function to output a pretty-printed table
#
###############################################################################

# header guardian 
# ${var+x} is a parameter expansion which evaluates to null if the variable is unset
if [ -z ${BASH_REPORT_HEADER+x} ]; then
  BASH_REPORT_HEADER="LOADED"
else
  return 0
fi

source $( dirname ${BASH_SOURCE} )/reportHtml.sh
source $( dirname ${BASH_SOURCE} )/reportMarkDown.sh
source $( dirname ${BASH_SOURCE} )/reportTerminal.sh

# private variable that sets the output format. Currently supported: HTML, MARKDOWN, TERMINAL
REPORT_OUTPUT_FORMAT_="MARKDOWN"

# function to set output format
#   currently supported output:
#   * HTML
#   * MARKDOWN
#   * TERMINAL
function REPORT_SET_OUTPUT_FORMAT() {
  local FORMAT=$( echo ${1} | tr '[:lower:]' '[:upper:]' )
  case ${FORMAT} in
    HTML)
      REPORT_OUTPUT_FORMAT_="HTML"
      ;;
    MARKDOWN)
      REPORT_OUTPUT_FORMAT_="MARKDOWN"
      ;;
    TERMINAL)
      REPORT_OUTPUT_FORMAT_="TERMINAL"
      ;;
    *)
      echo "ERROR, format ${FORMAT} not supported"
      exit 1
  esac
}

# function to be called for the beginning of each report
#
# @param TITLE the title of the overall report
function REPORT_START() {
  local TITLE=${1}

  local myStartFunction="REPORT_${REPORT_OUTPUT_FORMAT_}_START"
  ${myStartFunction} "${TITLE}" 

  REPORT_CHAPTER "${TITLE}"
}

# function to be called at the end of each report
function REPORT_END() {
  local myFunction="REPORT_${REPORT_OUTPUT_FORMAT_}_END"
  ${myFunction}
}

# function generating a new chapter
#
# @param CHAPTER_NAME the name of the section
function REPORT_CHAPTER() {
  local CHAPTER_NAME=${1}

  local myFunction="REPORT_${REPORT_OUTPUT_FORMAT_}_CHAPTER"
  ${myFunction} "${CHAPTER_NAME}"
}

# function generating a new section
#
# @param SECTION_NAME the name of the section
function REPORT_SECTION() {
  local SECTION_NAME=${1}

  local myFunction="REPORT_${REPORT_OUTPUT_FORMAT_}_SECTION"
  ${myFunction} "${SECTION_NAME}"
}

# function generating a new paragraph of text
#
# @param PARAGRAPH_TEXT text to be displayed
function REPORT_PARAGRAPH() {
  local PARAGRAPH_TEXT=${1}

  local myFunction="REPORT_${REPORT_OUTPUT_FORMAT_}_PARAGRAPH"
  ${myFunction} "${PARAGRAPH_TEXT}"
}

# function to include a monospaced codeblock
#
# @param CODEBLOCK text entry that contains the actual workflow, presumed to be in monospace ASCII format
# @param FORMAT    (optional) format specification, if supported
function REPORT_CODE_BLOCK() {
  local CODE_BLOCK=${1}
  local FORMAT=${2}

  local myFunction="REPORT_${REPORT_OUTPUT_FORMAT_}_CODE_BLOCK"
  ${myFunction} "${CODE_BLOCK}" "${FORMAT}"
}

# function to output a pretty-printed table
#
# @param TABLE_INPUT   text field containing the table; assumed to be 
#     - one row per line
#     - "|" separated
# @param TABLE_OPTIONS (optional)
function REPORT_TABLE() {
  local TABLE_INPUT=${1}
  local TABLE_OPTIONS=${2}

  local myFunction="REPORT_${REPORT_OUTPUT_FORMAT_}_TABLE"
  ${myFunction} "${TABLE_INPUT}" "${TABLE_OPTIONS}"
}

# function to render unified diffs
#
# @param DIFF_INPUT text field processed by diff -u
function REPORT_UNIFIED_DIFF() {
  local DIFF_INPUT=${1}

  local myFunction="REPORT_${REPORT_OUTPUT_FORMAT_}_UNIFIED_DIFF"
  ${myFunction} "${DIFF_INPUT}"
}
