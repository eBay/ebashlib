#!/usr/bin/env bash 

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# header guardian 
[[ -z ${BASH_LOGGING_HEADER+x} ]] && BASH_LOGGING_HEADER="LOADED" || return 0

# define log levels 
# - numerical values taken from python logging
# - declare works in bash 2 and above. 
#     -i = integer
#     -x = export outside environment of script

# no output
declare -i -x LOG_QUIET=999
# script failed
declare -i -x LOG_ERROR=40
# odd behaviour that does not stop the script but could potentially be wrong execution
declare -i -x LOG_WARNING=30
# script starting / ending ...
declare -i -x LOG_INFO=20
# function messages, progress update
declare -i -x LOG_DEBUG=10
# verbose logging such as variable contents...
declare -i -x LOG_TRACE=0

# define log level for output
LOGGING_LOG_LEVEL=${LOGGING_LOG_LEVEL:-$LOG_TRACE}

# function to set the log level for output
function LOGGER_SET_LOG_LEVEL() {
  local _NEW_LOG_LEVEL=$1
  # TODO: perform sanity checks here: 
  # - is integer
  # - is known log level 
  LOGGING_LOG_LEVEL=${_NEW_LOG_LEVEL}
}

# for consistent output, this line separator can be included into the logging output
LOGGING_SEPARATOR="------------------------------------------------------------"

# define standard data format
LOGGING_DATE_FORMAT=${LOGGING_DATE_FORMAT:-'+%Y-%m-%d %H:%M:%S'}

# function to output logging to stdout
#
# @param _LOG_LEVEL numerical value indicating severity
# @param _LOG_MESSAGE string to be output as message. can contain linebreaks etc.
#
# log levels higher than info will also show the invoking script/line
function LOGGER () {
    local _LOG_LEVEL=$1
    local _LOG_MESSAGE=$2

    local CALL_FUNCTION=$(basename ${BASH_SOURCE[1]})
    local CALL_LINE=${BASH_LINENO[0]}

    if [[ "${BASH_SOURCE[1]}" == "${BASH_SOURCE[0]}" ]]; then
       # this function has been invoked by another convenience function from this script
       # so we roll back the wheel
       CALL_FUNCTION=$(basename ${BASH_SOURCE[2]})
       CALL_LINE=${BASH_LINENO[1]}
    fi
 
    # check if this log message is happening based on the current log level
    if [ $LOGGING_LOG_LEVEL -gt ${_LOG_LEVEL} ]; then
      return
    fi

    local currentMessage="$( date "${LOGGING_DATE_FORMAT}" )"

    case $_LOG_LEVEL in
        ${LOG_ERROR})
           currentMessage="$currentMessage [ERROR] (${CALL_FUNCTION}:${CALL_LINE})"
           ;;
        ${LOG_WARNING})
           currentMessage="$currentMessage  [WARN] (${CALL_FUNCTION}:${CALL_LINE})"
           ;;
        ${LOG_INFO})
           currentMessage="$currentMessage  [INFO]"
           ;;
        ${LOG_DEBUG})
           currentMessage="$currentMessage [DEBUG]"
           ;;
        ${LOG_TRACE})
           currentMessage="$currentMessage [TRACE]"
           ;;
        *)
           currentMessage="$currentMessage [UNSET]"
           ;;
    esac

    echo -e "$currentMessage ${_LOG_MESSAGE}" >&2      
}

### convenience functions up ahead ###

# convenience function to output a section log message 
# @param _LOG_LEVEL   numerical value indicating severity
# @param _LOG_MESSAGE string to be output as section name. can contain linebreaks etc.
#
# @deprecated as of 0.8.X
function LOGGER_SECTION() {
    local _LOG_LEVEL=$1
    local _LOG_MESSAGE=$2
    LOGGER ${_LOG_LEVEL} "${LOGGING_SEPARATOR}"
    LOGGER ${_LOG_LEVEL} "${_LOG_MESSAGE}"
    LOGGER ${_LOG_LEVEL} "${LOGGING_SEPARATOR}"
}

# convenience function to output a block message on INFO
# ... basically wraps the message with two line separators
# @param _LOG_MESSAGE string to be output in between lines. can contain linebreaks etc.
function LOGGER_BLOCK() {
    local _LOG_MESSAGE=$1
    LOGGER ${LOG_INFO} "${LOGGING_SEPARATOR}"
    LOGGER ${LOG_INFO} "${_LOG_MESSAGE}"
    LOGGER ${LOG_INFO} "${LOGGING_SEPARATOR}"
}

# convenience function to output plain text enclosed by lines
# TODO decide on whether this should be exampled/documented
# @param _LOG_LEVEL   numerical value indicating severity
# @param _LOG_HEADER  string header
# @param _LOG_MESSAGE string to be output as plain text. can contain linebreaks etc.
function LOGGER_PLAINTEXT() {
    local _LOG_LEVEL=$1
    local _LOG_HEADER=$2
    local _LOG_MESSAGE=$3
    LOGGER ${_LOG_LEVEL} "${LOGGING_SEPARATOR}"
    LOGGER ${_LOG_LEVEL} "${_LOG_HEADER}\n${_LOG_MESSAGE}"
    LOGGER ${_LOG_LEVEL} "${LOGGING_SEPARATOR}"
}

# log script failure
# note: should only be invoked before error exits (not done automatically)
function LOGGER_ERROR() {
  LOGGER ${LOG_ERROR} "$1"
}

# log odd behaviour that does not stop the script but could potentially be wrong execution
function LOGGER_WARNING() {
  LOGGER ${LOG_WARNING} "$1"
}

# log as above, for the lazy ones' convenience
function LOGGER_WARN() {
  LOGGER ${LOG_WARNING} "$1"
}

# log script starting / ending ...
function LOGGER_INFO() {
  LOGGER ${LOG_INFO} "$1"
}

# log function messages, progress update
function LOGGER_DEBUG() {
  LOGGER ${LOG_DEBUG} "$1"
}

# verbose logging such as variable contents...
function LOGGER_TRACE() {
  LOGGER ${LOG_TRACE} "$1"
}
