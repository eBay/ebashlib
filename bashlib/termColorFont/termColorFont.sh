#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT

#  Acknowledgement for idea
# ------------------------------
#  https://stackoverflow.com/questions/27159322/rgb-values-of-the-colors-in-the-ansi-extended-colors-index-17-255
#  (Topic: https://stackoverflow.com/a/27165165 )
#  User: Adeaphon, https://stackoverflow.com/users/2992551/adaephon


# function battery for terminal color and font support
#
# public functions:
# 
# TERM_COLOR_FG( color, type ) 
#   set terminal foreground color
# TERM_COLOR_FG( color, type ) 
#   set terminal background color
# TERM_COLOR_RESET() 
#   resets colors but not font settings
#
# *color* is a string, out of:
#    red, blue, green, yellow, hibiscus, peach, orange, indigo, 
#    aquamarine, turquoise, magenta, sand, white
#    It is possible to give the first letter (r,b,g,y,h,p,o,i,a,t,m,s,w)
# *type* is a number, out of:
#    1 (bright) to 5 (dark) -- all colors
#    and 0 (logo-like colors) -- only for red yellow green blue
#    defaults to 3
###############################################################################

# header guardian 
# ${var+x} is a parameter expansion which evaluates to null if the variable is unset
[[ -z ${BASH_TERM_COLOR_FONT_HEADER+x} ]] && BASH_TERM_COLOR_FONT_HEADER="LOADED" || return 0

source "$( dirname ${BASH_SOURCE} )/termColor.sh"

# obtain the RGB HEX value for a color and type
#
# @param COLOR_NAME out of 
#    red, blue, green, yellow, hibiscus, peach, orange, indigo, 
#    aquamarine, turquoise, magenta, wheat, grayscale
#    @NOTE: will only use the first letter
# @param TYPE out of 1-5 (all colors) plus 0 (logo-like colors)
# 
# will return light gray (#999) if not found
function COLORS_GET_HEX_VALUE() {
  local COLOR_NAME=$( echo ${1:0:1} | tr '[:lower:]' '[:upper:]' )
  local TYPE=${2:-3}
  RETURN_HEX_VALUE_NAME="TERM_COLOR_${COLOR_NAME}[$TYPE]"
  RETURN_HEX_VALUE=${!RETURN_HEX_VALUE_NAME}
  if [[ ${RETURN_HEX_VALUE} =~ [A-Z0-9]{6} ]]; then
    echo ${RETURN_HEX_VALUE}
  else
   # something went wrong, substituting with gray
   echo "999999"
  fi 
}

# convert RGB Hex values into truecolor representation
# @param _HEX RGB-Hex Value to be converted
# @return RGB values, format: "#red;#green;#blue"
function COLORS_HEX_TO_RGB() {
  local _HEX=$( echo $1 | tr '[:lower:]' '[:upper:]' )
  printf "%d;%d;%d" 0x${_HEX:0:2} 0x${_HEX:2:2} 0x${_HEX:4:2}
}

# function to convert hex value into ANSI 256
#
# the ANSI 256 defines many additional colors in a 6*6*6 cube.
# thus, with (r)ed, (g)reen and (b)lue out of [0-5], the color
# code is
# ansiColor = 16 + 36 * r + 6 * g + b
# Most terminals do not distribute these ranges in a uniform
# way, however, but more like [0, 90, 135, 175, 215, 255].
# Thus, we map all below 75 to zero and then go up from 1 to 5 
# in 40-steps
#
# @param _HEX RGB-Hex Value to be converted
# @return (int) ANSI color cube value approximation
# TODO: caching might be nice
function COLORS_HEX_TO_256ANSI() {
  local _HEX=${1}
  if [[ ${_HEX} =~ [A-Z0-9]{6} ]]; then
    _RED_VALUE=$(printf '%d' 0x${_HEX:0:2} )
    _GREEN_VALUE=$(printf '%d' 0x${_HEX:2:2} )
    _BLUE_VALUE=$(printf '%d' 0x${_HEX:4:2} )
    printf '%03d' "$(( (  _RED_VALUE<75?0:(_RED_VALUE-35)/40)*6*6 + 
                       (_GREEN_VALUE<75?0:(_GREEN_VALUE-35)/40)*6 +
                       ( _BLUE_VALUE<75?0:(_BLUE_VALUE-35)/40)    + 16 ))"
  else
    echo "5"
  fi
}

###############################################################################
# public functions

# set terminal foreground color
# @param COLOR_NAME out of 
#    red, blue, green, yellow, hibiscus, peach, orange, indigo, 
#    aquamarine, turquoise, magenta, wheat, grayscale
# @param TYPE out of 1-5 (all colors)
#             and 0 (only if logo-like color red yellow green blue)
#             defaults to 3
function TERM_COLOR_FG() {
  local COLOR_NAME=$1
  local TYPE=${2:-3}
  MY_HEX_VALUE=$( COLORS_GET_HEX_VALUE "${COLOR_NAME}" "${TYPE}" )
  printf "\x1b[38;5;$( COLORS_HEX_TO_256ANSI ${MY_HEX_VALUE} )m"
}

# set terminal background color
# @param COLOR_NAME out of 
#    red, blue, green, yellow, hibiscus, peach, orange, indigo, 
#    aquamarine, turquoise, magenta, wheat, grayscale
# @param TYPE out of 1-5 (all colors)
#             and 0 (only if logo-like color red yellow green blue)
#             defaults to 3
function TERM_COLOR_BG() {
  local COLOR_NAME=$1
  local TYPE=${2:-3}
  MY_HEX_VALUE=$( COLORS_GET_HEX_VALUE "${COLOR_NAME}" "${TYPE}" )
  printf "\x1b[48;5;$( COLORS_HEX_TO_256ANSI ${MY_HEX_VALUE} )m"
}

# resets colors but not font settings
#
# escape code 39 resets the foreground color to the implementation standard
# escape code 49 resets the background color to the implementation standard
function TERM_COLOR_RESET() {
  printf "\x1b[39m"
  printf "\x1b[49m"
}

