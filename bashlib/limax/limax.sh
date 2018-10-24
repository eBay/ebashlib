#!/usr/bin/env bash 

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# Acknowledgement for idea:
# https://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
# ------------------------------------------------------
# https://stackoverflow.com/a/1116890
# Keith Smith, https://stackoverflow.com/users/12347/keith-smith

# Ties together functionality that works with bash commands on both linux and mac OS.

# header guardian 
[[ -z ${BASH_LIMAX_HEADER+x} ]] && BASH_LIMAX_HEADER="LOADED" || return 0

source $( dirname ${BASH_SOURCE} )/../logging/logging.sh

# maximum number of symlinks to follow, in order to avoid circular cycles
declare -i LIMAX_MAX_FOLLOW_SYMLINKS=20

# defining return codes. Note that bash scripts executed with the -e option will
# stop when return code is not zero
declare -i LIMAX_RETURN_OK=0
declare -i LIMAX_RETURN_FILE_NOT_FOUND=1
declare -i LIMAX_RETURN_DIR_ERROR=2
declare -i LIMAX_RETURN_MAX_SYMLINKS=3
declare -i LIMAX_RETURN_MKTEMP_FAIL=1

# function to find the canonical path of a file or directory
#
# behaviour is intended to be like `readlink -f` which works on linux but not on macOS
# 
# @param targetFile file or directory that we want to know the canonical path to
function LIMAX_READLINK() {
  local targetFile=$1
  # here, we preserve the (logical) directory we are currently
  # residing in
  local currentPath=$( pwd -L )

  # only follow symlinks to a maximum depth of X
  circularLinkProtection=${LIMAX_MAX_FOLLOW_SYMLINKS}

  # is the file we are looking at a directory?
  if [ -d "${targetFile}" ]; then
      cd "${targetFile}" 2> /dev/null

      if [ "$?" -ne 0 ]; then
          LOGGER_ERROR "could not enter directory $targetFile (permissions ok?)"
          cd "${currentPath}"
          return ${LIMAX_RETURN_DIR_ERROR} 
      fi

      # pwd -P returns the physical directory (default: logic)
      physicalDirectory=$( pwd -P )
      echo "${physicalDirectory}"
      cd "${currentPath}"
      return ${LIMAX_RETURN_OK}
  else
      # not a directory but an actual file, so we try to follow the symlinks (if any)

      # we enter this loop at least once (where we enter the directory of the file
      # and determine its basename
      #
      # then, we stay in the loop as long as the file is still a link 
      # (-L returns true if file exists and is a symbolic link)
      # but break if we reach an upper limit of sym link depth
      while [ ${circularLinkProtection} -eq ${LIMAX_MAX_FOLLOW_SYMLINKS} ] || \
            [ -L "${targetFile}" ] && [ ${circularLinkProtection} -gt 0 ]; do

          # only read link after first run
          [ ${circularLinkProtection} -eq ${LIMAX_MAX_FOLLOW_SYMLINKS} ] || targetFile=$( readlink "$targetFile" )

          let 'circularLinkProtection = circularLinkProtection - 1'

          targetDir=$( dirname "${targetFile}" )
          targetFile=$( basename "${targetFile}" )

          # NB: -d to check whether a directory exists behaves differently on mac and linux bash when one of 
          # the dirs is symbolic. 
          # e.g., let symlinkdir point to . (ln -s . symlinkdir) 
          # then, linux accepts that symlinkdir/../symlinkdir is a directory, mac does not
          # since "cd" can handle both cases, we take a brute-force approach here and ask questions later
          # (possible issues: dead link of dir, permission denied for execution, ...?)
          cd "${targetDir}" 2> /dev/null
          if [ "$?" -ne 0 ]; then
              LOGGER_ERROR "could not change to directory $targetDir (dead link? permission issue?)"
              cd "${currentPath}"
              return ${LIMAX_RETURN_DIR_ERROR} 
          fi
      done

      # error handling

      # first, we check for circular links, as -e below will also fail on dead links, making
      # it harder to provide meaningful error messages
      if [ "${circularLinkProtection}" -eq 0 ]; then
          LOGGER_ERROR "could not resolve ${targetFile} in dir ${targetDir} - symlink depth higher than ${LIMAX_MAX_FOLLOW_SYMLINKS} (circular links?)"
          cd "${currentPath}"
          return ${LIMAX_RETURN_MAX_SYMLINKS}
      fi

      # we arrived at the final directory
      physicalDirectory=$( pwd -P )
      echo "${physicalDirectory}/${targetFile}"
      cd "${currentPath}"

      # final check whether the file itself is already there. There might be use cases where this is
      # not given (e.g., for yet-to-be-filled log files), but at least we want to return a 
      # different value then so that our clients can differentiate between these cases.
      if [ ! -e "${targetFile}" ]; then
          return ${LIMAX_RETURN_FILE_NOT_FOUND}
      else
          return ${LIMAX_RETURN_OK}
      fi
  fi
}

# function to create a temp directory
#
# @param template prefix of the temp folder
# @note uses mktemp to create dir, so that $TMPDIR variable should work
function LIMAX_MKTEMPDIR() {
    local template=${1:-"tmp"}
    
    # check whether user assumed "normal" mktemp functionality, with options such as -p ...
    optionRegex="^[ ]*-"
    if [[ "$template" =~ $optionRegex ]]; then
        LOGGER_ERROR "no options supported for template"
        return ${LIMAX_RETURN_MKTEMP_FAIL}
    fi

    # macOS' and linux' mktemp differ in their usage of templates
    # linux expects a template whereas mac does not
    # fall-back solution:
    # mktemp -d "${TMPDIR:-/tmp}/zombie.XXXXXXXXX"
    local tmpDir=$( mktemp -d -t "${template}" 2>/dev/null || mktemp -d -t "${template}.XXXXXX" )
    if [ $? -ne 0 ]; then
        return ${LIMAX_RETURN_MKTEMP_FAIL}
    else
        echo "${tmpDir}"
        return ${LIMAX_RETURN_OK}
    fi
}
