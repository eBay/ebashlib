#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# simple example script for unit testing

source $(dirname $0)/../bashlib/bashlib.sh

SUM=0
let "SUM = 2 + 2"

# you can call assertions directly
UT_ASSERT_EQUAL "Two plus two is five" "${SUM}" "5"
UT_ASSERT_EQUAL "This time 4 real"     "${SUM}" "4"

# or you can use a 
######### TEST SUITE ##########

# the setUp function *must* be called like this
function UT_setUp() {
  # make mktemp work both for old MacOS and Linux. On Mac, the first command will fail because a template is required
  currentTempDirectory="$( mktemp -d 2>/dev/null || mktemp -d -t 'tmp')"
  echo "4" > "${currentTempDirectory}/result.txt"
}

# the tearDown function *must* be called like this
function UT_tearDown() {
  rm -f "${currentTempDirectory}/result.txt"
  rm -d "${currentTempDirectory}"
}

# a valid function is named UT_test[a-zA-Z0-9_]*
function UT_test1337Arithmetics() {
  currentSum=$(cat "${currentTempDirectory}/result.txt" )
  UT_ASSERT_EQUAL "reading four is high five" "${currentSum}" "5"
  # that was exhausting... go to sleep so that we at least see 1 second in the time summary
  sleep 1
}

UT_RUN_TEST_SUITE "1337 Arithmetics"
