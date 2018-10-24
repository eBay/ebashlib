#!/bin/bash 

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# example scripts demonstrating some mac/linux compatible functions

source $(dirname $0)/../bashlib/bashlib.sh

LOGGER_BLOCK "Readlink demonstration"

LOGGER_INFO "First, let's determine the canonical path this script resides in"
LIMAX_READLINK "$( dirname ${BASH_SOURCE} )"
exampleDir="$( LIMAX_READLINK "$( dirname $0 )" )"

LOGGER_INFO "Searching for file 'find.me' in 'files' subdir"
LIMAX_READLINK "${exampleDir}/files/find.me"

LOGGER_INFO "full path, partial path... not much of a difference"
LIMAX_READLINK "${exampleDir}/files/../files/find.me"

LOGGER_INFO "symbolically linking find.me to nextdoor.me (provoking error in next line)"
ln -f -s files/find.me "${exampleDir}/files/nextdoor.me"
LIMAX_READLINK "${exampleDir}/files/nextdoor.me"

LOGGER_INFO "Oh, we made a mistake... trying again"
ln -f -s find.me "${exampleDir}/files/nextdoor.me"
LIMAX_READLINK "${exampleDir}/files/nextdoor.me"

myTempDir=$( LIMAX_MKTEMPDIR "tempSub" )
LOGGER_INFO "linking it from a subdirectory ${myTempDir}"
ln -f -s "${exampleDir}/files/nextdoor.me" "${myTempDir}/temporarilyAway.me"
LIMAX_READLINK "${myTempDir}/temporarilyAway.me"

LOGGER_INFO "One more thing... if the file is not found but the directory can be entered,
you still obtain the canonical path, but the return value differs"
LIMAX_READLINK "${exampleDir}/lalala"
if [[ "$?" == "${LIMAX_RETURN_FILE_NOT_FOUND}" ]]; then
    LOGGER_INFO "... so that you can distinguish these cases"
fi

LOGGER_INFO "Note that, given this result value, your script will abort if you invoke it with the -e option.
If this is not what you want, consider using '|| true' to your command to ensure it always succeeds"

