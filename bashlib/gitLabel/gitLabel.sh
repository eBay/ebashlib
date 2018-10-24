#!/usr/bin/env bash 

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# various functions to help properly identify/label a git repository

# header guardian 
[[ -z ${BASH_GITLABEL_HEADER+x} ]] && BASH_GITLABEL_HEADER="LOADED" || return 0

### return values
# Note that for client bash scripts with -e option, anything else than 0 will cause an abort
# if this is undesired, consider `|| true`

# everything worked, git successful
declare -i -x GITLABEL_OK=0

# everything worked, but pattern could not be found/verified (e.g., asking for a tag on untagged version)
declare -i -x GITLABEL_FAIL=1

# default value to abort on
declare -i -x GITLABEL_ERROR=2

# obtain paragraph from readme text file
#
# a paragraph is assumed to be enclosed by two consecutive line breaks
# by default, attempts to find second paragraph in README.md (assumed to be the description)
#
# :param directory: a directory within a git repository (defaults to .)
# :param paragraph: which paragraph contains the description (defaults to 2)
# :param filename: name of the central readme file (defaults to README.md)
function GITLABEL_GET_README_DESCRIPTION() {
  local directory=${1:-"."}
  local paragraph=${2:-2}
  local filename=${3:-"README.md"}

  # first, we want to identify the absolute path of the top level of that git dir
  topLevelDir="$( git -C "${directory}" rev-parse --show-toplevel )"

    # remove blanks in otherwise empty lines  
    sed 's/^[ ]*$//g' "${topLevelDir}/${filename}" | \
    awk -v paragraph=${paragraph} '
        BEGIN { 
          # use two consecutive line breaks as separator
          RS='\n\n';
          # output separator. default is already blank, but just to make sure
          ORS=""; 
        } 
        (NR==paragraph)' | \
    # convert line breaks to blanks        
    tr '\n' ' ' 
  return "${GITLABEL_OK}"
}

# attempt to determine git upstream repository url
#
# does not work in detached state
#
# :param directory: a directory within a git repository (defaults to .)
# :returns: upstream URL if successful, "" else
function GITLABEL_GET_UPSTREAM_URL () {
  local directory=${1:-"."}
  # first, we need to find out which remote repo/branch we are connected to
  GIT_REMOTE_BRANCH="$( git -C "${directory}" rev-parse --abbrev-ref --symbolic-full-name @{u} 2> /dev/null )"
  if [[ "$?" -ne "0" ]]; then
    LOGGER_DEBUG "git rev-parse failed, probably because in detached commit"
    return "${GITLABEL_FAIL}"
  fi
  LOGGER_DEBUG "detected git upstream ${GIT_REMOTE_BRANCH}"
  # now, just get the name of the remote fork
  GIT_REMOTE="$( echo ${GIT_REMOTE_BRANCH} | sed 's#^\([^/]*\).*#\1#g' )"
  GIT_REMOTE_URL="$( git -C "${directory}" remote show ${GIT_REMOTE} | grep "Fetch URL" | sed 's/^[^@]*@//g;s#:#/#g' )"

  echo "${GIT_REMOTE_URL}"
  return "${GITLABEL_OK}"
}

# check whether our current git commit matches a tag
#
# :param directory: a directory within a git repository (defaults to .)
# :returns: tag name/GITLABEL_OK if found, "untagged"/GITLABEL_FAIL else
function GITLABEL_GET_TAG() {
    local directory=${1:-"."}
    GIT_TAG="$( git -C "${directory}" describe --exact-match --tags HEAD 2> /dev/null )"
    if [[ "$?" -ne "0" ]]; then
        LOGGER_DEBUG "Could not detect a repository tag attached to current commit."
        echo "untagged"
        return "${GITLABEL_FAIL}"
    fi
    echo ${GIT_TAG}
    return "${GITLABEL_OK}"
}

# checks whether files known to the git index contain uncommited (and maybe untracked) changes
#
# of interest are:
#   M updated in index
#   A added to index
#   D deleted from index
#   R renamed in index
#   C copied in index
#
# the following might be ignored by the option
#   ? untracked
# the following will be ignored (duh!)
#   ! ignored
#
# :param directory: a directory within a git repository (defaults to .)
# :param untracked: if "strict", also throw error on untracked files
# :returns: GITLABEL_OK if no uncommited changes, list of changes/GITLABEL_FAIL else
function GITLABEL_CHECK_UNCOMMITED_CHANGES() {
    local directory=${1:-"."}
    local untracked=${2:-"pass"}
    
    # invoke status 
    # porcelain option guarantees output format, in case user has specific settings
    gitStatus="$( git -C "${directory}" status --porcelain 2> /dev/null )"
    [[ "$?" -ne "0" ]] && return "${GITLABEL_ERROR}"
    if [[ "${untracked}" == "strict" ]]; then
        # only allow for ignored files
        gitUncommitedChanges="$( grep -v -e "^!" -e "^[ ]*$" <<< "${gitStatus}" )"
    else 
        # also allow untracked files
        gitUncommitedChanges="$( grep -v -e "^?" -e "^!" -e "^[ ]*$" <<< "${gitStatus}" )"
    fi
    if [[ "${gitUncommitedChanges}" == "" ]]; then
        return "${GITLABEL_OK}"
    else
        echo "${gitUncommitedChanges}"
        return "${GITLABEL_FAIL}"
    fi
}

# make a suggestion for a tag name of the current repo status
#
# the logic is:
#  * if there is a git tag on the main submodule commit (even if upstream), 
#    AND 
#    if there are no uncommited changes, it will use
#      this git tag (thus assuming it is a release)
#  * if the current commit is untagged, the script looks for a `VERSION` file and
#    assumes that the first token in this file marks the version number. The script
#    further assumes that this is only a snapshot and names the tag
#    "<version>-snapshot" 
#  * if neither tag nor version could be found, the user is on his/her own. The tag is called
#    "dev"
# :param directory: a directory within a git repository (defaults to .)
# :returns: tag name suggestion/GITLABEL_OK or dev/GITLABEL_FAIL
function GITLABEL_SUGGEST_IMAGE_TAG() {
    local directory=${1:-"."}
    suggestedTag="dev"
    # check whether our current status is also tagged
    gitTag="$( GITLABEL_GET_TAG "${directory}" )"
    if [[ "$?" == "${GITLABEL_OK}" ]]; then
        # ok, there is a tag. But is our current status clean? 
        # (NOTE) not checking for untracked files here... 
        gitChanges="$( GITLABEL_CHECK_UNCOMMITED_CHANGES "${directory}" )"
        if [[ "$?" == "${GITLABEL_OK}" ]]; then
            echo "${gitTag}" && return ${GITLABEL_OK}
        else
            LOGGER_WARNING "Not using current git tag ${gitTag} because of uncommited changes"
        fi
    fi

    # no tag... ok. Maybe there is a VERSION file at the top level path?
    topLevelDir="$( git -C "${directory}" rev-parse --show-toplevel )"
    versionFile="${topLevelDir}/VERSION"

    # is there a file that tells us which version we are looking at
    if [ -f "${versionFile}" ]; then
        assumedVersion="$( head -n 1 "${versionFile}" | awk '{print $1}' )"
        suggestedTag="${assumedVersion}-snapshot"
        LOGGER_DEBUG "Using version info in file ${versionFile}. Suggesting ${suggestedTag}"
        echo "${suggestedTag}" && return ${GITLABEL_OK}
    fi

    LOGGER_DEBUG "Unable to detect meaningful name... setting to default: ${suggestedTag}"
    echo "${suggestedTag}" && return ${GITLABEL_FAIL}
}

# get current commit hash (but warn on uncommited changes)
#
# :param directory: a directory within a git repository (defaults to .)
# :returns: tag name suggestion/GITLABEL_OK or dev/GITLABEL_FAIL
function GITLABEL_COMMIT() {
    local directory=${1:-"."}
    
    gitCommit="$( git -C "${directory}" rev-parse HEAD )"
    gitChanges="$( GITLABEL_CHECK_UNCOMMITED_CHANGES "${directory}" )"
    if [[ "$?" != "${GITLABEL_OK}" ]]; then
        LOGGER_WARNING "Current repository contains uncommited changes, commit is corrupted:

        ${gitChanges}
" 
        echo "${gitCommit}" && return ${GITLABEL_FAIL}
    else
        echo "${gitCommit}" && return ${GITLABEL_OK}
    fi
}
