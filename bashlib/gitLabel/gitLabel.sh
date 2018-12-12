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

    if GITLABEL_CHECK_UNCOMMITED_CHANGES "${directory}" > /dev/null
    then
        GIT_TAG="$( git -C "${directory}" describe --exact-match --tags HEAD 2> /dev/null )"
        if [[ "$?" -ne "0" ]]; then
            LOGGER_DEBUG "Could not detect a repository tag attached to current commit."
            echo -n "untagged"
            return "${GITLABEL_FAIL}"
        fi
    else
        LOGGER_DEBUG "Branch contains uncommitted files."
        echo -n "untagged"
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

# Make a suggestion for a tag name of the current repo status
#
#  * If there are uncommitted files in the repo         --> "dev"  (and fail)
#  * If this is a tagged version                        --> "<tagname>"
#  * If there is a file called VERSION in the repo root --> "<VERSION>-<commit>"
#  * Else, if we have a branch name                     --> "<BRANCHNAME>-<commit>"
#  * (If everything fails                               --> "dev" (and fail)
#  
#  Here, "<commit>" is the short commit ID (e.g. '1cae95e'). If you pass 
#  a different name as second parameter, e.g. `snapshot`, this will use that
#  parameter instead of the commit.
# 
#  E.g. `GITLABEL_SUGGEST_IMAGE_TAG .` --> 'master-1cae95e',
#       `GITLABEL_SUGGEST_IMAGE_TAG . snapshot` --> 'master-snapshot'
#
# :param directory: a directory within a git repository (defaults to .)
# :param [snapshot]: a suffix to be used instead of the git commit, e.g. 'snapshot'
# :returns: tag name suggestion/GITLABEL_OK or dev/GITLABEL_FAIL

function GITLABEL_SUGGEST_IMAGE_TAG() {
    local directory=${1:-"."}
    local snapshot=${2}
    if [[ -z "${snapshot}" ]]
    then
        # Get label for snapshot from commit
        snapshot=$(git -C "${directory}" show --no-patch --pretty='format:%h')
    fi
     
    local suggestedTag="dev"


    # First check whether there are uncommitted changes --
    # in this case we always return suggestedTag
    
    gitChanges="$( GITLABEL_CHECK_UNCOMMITED_CHANGES "${directory}" )"
    if [[ "$?" != "${GITLABEL_OK}" ]]; then
        LOGGER_WARNING "Not using current git tag ${gitTag} because of uncommited changes"
        echo "${suggestedTag}" && return ${GITLABEL_FAIL}
    fi


    # check whether our current status is also tagged
    gitTag="$( GITLABEL_GET_TAG "${directory}" )"
    if [[ "$?" == "${GITLABEL_OK}" ]]; then
        (echo -n "${gitTag}" | _GITLABEL_FILTER_TAG)  && return ${GITLABEL_OK}
    fi

    # no tag... ok. Maybe there is a VERSION file at the top level path?
    topLevelDir="$( git -C "${directory}" rev-parse --show-toplevel )"
    versionFile="${topLevelDir}/VERSION"

    # is there a file that tells us which version we are looking at
    if [ -f "${versionFile}" ]; then
        assumedVersion="$( head -n 1 "${versionFile}" | awk '{print $1}' )"
        suggestedTag="${assumedVersion}-${snapshot}"
        LOGGER_DEBUG "Using version info in file ${versionFile}. Suggesting ${suggestedTag}"
        (echo -n "${suggestedTag}" | _GITLABEL_FILTER_TAG) && return ${GITLABEL_OK}
    fi

    # Otherwise, is there at least a Branch name we can use?
    (echo -n "$(git -C "${directory}" rev-parse --abbrev-ref HEAD)-${snapshot}" |_GITLABEL_FILTER_TAG) && return ${GITLABEL_OK}

    LOGGER_DEBUG "Unable to detect meaningful name... setting to default: ${suggestedTag}"
    echo "${suggestedTag}" && return ${GITLABEL_FAIL}
}

# Remove illegal characters from tag
function _GITLABEL_FILTER_TAG() {
    sed -e 's/[^a-zA-Z0-9.-]//g' 
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
