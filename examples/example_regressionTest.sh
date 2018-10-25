#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# simple example script for regression testing

source $(dirname $0)/../bashlib/bashlib.sh

setUsage "Simple example script for regression testing.\nusage: $(basename $0) [options]"
addOption -f --format  dest=FORMAT default="TERMINAL" help="Output format, out of HTML, MARKDOWN, TERMINAL"
addOption -q --quiet   dest=QUIET flagTrue help="Set output verbosity to only error files"
addOption -d --debug   dest=DEBUG flagTrue help="Set output verbosity to debug mode"
addOption -m --max-lines dest=MAX_LINES default="10" help="no. of lines a diff should output on failure (default: 10)"
addOption -p --positive dest=POSITIVE flagTrue help="For demonstration of successful run, only execute positive tests"
parseOptions "$@"

# this function is mandatory to call at the beginning. The regressionTest functions
# make use of the bashlib/report library, so it supports all of their formats
REGRESSION_TEST_START "${FORMAT}"

# set the output verbosity level. If both options are given... well... then trust the debug
[[ "$QUIET" == "true" ]] && REGRESSION_TEST_SET_VERBOSITY ${REGRESSION_TEST_VERBOSITY_ERROR}
[[ "$DEBUG" == "true" ]] && REGRESSION_TEST_SET_VERBOSITY ${REGRESSION_TEST_VERBOSITY_DEBUG}

# the tests below will fail sometimes. This is how much output we will see
REGRESSION_TEST_SET_MAX_DIFF "${MAX_LINES}"

# we register a new test group. Useful if you want to group stuff in the output
# but not mandatory. 
REGRESSION_TEST_NEW_GROUP "Assert commands"

# function to assert command output
#
# assert commands have the parameters:
# 1. description (string)
# 2. command to be executed (bash-eval compatible)
# 3. expected output, if any (string, optional)
# 4. input to be piped into the command (string, defaults to "")
# CORRECT: nothing in nothing out
REGRESSION_TEST_ASSERT "nothing in nothing out" "echo"
# ERROR:   never mix foo with fu
[[ "$POSITIVE" != "true" ]] && REGRESSION_TEST_ASSERT "I pity the foo" "echo fu" "foo"
# ERROR:   never expect anything in life to be for free
[[ "$POSITIVE" != "true" ]] && REGRESSION_TEST_ASSERT "nothing comes for free" "cat" "" "out of thin air"
# ERROR:   their chief weapon is surprise
someInstitution="the Spanish Inquisition"
[[ "$POSITIVE" != "true" ]] && REGRESSION_TEST_ASSERT "their chief weapon is surprise" "cat" "Nobody expects ${someInstitution}" "I was not expecting ${someInstitution}"

# function to assert whether command raises correct exit code
#
# assert_raise commands have the parameters:
# 1. description (string)
# 2. command to be executed (bash-eval compatible)
# 3. expected exit code (defaults to 0, "normal")
# 4. input to be piped into the command (string, defaults to "")

# CORRECT: exit code is 0
REGRESSION_TEST_ASSERT_RAISE "true story, bro" "true"
# CORRECT: exit code is 42
REGRESSION_TEST_ASSERT_RAISE "story of my life" "exit 42" 42
# ERROR: quotes not set properly
[[ "$POSITIVE" != "true" ]] && REGRESSION_TEST_ASSERT_RAISE "read the exit code" "read code
echo \"Hi, my code is $code- what? My code is $code- who? My code is *whicky whicky* a bit shady.\"
exit $code" 128 "128"
# CORRECT: this works (as would using '')
REGRESSION_TEST_ASSERT_RAISE "reading exit code; bug in quotes - fixed." "read code; echo \"Code:$code\"; exit \$code" 128 "128"

# report the end of this test group. Since a lot of errors already happened, 
# on exit we will already invoke an exit error code (via "trap"), but we can continue
# to carry out other tests as well; even if the following test group succeeds, the error code
# will be issued.
REGRESSION_TEST_END 

REGRESSION_TEST_NEW_GROUP "Diff commands"

# ERROR: the versions of this fairy tale differ considerably
[[ "$POSITIVE" != "true" ]] && REGRESSION_TEST_DIFF_FILES "unfair fairy tale comparison" \
                           "$(dirname $0)/files/vomFischerUndSeinerFrau/1812/vonDenFischerUndSiineFru.txt" \
                           "$(dirname $0)/files/vomFischerUndSeinerFrau/1819/vonDemFischerUnSiineFru.txt"

# ERROR: even if we ignore all lines that 
# * have a year timestamp or 
# * are pure Markdown chapter entries (====)
#
# ... still, it fails... because the line numbers differ.
#
# NB #1: intentional behaviour of diff is that the ignore line RE has to match the whole
#   block that differs. Otherwise, it is still output.
# NB #2: for the diff output, the ignore-lines option does not work with diff, so we see
#   the whole file...
[[ "$POSITIVE" != "true" ]] && REGRESSION_TEST_DIFF_FILES "ignoring the timestamp does not help" \
                           "$(dirname $0)/files/vomFischerUndSeinerFrau/1812/README.md" \
                           "$(dirname $0)/files/vomFischerUndSeinerFrau/1819/README.md" \
                           "[0-9]\{4\}\|^=*$"

# CORRECT: just to have one test that works: 
# ignore all numbers and all lines containing a "="
REGRESSION_TEST_DIFF_FILES "ignoring almost everything is the best you can do" \
                           "$(dirname $0)/files/vomFischerUndSeinerFrau/1812/README.md" \
                           "$(dirname $0)/files/vomFischerUndSeinerFrau/1819/README.md" \
                           "[0-9]\|="

# ERROR: files differ in floating point 
[[ "$POSITIVE" != "true" ]] && REGRESSION_TEST_DIFF_FILES "floating point differences can be a nuisance" \
    "$(dirname $0)/files/floating/first_result.txt" \
    "$(dirname $0)/files/floating/second_result.txt" 

# CORRECT. floats differ below default precision of 0.000001
REGRESSION_TEST_DIFF_FILES_FLOAT "but there is a function for that as well" \
    "$(dirname $0)/files/floating/first_result.txt" \
    "$(dirname $0)/files/floating/second_result.txt" 

# ERROR ... but not below precision of 0.00000001
[[ "$POSITIVE" != "true" ]] && REGRESSION_TEST_DIFF_FILES_FLOAT "and you can increase precision to adjust fail/pass" \
    "$(dirname $0)/files/floating/first_result.txt" \
    "$(dirname $0)/files/floating/second_result.txt" \
    0.00000001

[[ "$POSITIVE" != "true" ]] && REGRESSION_TEST_DIFF_FILES_FLOAT "still failing on number vs. words" \
    "$(dirname $0)/files/floating/first_result.txt" \
    "$(dirname $0)/files/floating/third_result.txt" \
    0.00000001

[[ "$POSITIVE" != "true" ]] && REGRESSION_TEST_DIFF_FILES_FLOAT "still failing on missing words" \
    "$(dirname $0)/files/floating/first_result.txt" \
    "$(dirname $0)/files/floating/fourth_result.txt" \
    0.00000001

[[ "$POSITIVE" != "true" ]] && REGRESSION_TEST_DIFF_FILES_FLOAT "still failing on changed words" \
    "$(dirname $0)/files/floating/first_result.txt" \
    "$(dirname $0)/files/floating/fifth_result.txt" \
    0.00000001

REGRESSION_TEST_END 

