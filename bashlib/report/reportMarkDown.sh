#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.
###############################################################################
# this function battery provides tools for standardized reports
# see abstract class report.sh for definition of public functions
###############################################################################

# private function to escape Markdown characters in a given string
function REPORT_MARKDOWN_ESCAPE_() {
  echo -e "$*" | fold -w 80 -s 
}

# for markdown. Defined here to avoid nasty quoting throughout this document
MD_TIC="\`"

# function to be called for the beginning of each report
function REPORT_MARKDOWN_START() {
  :
}

# function to be called for the beginning of each report
function REPORT_MARKDOWN_END() {
  :
}

# function generating a new chapter
#
# @param CHAPTER_NAME the name of the section
function REPORT_MARKDOWN_CHAPTER() {
  local CHAPTER_NAME=$( REPORT_MARKDOWN_ESCAPE_ "${1}" )
  echo "${CHAPTER_NAME}"
  echo "${CHAPTER_NAME}" | sed 's/./=/g'
  echo ""
}

# function generating a new section
#
# @param SECTION_NAME the name of the section
function REPORT_MARKDOWN_SECTION() {
  local SECTION_NAME=$( REPORT_MARKDOWN_ESCAPE_ "${1}" )
  echo "${SECTION_NAME}"
  echo "${SECTION_NAME}" | sed 's/./-/g'
  echo ""
}

# function generating a new paragraph of text
#
# @param PARAGRAPH_TEXT text to be displayed
function REPORT_MARKDOWN_PARAGRAPH() {
  local PARAGRAPH_TEXT=$( REPORT_MARKDOWN_ESCAPE_ "${1}" )

  echo -e "${PARAGRAPH_TEXT}"
  echo ""
}

# function to include a monospaced codeblock
#
# @param CODEBLOCK text entry that contains the actual workflow, presumed to be in monospace ASCII format
# @param FORMAT    (optional) format specification, if supported
function REPORT_MARKDOWN_CODE_BLOCK() {
  local CODE_BLOCK=${1}
  local FORMAT=${2}

  cat <<EOF
${MD_TIC}${MD_TIC}${MD_TIC}${FORMAT}
${CODE_BLOCK}
${MD_TIC}${MD_TIC}${MD_TIC}
EOF
}

# function to output a pretty-printed table
#
# @param TABLE_INPUT   text field containing the table; assumed to be 
#     - one row per line
#     - "|" separated
# @param TABLE_OPTIONS (optional)
function REPORT_MARKDOWN_TABLE() {
  local TABLE_INPUT=${1}
  local TABLE_OPTIONS=${2}
  echo -e "${TABLE_INPUT}" | \
    grep -v "^[ ]*$" | \
    awk -v tableOptions="${TABLE_OPTIONS}" \
        -f "$( dirname ${BASH_SOURCE} )/tableProcessingLib.awk" \
        -f "$( dirname ${BASH_SOURCE} )/tableProcessingMarkdown.awk" 
  echo ""
}

# function to render unified diffs
#
# @param DIFF_INPUT text field processed by diff -u
function REPORT_MARKDOWN_UNIFIED_DIFF() {
  local DIFF_INPUT=${1}

  REPORT_MARKDOWN_CODE_BLOCK "${DIFF_INPUT}" "diff"
}
