#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# simple example script to show the color functionality
# "Fill your term with colors!"

source $(dirname $0)/../bashlib/bashlib.sh

printf "\n"
printf "$(TERM_COLOR_BG "white" "1" ) %s%s%s%s $(TERM_COLOR_RESET)-like colors approximated to ANSI-256\n" \
  "$(TERM_COLOR_FG "red" "0" )e" \
  "$(TERM_COLOR_FG "blue" "0" )b" \
  "$(TERM_COLOR_FG "yellow" "0" )a" \
  "$(TERM_COLOR_FG "green" "0" )y"

printf "\n"
printf "$(TERM_COLOR_BG "white" "1")$(TERM_COLOR_FG "white" "5")           MAIN COLORS         $(TERM_COLOR_RESET)\n\n"

for colorName in red blue yellow green; do
  printf "%10s " "${colorName}"
  for saturation in `seq 1 5`; do
    printf "$(TERM_COLOR_BG ${colorName} ${saturation})    $(TERM_COLOR_RESET)"
  done
  echo
done

printf "\n"
printf "$(TERM_COLOR_BG "white" "1")$(TERM_COLOR_FG "white" "5")           OTHER COLORS        $(TERM_COLOR_RESET)\n\n"

for colorName in hibiscus peach orange indigo aquamarine turquoise magenta sand white; do
  printf "%10s " "${colorName}"
  for saturation in $( seq 1 5 ); do
    printf "$(TERM_COLOR_BG ${colorName} ${saturation})    $(TERM_COLOR_RESET)"
  done
  echo
done

printf "\n... but sadly, no $(TERM_COLOR_BG "Rainbow" "123")rainbow color$(TERM_COLOR_RESET)\n"

