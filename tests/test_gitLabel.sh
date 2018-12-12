#!/bin/bash 

# script to unit-test working with Git metadata and tags, 
# and suggesting labels

source $(dirname ${BASH_SOURCE})/../bashlib/bashlib.sh

LOGGER_SET_LOG_LEVEL ${LOG_QUIET}

function _GIT() {
  # Run git in currentTempDir
  cmd=$1
  shift
  git -C "${currentTempDir}" ${cmd} "$@"
}

# Helper function: 
# Run a test, check result and return 
function _ASSERT_STDOUT_RETURN_EQUAL() {
  DESCRIPTION="${1}"
  CMD="${2}"
  EXPECTED_STDOUT="${3}"
  EXPECTED_RETURN="${4}"
  actual_stdout=$(eval "${CMD}")
  actual_return=$?

  UT_ASSERT_EQUAL "${DESCRIPTION} (stdout)" "${actual_stdout}" "${EXPECTED_STDOUT}"
  UT_ASSERT_EQUAL "${DESCRIPTION} (return)" "${actual_return}" "${EXPECTED_RETURN}"
}


# creating various test files in a temp dir
function UT_setUp() {
    invocationDir=$( pwd -P )
    currentTempDir="$( LIMAX_MKTEMPDIR "gitLabelTestTempDir" )"
    _GIT init
    echo "This is a simple test for gitLabel" > ${currentTempDir}/README.txt
    _GIT add README.txt
    _GIT commit -m "Initial commit"
    _GIT tag initial
}

function _GIT_RESET() {
  _GIT checkout master
  _GIT reset --hard initial
}


# removing test files, as safe as possible
function UT_tearDown() {
  _GIT_RESET
  rm -rf "${currentTempDir}/.git"
  rm -f "${currentTempDir}/README.txt"
  rmdir "${currentTempDir}"
}

function UT_test_GET_TAG() {
  _GIT checkout master
  UT_ASSERT_EQUAL "get valid tag" "$(GITLABEL_GET_TAG ${currentTempDir})" "initial"
  # Now create a new branch and commit a new file
  _GIT checkout -b testBranch
  echo "A Test File" > ${currentTempDir}/test.txt
  _GIT add test.txt
  
  # Branch is not commited
  UT_ASSERT_EQUAL "uncommitted branch" "$(GITLABEL_GET_TAG ${currentTempDir} || echo -n "-failing" )" "untagged-failing"

  # Commit
  _GIT commit -m "Committing test"
  # Branch is commited
  UT_ASSERT_EQUAL "committed branch" "$(GITLABEL_GET_TAG ${currentTempDir} || echo -n "-failing" )" "untagged-failing"

  # Reset everything
  _GIT_RESET
  _GIT branch -D testBranch
}


# Helper: Replace short commit suffixes -abcdef0 by -XXXXXXX
function _REMOVE_SHORT_COMMIT() {
  sed -e 's/-[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$/-XXXXXXX/'
}

function UT_test_GITLABEL_SUGGEST_IMAGE_TAG() {
  _GIT checkout master

  _ASSERT_STDOUT_RETURN_EQUAL "Initial State" 'GITLABEL_SUGGEST_IMAGE_TAG ${currentTempDir}' "initial" "${GITLABEL_OK}"

  # Now create a new branch and commit a new file
  _GIT checkout -b testBranch
  echo "A Test File" > "${currentTempDir}/test.txt"

  _ASSERT_STDOUT_RETURN_EQUAL "New file" 'GITLABEL_SUGGEST_IMAGE_TAG ${currentTempDir}' "initial" "${GITLABEL_OK}"

  _GIT add test.txt
  

  _ASSERT_STDOUT_RETURN_EQUAL "Added file" 'GITLABEL_SUGGEST_IMAGE_TAG ${currentTempDir}' "dev" "${GITLABEL_FAIL}"
  

  # Branch is not commited

  # Commit
  _GIT commit -m "Committing test"
 
  # FIXME
  _ASSERT_STDOUT_RETURN_EQUAL "Committed file" 'GITLABEL_SUGGEST_IMAGE_TAG ${currentTempDir} | _REMOVE_SHORT_COMMIT' "testBranch-XXXXXXX" "${GITLABEL_OK}"
  _ASSERT_STDOUT_RETURN_EQUAL "Committed file (snapshot)" 'GITLABEL_SUGGEST_IMAGE_TAG ${currentTempDir} snapshot' "testBranch-snapshot" "${GITLABEL_OK}"

  # Branch is commited

  # And now with a VERSION file
  echo "v1.2.3" > ${currentTempDir}/VERSION
  _GIT add VERSION
  _GIT commit VERSION -m 'Setting a version'
  
  _ASSERT_STDOUT_RETURN_EQUAL "VERSION" 'GITLABEL_SUGGEST_IMAGE_TAG ${currentTempDir} | _REMOVE_SHORT_COMMIT' "v1.2.3-XXXXXXX" "${GITLABEL_OK}"
  _ASSERT_STDOUT_RETURN_EQUAL "VERSION (snapshot)" 'GITLABEL_SUGGEST_IMAGE_TAG ${currentTempDir} snapshot' "v1.2.3-snapshot" "${GITLABEL_OK}"

  # VERSION and uncommitted files
  echo "Some new stuff" >> "${currentTempDir}/test.txt"

  _ASSERT_STDOUT_RETURN_EQUAL "VERSION and new" 'GITLABEL_SUGGEST_IMAGE_TAG ${currentTempDir}' "dev" "${GITLABEL_FAIL}"
  _GIT commit test.txt -m 'Adding some new stuff'
  
  _ASSERT_STDOUT_RETURN_EQUAL "VERSION and committed" 'GITLABEL_SUGGEST_IMAGE_TAG ${currentTempDir} | _REMOVE_SHORT_COMMIT' "v1.2.3-XXXXXXX" "${GITLABEL_OK}"
  _ASSERT_STDOUT_RETURN_EQUAL "VERSION and committed (snapshot)" 'GITLABEL_SUGGEST_IMAGE_TAG ${currentTempDir} snapshot' "v1.2.3-snapshot" "${GITLABEL_OK}"


  # Tagging this overrides everything again
  _GIT tag "v1.2.3-RELEASE"
  
  _ASSERT_STDOUT_RETURN_EQUAL "Tagging again" 'GITLABEL_SUGGEST_IMAGE_TAG ${currentTempDir}' "v1.2.3-RELEASE" "${GITLABEL_OK}"

  # Illegal characters in the VERSION
  echo "V17:Doesn't? Does?" > ${currentTempDir}/VERSION
  _GIT commit ${currentTempDir}/VERSION -m "Weird Characters"


  _ASSERT_STDOUT_RETURN_EQUAL "Tagging again" 'GITLABEL_SUGGEST_IMAGE_TAG ${currentTempDir} snapshot' "V17Doesnt-snapshot" "${GITLABEL_OK}"

  # Reset everything
  _GIT_RESET
  _GIT branch -D testBranch
}


function UT_test_GITLABEL_CHECK_UNCOMMITED_CHANGES() {
  _GIT checkout master

  _ASSERT_STDOUT_RETURN_EQUAL "Initial State" 'GITLABEL_CHECK_UNCOMMITED_CHANGES ${currentTempDir}' "" "${GITLABEL_OK}"
  _ASSERT_STDOUT_RETURN_EQUAL "Initial State strict" 'GITLABEL_CHECK_UNCOMMITED_CHANGES ${currentTempDir} strict' "" "${GITLABEL_OK}"

  # Now create a new branch and commit a new file
  _GIT checkout -b testBranch
  echo "A Test File" > "${currentTempDir}/test.txt"

  _ASSERT_STDOUT_RETURN_EQUAL "New file" 'GITLABEL_CHECK_UNCOMMITED_CHANGES ${currentTempDir}' "" "${GITLABEL_OK}"
  _ASSERT_STDOUT_RETURN_EQUAL "New file strict" 'GITLABEL_CHECK_UNCOMMITED_CHANGES ${currentTempDir} strict' "?? test.txt" "${GITLABEL_FAIL}"

  _GIT add test.txt
  

  _ASSERT_STDOUT_RETURN_EQUAL "Added file" 'GITLABEL_CHECK_UNCOMMITED_CHANGES ${currentTempDir}' "A  test.txt" "${GITLABEL_FAIL}"
  _ASSERT_STDOUT_RETURN_EQUAL "Added file strict" 'GITLABEL_CHECK_UNCOMMITED_CHANGES ${currentTempDir} strict' "A  test.txt" "${GITLABEL_FAIL}"

  # Branch is not commited

  # Commit
  _GIT commit -m "Committing test"

  _ASSERT_STDOUT_RETURN_EQUAL "Committed" 'GITLABEL_CHECK_UNCOMMITED_CHANGES ${currentTempDir}' "" "${GITLABEL_OK}"
  _ASSERT_STDOUT_RETURN_EQUAL "Committed strict" 'GITLABEL_CHECK_UNCOMMITED_CHANGES ${currentTempDir} strict' "" "${GITLABEL_OK}"

   # Branch is commited

  # Reset everything
  _GIT_RESET
  _GIT branch -D testBranch
}


UT_RUN_TEST_SUITE "gitLabel test"
