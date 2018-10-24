#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# main file gathering all subtools in this directory
# 
# to use it, simply type 
#   source <thisRepoFolder>/bashlib/bashlib.sh 
# into your own bash script

# first check that we are in bash mode. Remember, if
# a bash script is invoked by, e.g., sh, this will
# overwrite the #! shell
[[ "${BASH_SOURCE}" == "" ]] && echo "very old bash or script invoked with different shell. Aborting." && exit 2

# this script is probably called from somewhere else, so we cannot
# rely on $0 to contain the path to this folder
MY_BASEDIR="$( dirname ${BASH_SOURCE} )"

# shellOptions is included as a submodule and might need to be initialized once
[[ ! -f "${MY_BASEDIR}/shellOptions/options.bash" ]] && git -C "${MY_BASEDIR}" submodule update --init

source "${MY_BASEDIR}/termColorFont/termColorFont.sh"
source "${MY_BASEDIR}/logging/logging.sh"
source "${MY_BASEDIR}/report/report.sh"
source "${MY_BASEDIR}/fileSanity/fileSanity.sh"
source "${MY_BASEDIR}/limax/limax.sh"
source "${MY_BASEDIR}/shellOptions/options.bash"
source "${MY_BASEDIR}/regressionTest/regressionTest.sh"
source "${MY_BASEDIR}/unitTest/unitTest.sh"
source "${MY_BASEDIR}/dryrun/dryrun.sh"
source "${MY_BASEDIR}/gitLabel/gitLabel.sh"
