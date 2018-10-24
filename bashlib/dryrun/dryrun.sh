#!/usr/bin/env bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# functionality to either execute or echo command in dryrun

# header guardian 
[[ -z ${BASH_DRYRUN_HEADER+x} ]] && BASH_DRYRUN_HEADER="LOADED" || return 0

DRYRUN=""

# setter for dryrun mode
function DRYRUN_SET_DRYRUN(){
  DRYRUN="true"
}

# unsetter for dryrun mode
function DRYRUN_UNSET_DRYRUN(){
  DRYRUN="false"
}

# private function to flush anything still residing in stdin
function __DRYRUN_FLUSH_STDIN(){
  # is stdin attached to our pipe? then output it
  if [[ -p /dev/stdin ]]; then
     cat /dev/stdin
  fi
}

# write STDIN to a file (default) or stdout (if DRYRUN is true)
#
# @param myFile file to write to (default: stdout)
function DRYRUN_WRITE_TO_FILE(){
  local myFile=${1:-/dev/stdout}
  if [[ "${DRYRUN}" == "true" ]]; then
      __DRYRUN_FLUSH_STDIN
      echo "> ${myFile}"
  else
      cat - > ${myFile}
  fi
}

# append STDIN to a file (default) or stdout (if DRYRUN is true)
#
# @param myFile file to write to (default: stdout)
function DRYRUN_APPEND_TO_FILE(){
  local myFile=${1:-/dev/stdout}
  if [[ "${DRYRUN}" == "true" ]]; then
      __DRYRUN_FLUSH_STDIN
      echo ">> ${myFile}"
  else
      cat - >> ${myFile}
  fi
}

# function to execute or echo command, based on DRYRUN variable 
#
# if DRYRUN is anything else than "true", it will execute as before.
# otherwise, it will print the parameters. 
#
# @param [command] a bash command with potential options
# 
# @note: restoring quotes is not as trivial though because bash already removes
# all quotes before passing them to this function. We try to restore them as
# much as possible, assuming that all args containing blanks should be quoted
function DRYRUN_EXEC(){
  if [[ "${DRYRUN}" == "true" ]]; then
    local output=""
    for current_arg in "$@" ; do
        grep -q "[[:space:]]" <<< "${current_arg}" \
            && output="${output} \"${current_arg}\"" \
            || output="${output} ${current_arg}"
    done
    __DRYRUN_FLUSH_STDIN
    # is stdout attached to a pipe?
    if [[ -p /dev/stdout ]]; then
       output="${output} |"
       # remove first space. add \ to all lines
       sed -e 's/^ //;s/$/ \\/;' <<< "${output}" 

    # are we writing to a file?   
    elif [[ ! -t 1 ]]; then
        # if so, we try to determine the file name currently
        # attached to our PID, stored in bash's $$, by asking lsof
        # -p include PID -a AND -d include FD with -f output format n name
        mostProbableFilename="$( lsof -p $$ -a -d 1 -Fn | sed -n '$ s/^.// p' )"
        echo "DRYRUN mode. Writing command to $mostProbableFilename" >&2
        sed -e 's/^ //;$ ! s/$/ \\/;' <<< "${output}" 

    # it seems that we neither write into a pipe nor into a file    
    else
       # remove first space and print. add \ to all lines except the last
       sed -e 's/^ //;$ ! s/$/ \\/;' <<< "${output}" 
    fi
  else 
    # no dryrun. simply execute
    "$@"
  fi
}
