#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# simple example script to show the git label functionality

SCRIPTDIR="$( dirname $0 )"

source "${SCRIPTDIR}/../bashlib/bashlib.sh"

# supress debug output of gitlabel for this example
LOGGER_SET_LOG_LEVEL ${LOG_INFO}

LOGGER_INFO "ebashlib has the mission statement:

  $( GITLABEL_GET_README_DESCRIPTION "${SCRIPTDIR}" )
"

upstream="$( GITLABEL_GET_UPSTREAM_URL "${SCRIPTDIR}" )"
if [[ "$?" == "${GITLABEL_OK}" ]]; then
    LOGGER_INFO "The upstream URL for this local branch is ${upstream}"
else
    LOGGER_INFO "Your local branch is not connected to an upstream URL"
fi

LOGGER_INFO "Trying to look for a tag: $( GITLABEL_GET_TAG "${SCRIPTDIR}" )"

uncommitedChanges="$( GITLABEL_CHECK_UNCOMMITED_CHANGES "${SCRIPTDIR}" )"
if [[ "$?" == "${GITLABEL_OK}" ]]; then
    LOGGER_INFO "No uncommited changes detected (but maybe untracked changes?)"
else
    LOGGER_INFO "Uh oh, you have a couple of uncommited changes: 
    
    ${uncommitedChanges}
    
    ... maybe even untracked changes?
    
    $( GITLABEL_CHECK_UNCOMMITED_CHANGES "${SCRIPTDIR}" strict )"
fi

LOGGER_INFO "Current commit: $( GITLABEL_COMMIT "${SCRIPTDIR}" )"
LOGGER_INFO "I would label this repo as $( GITLABEL_SUGGEST_IMAGE_TAG "${SCRIPTDIR}" )"

LOGGER_INFO "One more thing. By default, the commands in this tool look into
your current directory, but with some tweaking you can also start them from
somewhere else or into submodules etc.. Execute this script from the directory
of another repo and obtain a different label for GITLABEL_GET_TAG: 
$( GITLABEL_SUGGEST_IMAGE_TAG )"
