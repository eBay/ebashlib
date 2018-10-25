#!/bin/bash 

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# script to unit-test linux/mac functions for limax lib

source $(dirname ${BASH_SOURCE})/../bashlib/bashlib.sh

LOGGER_SET_LOG_LEVEL ${LOG_QUIET}

# creating various test files in a temp dir
function UT_setUp() {
    invocationDir=$( pwd -P )
    currentTempDir="$( LIMAX_MKTEMPDIR "tempDir" )"
    canonicalTempDirPath=$( cd "${currentTempDir}" && pwd -P || echo "ERROR" )
    touch "${currentTempDir}/someFile"
    ln -s someFile "${currentTempDir}/linkToSomeFile"
    ln -s badLink "${currentTempDir}/linkToNowhere"
    ln -s someFile "${currentTempDir}/link with blanks"
    ln -s "${currentTempDir}" "${currentTempDir}/tmp"
    ln -s tmp "${currentTempDir}/tmptwo"
    ln -s tmp "${currentTempDir}/tmp dir with blanks"
    ln -s tmp/tmp/../someFile "${currentTempDir}/labyrink"
    ln -s tmp/../tmp/../someFile "${currentTempDir}/labyrink2"

    # for testing abort on circular links
    ln -s circular.ying "${currentTempDir}/circular.yang"
    ln -s circular.yang "${currentTempDir}/circular.ying"

    # for testing abort on dirs with missing permissions
    mkdir -p "${currentTempDir}/permissionDenied"
    ln -s permissionDenied "${currentTempDir}/linkPermissionDenied"
    ln -s "${currentTempDir}/someFile" "${currentTempDir}/permissionDenied/linkToSomeFile"
    chmod 600 "${currentTempDir}/permissionDenied"
}

# removing test files
function UT_tearDown() {
    rm -f "${currentTempDir}/"{someFile,linkToSomeFile,linkToNowhere,tmp,tmptwo,labyrink,labyrink2,circular.ying,circular.yang}
    rm -f "${currentTempDir}/"{link\ with\ blanks,tmp\ dir\ with\ blanks}
    chmod 700 "${currentTempDir}/permissionDenied"
    rm -f "${currentTempDir}/permissionDenied/linkToSomeFile"
    rm -f "${currentTempDir}/linkPermissionDenied"
    rmdir "${currentTempDir}/permissionDenied"
    rmdir "${currentTempDir}"
}

# test whether we successfully catch a bad template entry
function UT_testNoOptionTempDir() {
    returnCode=0
    LIMAX_MKTEMPDIR "-t" || returnCode=$?
    UT_ASSERT_EQUAL "limax is not mktemp" "${returnCode}" "${LIMAX_RETURN_MKTEMP_FAIL}"

    returnCode=0
    LIMAX_MKTEMPDIR "-p using some options" || returnCode=$?
    UT_ASSERT_EQUAL "limax is really not mktemp" "${returnCode}" "${LIMAX_RETURN_MKTEMP_FAIL}"
}

# since the main functionality uses vanilla readlink which only resolves on link at a time,
# we might run into circular links. this test ensures that the function aborts properly
function UT_testCircularLinkError() {
    returnCode=0
    LIMAX_READLINK ${currentTempDir}/circular.ying || returnCode=$?
    UT_ASSERT_EQUAL "circular links cannot be resolved" "${returnCode}" "${LIMAX_RETURN_MAX_SYMLINKS}"
    UT_ASSERT_EQUAL "returned to original dir after circ link error" "$( pwd -P)" "${invocationDir}"
}

# testing behaviour on finding/not finding files
function UT_testSymFile() {
    UT_ASSERT_EQUAL "find file with canonical path" "$( LIMAX_READLINK "${currentTempDir}/someFile" )" "$canonicalTempDirPath/someFile"
    UT_ASSERT_EQUAL "find linked file" "$( LIMAX_READLINK "${currentTempDir}/linkToSomeFile" )" "$canonicalTempDirPath/someFile"
    # tmp/tmp/../
    UT_ASSERT_EQUAL "find linked file with weird linked dir" "$( LIMAX_READLINK "${currentTempDir}/labyrink" )" "$canonicalTempDirPath/someFile"
    # tmp/../tmp/.. 
    UT_ASSERT_EQUAL "find linked file with another weird linked dir" "$( LIMAX_READLINK "${currentTempDir}/labyrink2" )" "$canonicalTempDirPath/someFile"
    UT_ASSERT_EQUAL "find linked file with blank link" "$( LIMAX_READLINK "${currentTempDir}/link with blanks" )" "$canonicalTempDirPath/someFile"
    UT_ASSERT_EQUAL "returned to original dir after finding files" "$( pwd -P)" "${invocationDir}"

    returnCode=0
    LIMAX_READLINK ${currentTempDir}/linkToNowhere || returnCode=$?
    UT_ASSERT_EQUAL "successfully not finding a file" "${returnCode}" "${LIMAX_RETURN_FILE_NOT_FOUND}"
    UT_ASSERT_EQUAL "returned to original dir after file not found" "$( pwd -P)" "${invocationDir}"

    returnCode=0
    LIMAX_READLINK ${currentTempDir}/linkPermissionDenied/linkToSomeFile || returnCode=$?
    UT_ASSERT_EQUAL "successful abort on unreachable file (behind barred dir)" "${returnCode}" "${LIMAX_RETURN_DIR_ERROR}"
    UT_ASSERT_EQUAL "returned to original dir after dir not accessible" "$( pwd -P)" "${invocationDir}"
}

# this function tests the resolvance of several symbolic links to directories
#
# since the temp Dir we have created can theoretically be symbolic as well (e.g.,
# MacOS likes to store temp dirs in /var which is actually /private/var), 
# comparison is a bit problematic here since 
# - we do not know in advance how the directory will be named
# - how its canonical path will look like
function UT_testSymDir() {
    UT_ASSERT_EQUAL "resolving temp dir to actual path" "$( LIMAX_READLINK ${currentTempDir} )" "$canonicalTempDirPath"
    UT_ASSERT_EQUAL "resolving symbolic directory links" "$( LIMAX_READLINK ${currentTempDir}/tmp )" "$canonicalTempDirPath"
    UT_ASSERT_EQUAL "resolving symbolic directory link cascade" "$( LIMAX_READLINK ${currentTempDir}/tmptwo )" "$canonicalTempDirPath"
    UT_ASSERT_EQUAL "resolving symbolic directory with blanks" "$( LIMAX_READLINK "${currentTempDir}/tmp dir with blanks" )" "$canonicalTempDirPath"
    returnCode=0
    LIMAX_READLINK ${currentTempDir}/linkToNowhere/find.me || returnCode=$?
    UT_ASSERT_EQUAL "successfully not finding a dir" "${returnCode}" "${LIMAX_RETURN_DIR_ERROR}"
    UT_ASSERT_EQUAL "returned to original dir after dir not found" "$( pwd -P)" "${invocationDir}"

    returnCode=0
    LIMAX_READLINK ${currentTempDir}/permissionDenied || returnCode=$?
    UT_ASSERT_EQUAL "successful abort on permission issue" "${returnCode}" "${LIMAX_RETURN_DIR_ERROR}"
    UT_ASSERT_EQUAL "returned to original dir after dir not accessible" "$( pwd -P)" "${invocationDir}"

    returnCode=0
    LIMAX_READLINK ${currentTempDir}/linkPermissionDenied || returnCode=$?
    UT_ASSERT_EQUAL "successful abort on (linked) permission issue" "${returnCode}" "${LIMAX_RETURN_DIR_ERROR}"
    UT_ASSERT_EQUAL "returned to original dir after dir not accessible" "$( pwd -P)" "${invocationDir}"
}

UT_RUN_TEST_SUITE "Limax test"
