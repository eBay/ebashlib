#!/bin/bash
# (stub) define style options for terminal output

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

source $( dirname ${BASH_SOURCE} )/../termColorFont/termColorFont.sh

# default style options for terminal
function REPORT_TERMINAL_STYLE_DEFAULT() {
  REPORT_TERMINAL_STRONG="$(TERM_COLOR_FG sand 3)"
  REPORT_TERMINAL_EMPHASIS="$(TERM_COLOR_FG yellow 1)"
  REPORT_TERMINAL_H1="$(TERM_COLOR_BG yellow 4)$(TERM_COLOR_FG white 5)" 
  REPORT_TERMINAL_H2="$(TERM_COLOR_FG yellow 4)$(TERM_COLOR_BG white 5)"
  REPORT_TERMINAL_PRE="$(TERM_COLOR_BG sand 1)$(TERM_COLOR_FG black 5)"
  REPORT_TERMINAL_CODE="$(TERM_COLOR_BG sand 5)"
  REPORT_TERMINAL_TABLE_HEADER="$(TERM_COLOR_BG aquamarine 2)$(TERM_COLOR_FG white 5)"
  REPORT_TERMINAL_TABLE_ROW1="$(TERM_COLOR_BG aquamarine 4)"
  REPORT_TERMINAL_TABLE_ROW2="$(TERM_COLOR_BG green 5)"
  REPORT_TERMINAL_TABLE_STRONG="$(TERM_COLOR_BG aquamarine 3)$(TERM_COLOR_FG white 5)"
  REPORT_TERMINAL_TABLE_EMPHASIS="$(TERM_COLOR_BG sand 3)$(TERM_COLOR_FG white 5)"
  REPORT_TERMINAL_DIFF_DEFAULT="$(TERM_COLOR_RESET)"
  REPORT_TERMINAL_DIFF_ONLY="$(TERM_COLOR_FG red 3)"
  REPORT_TERMINAL_DIFF_OLDFILE="$(TERM_COLOR_FG orange 2)"
  REPORT_TERMINAL_DIFF_NEWFILE="$(TERM_COLOR_FG aquamarine 2)"
  REPORT_TERMINAL_DIFF_DIFF="$(TERM_COLOR_FG red 3)"
  REPORT_TERMINAL_DIFF_STATISTICS="$(TERM_COLOR_BG sand 2)$(TERM_COLOR_FG white 5)"
  REPORT_TERMINAL_DIFF_OLD="$(TERM_COLOR_BG orange 4)"
  REPORT_TERMINAL_DIFF_NEW="$(TERM_COLOR_BG aquamarine 4)"
  REPORT_TERMINAL_RESET="$(TERM_COLOR_RESET)"
}
