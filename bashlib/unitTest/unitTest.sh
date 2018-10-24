#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# function battery to conduct some basic unit testing
#
# public functions:
#
# UT_RUN_TEST_SUITE( description )
#   executes the current test suite and prints a statistic on pass and fail assertions
# 
#   a sample run will be: 
#     UT_setUp             (optional, must be declared as a function with exactly this name)
#     UT_testMy1stFunction (first function found that matches the name UT_test[a-zA-Z0-9_]* )
#     UT_tearDown          (optional, must be declared as a function with exactly this name) 
#     UT_setUp             (as above)
#     UT_testMy2ndFunction (second function found that matches the name UT_test[a-zA-Z0-9_]* )
#     UT_tearDown          (as above)
#
# UT_ASSERT_EQUAL( description, hypothesis, reference ) 
#   checks whether hypothesis and reference are equal. 
#   will print a fail notice along with the description if not.
#
# UT_SET_REPORT_PASS_ON() 
#   setter function to switch reports on passed tests on 
# UT_SET_REPORT_PASS_OFF() 
#   setter function to switch reports on passed tests off
#
# @note: 
#   this script is not relying on LOGGER functionality here to make these core functions self-sustaining
###############################################################################

# header guardian 
# ${var+x} is a parameter expansion which evaluates to null if the variable is unset
if [ -z ${BASH_UNIT_TEST_HEADER+x} ]; then
  BASH_UNIT_TEST_HEADER="LOADED"
else
  return
fi

# count how much successful tests were conducted in a group
declare -i UT_SINGLE_PASS_COUNT=0
# count how much unsuccessful tests were conducted in a group
declare -i UT_SINGLE_FAIL_COUNT=0

# private beautification 
__UT_SEPARATOR__="--------------------------------------------------"

# if true, passed tests are shown as well
UT_SETTING_REPORT_PASS=true

# variable storing the description of a test suite
UT_CURRENT_GROUP_DESCRIPTION=""

# private function to initialize a new test suite
#
# @param UT_CURRENT_GROUP_DESCRIPTION name of the test group (optional)
function __UT_INITIALIZE__() {
  UT_CURRENT_GROUP_DESCRIPTION=${1:-"DEFAULT"}
  UT_SINGLE_PASS_COUNT=0
  UT_SINGLE_FAIL_COUNT=0
  UT_CURRENT_GROUP_START_TIME=$(date +%s)
  echo "${__UT_SEPARATOR__}"
  echo "Starting Test Suite: ${UT_CURRENT_GROUP_DESCRIPTION}"
  echo "${__UT_SEPARATOR__}"
}

# private function to finish current test suite, printing overall statistics
function __UT_FINISH__() {
  UT_CURRENT_GROUP_STOP_TIME=$(date +%s)
  let "TIME_TAKEN_SECONDS = (UT_CURRENT_GROUP_STOP_TIME-UT_CURRENT_GROUP_START_TIME)"
  echo "${__UT_SEPARATOR__}"
  echo "Ending Test Suite ${UT_CURRENT_GROUP_DESCRIPTION}"
  echo "Pass: ${UT_SINGLE_PASS_COUNT} Fail: ${UT_SINGLE_FAIL_COUNT} Time[s]: ${TIME_TAKEN_SECONDS}"
  echo "${__UT_SEPARATOR__}"
}

# private function on passed tests.
#
# @param _MESSAGE user's description of the conducted test
function __UT_REPORT_PASS__() {
  local _MESSAGE=$1
  if [ "${UT_SETTING_REPORT_PASS}" = true ]; then
    echo "[passed] ${_MESSAGE}"
  fi
  let "UT_SINGLE_PASS_COUNT += 1"
}

# private function on failed tests.
#
# @param _CALL_FUNCTION script which called the failed test. 
#                       @note: handed over as a variable here as only the initial function can rely on the array 
#                       position of the caller
# @param _CALL_LINE     script line number which called the failed test.
# @param _DESCRIPTION   user's description of the conducted test
# @param _MESSAGE       error description by the test function
function __UT_REPORT_FAIL__() {
  local _CALL_FUNCTION=$1
  local _CALL_LINE=$2
  local _DESCRIPTION=$3
  local _MESSAGE=$4
  echo "[failed] [${_CALL_FUNCTION}:${_CALL_LINE}] ${_DESCRIPTION} -- ${_MESSAGE}"
  let "UT_SINGLE_FAIL_COUNT += 1"
}

# setter function to switch reports on passed tests on
function UT_SET_REPORT_PASS_ON() {
  UT_SETTING_REPORT_PASS=true
}

# setter function to switch reports on passed tests off
function UT_SET_REPORT_PASS_OFF() {
  UT_SETTING_REPORT_PASS=false
}

# checks whether two values are equal
#
# @param DESCRIPTION name of the test
# @param HYP_RESULT  output of the function
# @param REF_RESULT  reference result that the function should output
#
# @return "passed: ..." on success, "failed: ..." on failure
function UT_ASSERT_EQUAL() {
  local DESCRIPTION=$1
  local HYP_RESULT=$2
  local REF_RESULT=$3
  local CALL_FUNCTION=$(basename ${BASH_SOURCE[1]})
  local CALL_LINE=${BASH_LINENO[0]} 

  if [[ "${HYP_RESULT}" == "${REF_RESULT}" ]]; then
    __UT_REPORT_PASS__ "${DESCRIPTION}"
  else
    __UT_REPORT_FAIL__ "${CALL_FUNCTION}" "${CALL_LINE}" "${DESCRIPTION}" "${HYP_RESULT} != ${REF_RESULT}"
  fi
}

# executes the current test suite and prints a statistic on pass and fail assertions
# 
# a sample run will be: 
# UT_setUp                (optional, must be declared as a function with exactly this name)
# UT_testMy1stFunction  (first function found that matches the name UT_test[a-zA-Z0-9_]* )
# UT_tearDown             (optional, must be declared as a function with exactly this name) 
# UT_setUp                (as above)
# UT_testMy2ndFunction (second function found that matches the name UT_test[a-zA-Z0-9_]* )
# UT_tearDown             (as above)
#
# @param _DESCRIPTION name of the test suite
function UT_RUN_TEST_SUITE() {
  local _DESCRIPTION=$1

  __UT_INITIALIZE__ "${_DESCRIPTION}"

  # search for all functions that are named UT_testABC
  for testcase in $(declare -f | grep -o "^UT_test[a-zA-Z0-9_]*"); do

    # check if a UT_setUp is set and is a function => execute
    type UT_setUp 2>&1 | grep -q function && UT_setUp
    # execute the testcase
    ${testcase}
    # check if a UT_tearDown is set and is a function => execute
    type UT_tearDown 2>&1 | grep -q function && UT_tearDown

  done

  __UT_FINISH__
}
