#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# simple example script for shell options. Run with -h for help

source $(dirname $0)/../bashlib/bashlib.sh

setUsage "Simple example script for shell options.\nusage: $(basename $0) [options]"
addOption -f --firstNumber  dest=FIRST      required       help="First number in the equation"
addOption -s --secondNumber dest=SECOND     required       help="Second number in the equation"
addOption -p --plusMinus    dest=PLUS_MINUS default="plus" help="operation, out of <plus|minus>"
parseOptions "$@"

SUM=0

case $PLUS_MINUS in
  plus)
    let "SUM = FIRST + SECOND"
    ;;
  minus)
    let "SUM = FIRST - SECOND"
    ;;
  *)
    LOGGER ${LOG_ERROR} "Unknown option $PLUS_MINUS, expecting plus or minus"
esac

echo "SUM = $SUM"

