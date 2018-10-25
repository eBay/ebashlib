#!/bin/bash 

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# header guardian 
# ${var+x} is a parameter expansion which evaluates to null if the variable is unset
[[ -z ${BASH_REGRESSION_TEST_HEADER+x} ]] && BASH_REGRESSION_TEST_HEADER="LOADED" || return 0

source $( dirname ${BASH_SOURCE} )/../report/report.sh

# overall tests runs
declare -i REGRESSION_TEST_TESTS_RAN=0
# overall test failures
declare -i REGRESSION_TEST_TESTS_FAILED=0

# how many lines of diff to output on error
declare -i REGRESSION_TEST_MAX_DIFF=10

# setter function for the maximum lines a diff will show
# 
# param: number of lines (ignoring first two lines "output" & "expected")
function REGRESSION_TEST_SET_MAX_DIFF() {
  REGRESSION_TEST_MAX_DIFF=${1}
}

# report verbosity level, as numerical values
# - declare works in bash 2 and above. 
#     -i = integer

# only output on error
declare -i REGRESSION_TEST_VERBOSITY_ERROR=40
# output all tests executed
declare -i REGRESSION_TEST_VERBOSITY_INFO=20
# output all tests and how they were executed
declare -i REGRESSION_TEST_VERBOSITY_DEBUG=10

# define default verbosity level
REGRESSION_TEST_VERBOSITY=${REGRESSION_TEST_VERBOSITY:-$REGRESSION_TEST_VERBOSITY_INFO}

# setter function for the verbosity of the regression tests
function REGRESSION_TEST_SET_VERBOSITY() {
  REGRESSION_TEST_VERBOSITY=${1}
}

# list containing all names
REGRESSION_TEST_NAMES=()
REGRESSION_TEST_NAMES+=("Names of all tests")

# list marking successful (=1) and unsuccessful (!=1) runs 
REGRESSION_TEST_SUCCESS=()
REGRESSION_TEST_SUCCESS+=(1)

# list of the commands executed 
REGRESSION_TEST_COMMAND=()
REGRESSION_TEST_COMMAND+=("List of the exact command that was tested")

# list of what came out of each test
REGRESSION_TEST_OUTPUT=()
REGRESSION_TEST_OUTPUT+=("What came out of the test")

# list of what was actually expected
REGRESSION_TEST_EXPECTED=()
REGRESSION_TEST_EXPECTED+=("What was actually expected")

# some means of preserve any options such as --ignore-matching-lines for diff tests
REGRESSION_TEST_DIFF_OPTIONS=()
REGRESSION_TEST_DIFF_OPTIONS+=("Do we have any options?")

# private function to be called at the beginning of each test group
#
# initializes the main parameters
function __REGRESSION_TEST_INITIALIZE__() {
  REGRESSION_TEST_CURRENT_DESCRIPTION=${1}
}

# private function called whenever a test was successful
function __REGRESSION_TEST_SUCCESS__() {
  local description=$1
  echo -n "." > /dev/stderr
  REGRESSION_TEST_NAMES+=("$description")
  REGRESSION_TEST_SUCCESS+=(1)
}

# private function called whenever a test was unsuccessful
function __REGRESSION_TEST_FAILURE__() {
  local description=$1
  let 'REGRESSION_TEST_TESTS_FAILED++'
  echo -n "F" > /dev/stderr
  REGRESSION_TEST_NAMES+=("$description")
  REGRESSION_TEST_SUCCESS+=(0)
}

# function initiating the tests
#
# mandatory to call at the beginning
# @param format: all formats supported by the bashlib/report library
function REGRESSION_TEST_START() {
  REPORT_SET_OUTPUT_FORMAT "${1:=MARKDOWN}"
  REGRESSION_TEST_START_TIME=$(date '+%s')
  __REGRESSION_TEST_INITIALIZE__
  trap __REGRESSION_TEST_CLEANUP__ EXIT
}


# function to register a new test group
#
# Useful if you want to group stuff in the output, but not mandatory. 
# @param description name of the test group
function REGRESSION_TEST_NEW_GROUP() {
  local description=${1}
  echo "" > /dev/stderr
  echo "${description}" > /dev/stderr
  __REGRESSION_TEST_INITIALIZE__ "${description}"
}

# function to report the end of the current test group (or the whole test)
#
# mandatory as last step.
# if a new test group is started after this command, it will keep the overall
# exit code and invoke later (via "trap")
function REGRESSION_TEST_END() {
  # there might be other tests up ahead, so we reset the counters 
  __REGRESSION_TEST_INITIALIZE__
}

function REGRESSION_TEST_WRITE_REPORT() {
  echo "" > /dev/stderr
  REPORT_START "Regression Test"
  REPORT_PARAGRAPH "Invokation by ${BASH_SOURCE[1]} on $(date '+%Y-%m-%d') by $USER."
  REPORT_SECTION "Summary"

  REGRESSION_TEST_STOP_TIME=$(date '+%s')
  let "TIME_TAKEN_SECONDS = (REGRESSION_TEST_STOP_TIME-REGRESSION_TEST_START_TIME)"

  if [[ "${REGRESSION_TEST_TESTS_FAILED}" -eq 0 ]]; then
    REPORT_PARAGRAPH "All ${REGRESSION_TEST_TESTS_RAN} tests ran successfully.
    In total, the tests took ${TIME_TAKEN_SECONDS} seconds."
  else
    REPORT_PARAGRAPH "Out of ${REGRESSION_TEST_TESTS_RAN} tests,
    there have been ${REGRESSION_TEST_TESTS_FAILED} errors.
    In total, the tests took ${TIME_TAKEN_SECONDS} seconds."
  fi
  # do we output any details? Only if verbosity is high enough or a test failed
  if [[ "${REGRESSION_TEST_TESTS_FAILED}" -ne 0 || "${REGRESSION_TEST_VERBOSITY}" -le ${REGRESSION_TEST_VERBOSITY_INFO} ]]; then
      REPORT_CHAPTER "Details"
        for currentTest in $( seq 1 ${REGRESSION_TEST_TESTS_RAN} ); do
            if [[ "${REGRESSION_TEST_SUCCESS[$currentTest]}" -eq 1 ]]; then
                [[ "${REGRESSION_TEST_VERBOSITY}" -le ${REGRESSION_TEST_VERBOSITY_INFO} ]] \
                    && REPORT_PARAGRAPH "__OK__ (#$currentTest) ${REGRESSION_TEST_NAMES[$currentTest]}"
                [[ "${REGRESSION_TEST_VERBOSITY}" -le ${REGRESSION_TEST_VERBOSITY_DEBUG} ]] \
                    && REPORT_CODE_BLOCK "${REGRESSION_TEST_COMMAND[$currentTest]}"
            else
                REPORT_PARAGRAPH "__FAIL__ (#$currentTest) ${REGRESSION_TEST_NAMES[$currentTest]}"
                REPORT_CODE_BLOCK "${REGRESSION_TEST_COMMAND[$currentTest]}"
                output="${REGRESSION_TEST_OUTPUT[$currentTest]}"
                expected="${REGRESSION_TEST_EXPECTED[$currentTest]}"
                diffOptions="${REGRESSION_TEST_DIFF_OPTIONS[$currentTest]}"
                if [[ -z "$output" ]]; then
                    REPORT_PARAGRAPH "Output was empty"
                else
                    outputSize=$( echo "${output}" | wc -l )
                    expectedSize=$( echo "${expected}" | wc -l )
                    if [[ "$outputSize" -le 5 && "$expectedSize" -le 5 ]]; then
                      REPORT_PARAGRAPH "Command output:"
                      REPORT_CODE_BLOCK "$output"
                      REPORT_PARAGRAPH "Expected Output"
                      REPORT_CODE_BLOCK "$expected"
                    else
                      if [[ "$outputSize" -ne "$expectedSize" ]]; then
                          REPORT_PARAGRAPH "Output consisted of $outputSize lines, expected input of $expectedSize lines."
                      fi
                      REPORT_PARAGRAPH "Showing diff of the first ${REGRESSION_TEST_MAX_DIFF} lines."
                      let 'REGRESSION_TEST_TOTAL_MAX_DIFF = REGRESSION_TEST_MAX_DIFF + 2'
                      REPORT_UNIFIED_DIFF "$(diff --new-file ${diffOptions} --unified --label output --label expected <( echo "$output" ) <( echo "$expected" ) | head -n ${REGRESSION_TEST_TOTAL_MAX_DIFF} )" 
            
                    fi  
                fi
            fi  
        done
      REPORT_END
  fi
}

# function to assert command output
#
# @param description name of this assert test
# @param command executed via eval
# @param expectedResult expected output, if any (string, optional)
# @param commandInput input to be piped into the command (string, defaults to "")
function REGRESSION_TEST_ASSERT() {
  local description=$1
  local command=$2
  local expectedResult=$( echo -ne "${3}" )
  local commandInput=${4:-}
  let 'REGRESSION_TEST_TESTS_RAN++'

  REGRESSION_TEST_COMMAND+=("${command}${commandInput:+ <<< $commandInput}") 
  local commandResult="$(eval 2>/dev/null ${command} <<< ${commandInput})" || true

  [[ -z "$commandResult" ]] && commandResult="nothing" || commandResult="\"$commandResult\""
  [[ -z "$expectedResult" ]] && expectedResult="nothing" || expectedResult="\"$expectedResult\""
  REGRESSION_TEST_OUTPUT+=("${commandResult}")
  REGRESSION_TEST_EXPECTED+=("${expectedResult}")
  REGRESSION_TEST_DIFF_OPTIONS+=("")

  if [[ "${commandResult}" == "${expectedResult}" ]]; then
    __REGRESSION_TEST_SUCCESS__ "${description}"
  else
    __REGRESSION_TEST_FAILURE__ "${description}"
  fi
}

# function to assert the exit code of a command 
#
# @param description name of this assert test
# @param command executed via eval
# @param expectedCode expected exit code (optional, defaults to 0)
# @param commandInput input to be piped into the command (optional, defaults to "")
function REGRESSION_TEST_ASSERT_RAISE() {
  local description=$1
  local command=$2
  local expectedCode=${3:-0}
  local commandInput=${4:-}
  let 'REGRESSION_TEST_TESTS_RAN++'

  REGRESSION_TEST_COMMAND+=("${command}${commandInput:+ <<< $commandInput}") 
  commandOutput=$(eval 2>&1 "${2}" <<< ${commandInput}) 
  exitCode=$?

  commandOutput=${commandOutput:-"----- empty output -----"}
  REGRESSION_TEST_OUTPUT+=("exit code ${exitCode}

**program output (first $REGRESSION_TEST_MAX_DIFF lines)**
$(echo "$commandOutput" | head -n $REGRESSION_TEST_MAX_DIFF)")
  REGRESSION_TEST_EXPECTED+=("exit code ${expectedCode}")
  REGRESSION_TEST_DIFF_OPTIONS+=("")

  if [[ "${exitCode}" -eq "${expectedCode}" ]]; then
    __REGRESSION_TEST_SUCCESS__ "${description}"
  else
    __REGRESSION_TEST_FAILURE__ "${description}"
  fi
}

# function to check whether two files differ
#
# @param description   human readable description of what is currently tested
# @param outputFile    the file that was produced and should be checked
# @param referenceFile gold standard output file
# @param diffIgnore    optional. Regular expression of which lines should be ignored in the diff 
#                      process (e.g., timestamps, user names...)
# 
# @notes diff behavior for ignoring lines:
# * the whole matching line will be ignored, so any diffs in that line will be unnoticed as well
# * if a certain change in a hunk (diff block) does NOT match a regEx, you will see the whole hunk.
#   from the man page: "for each nonignorable change, diff prints the complete set of changes in 
#                       its vicinity, including the ignorable ones."
function REGRESSION_TEST_DIFF_FILES() {
  local description=$1
  local outputFile=$2
  local referenceFile=$3
  local diffIgnore=${4:+--ignore-matching-lines=$4}

  let 'REGRESSION_TEST_TESTS_RAN++'

  # --ignore-matching-lines: if set, add regular expression of lines that are to be ignored
  #                          (ALL lines within a change block need to match)
  # --brief: output only whether files differ
  # --new-file: treat absent files as empty

  REGRESSION_TEST_COMMAND+=("diff --brief ${diffIgnore}  
     --new-file 
     \"${outputFile}\" 
     \"${referenceFile}\"")
  REGRESSION_TEST_DIFF_OPTIONS+=( "${diffIgnore}")

  [[ -e "${outputFile}" ]] && REGRESSION_TEST_OUTPUT+=( "$( cat "${outputFile}" )" ) || REGRESSION_TEST_OUTPUT+=( "$outputFile not found" )
  [[ -e "${referenceFile}" ]] && REGRESSION_TEST_EXPECTED+=( "$( cat "${referenceFile}" )" ) || REGRESSION_TEST_EXPECTED+=( "$referenceFile not found" )
  DIFFME="$( diff --brief --new-file ${diffIgnore} "${outputFile}" "${referenceFile}" 2> /dev/null )"
  if [[ $? -eq 0 ]]; then
    __REGRESSION_TEST_SUCCESS__ "${description}"
  else
    __REGRESSION_TEST_FAILURE__ "${description}"
  fi  
}

# private function to check whether two files differ with floating precision
#
# @param outputFile    the file that was produced and should be checked
# @param referenceFile gold standard output file
# @param precision     float where delta difference is tolerable
function __REGRESSION_DIFF_FLOAT(){
  local outputFile=$1
  local referenceFile=$2
  local precision=${3}
  awk -v PRECISION=${precision} '
         # check whether a token is a number. (awk treats them as zero for arithmetics, but not for comparison)
         function isnum(x) {
             return(x==x+0);
         }
         # compute absolute value
         function abs(v) {
             return v < 0 ? -v : v;
         }
         # ingest whole lines
         BEGIN {
             FS="\n";
             found_mismatch=0;
         } 
         { 
             # still in first file?
             if (ARGV[1]==FILENAME) {
                 first_file[NR]=$1; 
                 next;
             } else { 
                 mismatch = 0
                 split(first_file[FNR], first_file_linesplit, " "); 
                 split($1, second_file_linesplit, " "); 
                 if (length(first_file_linesplit) != length(second_file_linesplit)) {
                     mismatch=1;
                 }
                 for (i=1; i <= length(first_file_linesplit); i++) {
                     if (isnum(first_file_linesplit[i]) != isnum(second_file_linesplit[i])) {
                         mismatch=1;
                     }
                     if (isnum(first_file_linesplit[i])) {
                         if (abs(first_file_linesplit[i] - second_file_linesplit[i]) > PRECISION) {
                             mismatch=1;
                         }
                     } else {
                         if (first_file_linesplit[i] != second_file_linesplit[i]) {
                             mismatch=1;
                         }
                     }
                 }
                 if (mismatch==1) {
                     found_mismatch=1;
                     print "line mismatch: "first_file[FNR]" vs. "$1;
                 }
             }
         }
         END {
             if (found_mismatch==1) {
                 print "files differ!";
                 exit 2;
             } 
             exit 0;
         }
         ' "${outputFile}" "${referenceFile}"
}

# function to check whether two files differ with floating precision
#
# @param description   human readable description of what is currently tested
# @param outputFile    the file that was produced and should be checked
# @param referenceFile gold standard output file
# @param precision     float where delta difference is tolerable. defaults to 0.000001
function REGRESSION_TEST_DIFF_FILES_FLOAT() {
  local description=$1
  local outputFile=$2
  local referenceFile=$3
  local precision=${4:-0.000001}

  let 'REGRESSION_TEST_TESTS_RAN++'

  [[ -e "${outputFile}" ]] && REGRESSION_TEST_OUTPUT+=( "$( cat "${outputFile}" )" ) || REGRESSION_TEST_OUTPUT+=( "$outputFile not found" )
  [[ -e "${referenceFile}" ]] && REGRESSION_TEST_EXPECTED+=( "$( cat "${referenceFile}" )" ) || REGRESSION_TEST_EXPECTED+=( "$referenceFile not found" )

  REGRESSION_TEST_COMMAND+=("__REGRESSION_DIFF_FLOAT \"${outputFile}\" \"${referenceFile}\" \"${precision}\"")
  REGRESSION_TEST_DIFF_OPTIONS+=("")

  DIFFME="$( __REGRESSION_DIFF_FLOAT "${outputFile}" "${referenceFile}" "${precision}" )"
  if [[ $? -eq 0 ]]; then
    __REGRESSION_TEST_SUCCESS__ "${description}"
  else
    __REGRESSION_TEST_FAILURE__ "${description}"
  fi  
}

# private function called at the end of the tests (via trap)
# which determines whether the an exit code should be uttered
function __REGRESSION_TEST_CLEANUP__() {
  REGRESSION_TEST_WRITE_REPORT
  [[ "${REGRESSION_TEST_TESTS_FAILED}" -eq 0 ]] && exit 0 || exit 2
}



