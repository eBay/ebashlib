#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Gregor Leusch, Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# test script for fileSanity lib

source $(dirname ${BASH_SOURCE})/../bashlib/bashlib.sh

LOGGER_SET_LOG_LEVEL ${LOG_QUIET}

##################################################
## Helper functions
##################################################

# function to create directory with some test files:
# somefile             one line
# someexecutable       one line executable bash script without output
# someexecutablewithoutput  four lines executable bash script with three lines of output
# filewithfourlines         four lines non-executable
# @RETURN name of temp directory
function createTestDirectory() {
  LOGGER ${LOG_DEBUG} "Creating temp directory"
  local _tdir=$(mktemp -d -t unittest.XXXXXXXX)
  echo SOMETHING > ${_tdir}/somefile
  echo '#!/bin/bash' > ${_tdir}/someexecutable
  echo '#!/bin/bash' > ${_tdir}/someexecutablewithoutput
  echo 'echo YES'   >> ${_tdir}/someexecutablewithoutput
  echo 'echo YES'   >> ${_tdir}/someexecutablewithoutput
  echo 'echo YES'   >> ${_tdir}/someexecutablewithoutput

  for i in {1..4}; do
     echo "LALA" >> ${_tdir}/filewithfourlines
  done

  chmod u+x ${_tdir}/someexecutable ${_tdir}/someexecutablewithoutput
  echo ${_tdir}
}

# Function to remove previously created test files and directory
# @PARAM tdir  Test directory to remove
function removeTestDirectory() {
  local _tdir=$1
  LOGGER ${LOG_DEBUG} "Removing temp directory"
  rm -f ${_tdir}/{somefile,someexecutable,someexecutablewithoutput,filewithfourlines}
  rmdir ${_tdir}
} 


# Private function to run a single test
function _run_test_checkFile() {
  local _fn=$1         ; # Filename
  local _resExists=$2  ; # Expected result for 'exists'
  local _resExec=$3   ; # Expected result for 'executable'
  local _resRuns3=$4  ; # Expected result for 'runs 3'
  local _resRuns4=$5  ; # Expected result for 'runs 4'
  
  local _bfn=$(basename ${_fn})

  r=$(checkFile exists ${_fn})
  errno=$?
  UT_ASSERT_EQUAL "${_bfn} exists" $errno ${_resExists}

  r=$(checkFile executable ${_fn} "")
  errno=$?
  UT_ASSERT_EQUAL "${_bfn} executable" $errno ${_resExec}

  r=$(checkFile runs ${_fn} "" 3)
  errno=$?
  UT_ASSERT_EQUAL "${_bfn} runs 3" $errno ${_resRuns3}

  r=$(checkFile runs ${_fn} "" 4)
  errno=$?
  UT_ASSERT_EQUAL "${_bfn} runs 4" $errno ${_resRuns4}
}

##################################################
## Unit Test 
##################################################

# Unit test testing whether checkFile returns the expected value
# for files that do or do not exists, are executable or not, return a certain number of lines
function test_checkFile() {
  local _tdir=$(createTestDirectory)

  _run_test_checkFile ${_tdir}/doesnotexist 2 2 2 2 
  _run_test_checkFile ${_tdir}/somefile 0 2 2 2 
  _run_test_checkFile ${_tdir}/someexecutable 0 0 2 2 
  _run_test_checkFile ${_tdir}/someexecutablewithoutput 0 0 0 2 
  
  removeTestDirectory ${_tdir}
}

# Unit test testing whether assertEqualNumberOfLinen returns the expected value
# on files existing or not, with certain number of lines
function test_assertEqualNumberOfLines() {
  local _tdir=$(createTestDirectory)
  
  r=$(assertEqualNumberOfLines "UT_test_assertEqualNumberOfLines" ${_tdir}/filewithfourlines ${_tdir}/someexecutablewithoutput)
  errno=$?
  UT_ASSERT_EQUAL "four lines" $errno 0

  r=$(assertEqualNumberOfLines "UT_test_assertEqualNumberOfLines" ${_tdir}/filewithfourlines ${_tdir}/someexecutable)
  errno=$?
  UT_ASSERT_EQUAL "one line" $errno 2

  r=$(assertEqualNumberOfLines "UT_test_assertEqualNumberOfLines" ${_tdir}/filewithfourlines ${_tdir}/doesnotexist)
  errno=$?
  UT_ASSERT_EQUAL "does not exist" $errno 2

  r=$(assertEqualNumberOfLines "UT_test_assertEqualNumberOfLines" ${_tdir}/doesnotexist ${_tdir}/filewithfourlines)
  errno=$?
  UT_ASSERT_EQUAL "ref does not exist" $errno 2

  removeTestDirectory ${_tdir}
}




##################################################
## Main
##################################################

test_checkFile
test_assertEqualNumberOfLines
