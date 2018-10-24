#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Gregor Leusch, Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# functions to check where files exist, work as predicted, have the correct line number, ...

# header guardian 
[[ -z ${BASH_FILESANITY_HEADER+x} ]] && BASH_FILESANITY_HEADER="LOADED" || return 0

# function to remove unwanted characters from a name
#
# @param  name
# @return input, but stripped to a) alpha-numberical letters or b) _.- punctuation marks
function sanitizeName() {
    tr -c -d '[:alnum:]_.-' <<< "$1"
}

# function to check whether a file exists
# will invoke exit on error
#
# @param _MODE          
#   determine the level of testing, out of: [exists, executable, runs]
#   - exists     true if file could be found
#   - executable true if file has executable rights for this user
#   - runs       true if file returns expected number of lines, given _OPTION (s.below); mostly testing helper files
# @param _FILE           file to be checked
# @param _OPTION         if _MODE==runs, enter options here
# @param _EXPECTED_LINES if _MODE==runs, enter expected minimum number of output lines here
function checkFile() {
    local _MODE=$1
    local _FILE=$2
    local _OPTION=$3         # only needed for _MODE==runs
    local _EXPECTED_LINES=$4 # only needed for _MODE==runs
    case ${_MODE} in
        (exists) 
            if [ ! -e "${_FILE}" ]; then
                LOGGER ${LOG_ERROR} "mandatory file missing: ${_FILE}"
                exit 2
            fi
            ;;
        (executable) 
            if [ ! -x "${_FILE}" ]; then 
                LOGGER ${LOG_ERROR} "mandatory file missing or not executable: ${_FILE}"
                exit 2
            fi
            ;;
        (runs)
            nlines=$( ${_FILE} ${_OPTION} 2>&1 | wc -l)
            if [ $nlines -lt ${_EXPECTED_LINES} ]; then
                LOGGER ${LOG_ERROR} "unexpected results when trying to execute ${_FILE}. Missing/wrong format?"
                exit 2
            fi
            ;;
        (*)
            LOGGER ${LOG_ERROR} "internal error: unknown check mode '${_MODE}' for '${_FILE}'."
            exit 2
            ;;
    esac
}

# function to check whether all files given have the same line numbers
# will invoke exit on error
# 
# @param _CURRENT_STEP   step in which the test has been invoked, for logging purposes
# @param _REFERENCE_FILE file to which the subsequent ones are compared against
# @param [hyp_files]     one or many files whose line number will be compared to the reference
function assertEqualNumberOfLines() {
    local _CURRENT_STEP=$1
    local _REFERENCE_FILE=$2
    checkFile exists "${_REFERENCE_FILE}" 
    
    refLines=$( cat "${_REFERENCE_FILE}" | gzip -c -d -f | wc -l)
    for hypFile in ${@:3}; do
        checkFile exists "${hypFile}"

        hypLines=$( cat "${hypFile}" | gzip -c -d -f | wc -l)
        if [ $refLines -ne $hypLines ]; then
          LOGGER ${LOG_ERROR} "${_CURRENT_STEP}: mismatch in number of lines between ${_REFERENCE_FILE} (${refLines}) and ${hypFile} (${hypLines})"
          exit 2
        else
          LOGGER ${LOG_DEBUG} "check on equal line number between ${_REFERENCE_FILE} and ${hypFile} successful (${refLines})"
        fi
    done
}
