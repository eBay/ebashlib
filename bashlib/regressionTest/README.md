regressionTest
==============

function battery to conduct regression tests

run `../../examples/example_regressionTest.sh` for a demo of the main functionalities

public functions
----------------

### `REGRESSION_TEST_START ( format )`

Starting function, mandatory to call at the beginning. The regressionTest functions
make use of the bashlib/report library, so all current formats are supported (HTML, Markdown, terminal)

### `REGRESSION_TEST_NEW_GROUP( description )`

function to register a new test group. Useful if you want to group "stuff" in the output,
but not mandatory. 

### `REGRESSION_TEST_SET_MAX_DIFF( lines )`

setter function to set the maximum number of diffs in failed experiments (default: `10`)

### `REGRESSION_TEST_SET_VERBOSITY( level )`

setter function for the verbosity of the regression test report. Can be either an integer level
or a predefined constant (recommended). Default is `20=REGRESSION_TEST_VERBOSITY_INFO`

| value   | constant                          | meaning                                                       |
|---------|-----------------------------------|---------------------------------------------------------------|
| 10      | `REGRESSION_TEST_VERBOSITY_DEBUG` | output *all* the tests (successful or not) and their commands |
| 20      | `REGRESSION_TEST_VERBOSITY_INFO`  | output *all* the tests but keep it short for successful ones  |
| 40      | `REGRESSION_TEST_VERBOSITY_ERROR` | output only failed tests                                      |

### `REGRESSION_TEST_ASSERT` ( description, command, expectedOutput, input )

will check whether a command will produce the desired output. Mainly targeted at steps within 
a larger pipe.

* `description` human readable description of the assert test
* `command` bash-eval compatible command that is to be executed 
* `expectedOutput` specifies what should come out of this test, if any. defaults to ""
* `input` what should be piped into the command. defaults to ""

### `REGRESSION_TEST_ASSERT_RAISE` ( description, command, expectedCode, input )

will check whether a command will produce the expected exit code.

* `description` human readable description of the assert test
* `command` bash-eval compatible command that is to be executed 
* `expectedCode` specifies the expected exit code, defaults to 0 (no error)
* `input` what should be piped into the command. defaults to ""

### `REGRESSION_TEST_DIFF_FILES` ( description, outputFile, referenceFile, diffIgnore, maxDiffLines ) 

function to check whether two files differ

* `description`   human readable description of why you are comparing the files
* `outputFile`    the file that was produced and should be checked
* `referenceFile` gold standard output file
* `diffIgnore`    _optional_ Regular expression of which lines should be ignored in the diff 
                     process (e.g., timestamps, user names...)
* `maxDiffLines`  _deprecated_ Set the line limit globally with `REGRESSION_TEST_SET_MAX_DIFF`
 

* **Notes:** diff behavior for ignoring lines:
 * the whole matching line will be ignored, so any diffs in that line will be unnoticed as well
 * if a certain change in a hunk (diff block) does NOT match a regEx, you will see the whole hunk.
   from the man page:

> for each nonignorable change, diff prints the complete set of changes in 
> its vicinity, including the ignorable ones.

### `REGRESSION_TEST_DIFF_FILES_FLOAT` ( description, outputFile, referenceFile, precision ) 

function to check whether two files differ with floating precision

* `description`   human readable description of what is currently tested
* `outputFile`    the file that was produced and should be checked
* `referenceFile` gold standard output file
* `precision`     float where delta difference is tolerable. defaults to 0.000001

* **Note:** not suitable for large files, will load the first into memory

### `REGRESSION_TEST_END()`

function to report the end of the current test group (or the whole test)

**mandatory** as last step.

if a new test group is started after this command, it will keep the overall
 exit code and invoke later (via "trap")
