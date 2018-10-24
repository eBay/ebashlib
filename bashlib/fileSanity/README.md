fileSanity
==========

* checks if file exists, runs, works as predicted
* checks whether files have the same line numbers

Public Functions
----------------

### `sanitizeName ( name )`

function to remove unwanted characters from a name

* `name` single string
* returns `name` but stripped to 
  * a) alpha-numberical letters or 
  * b) `_.-` punctuation marks

### `checkFile( mode, file, option, expected_lines)`

function to check whether a file exists

will invoke exit 2 on error

* `mode`: determine the level of testing, out of: [exists, executable, runs]
  * `exists`: true if file could be found
  * `executable`: true if file has executable rights for this user
  * `runs`: true if file returns expected number of lines, given `option` (s.below); mostly testing helper files
* `file` file to be checked
* `option` if `mode` equals `runs`, enter options here
* `expected_lines`: if `mode` equals `runs`, enter expected minimum number of output lines here

### `assertEqualNumberOfLines ( current_step, reference_file, [hyp_file] )`

function to check whether all files given have the same line numbers

will invoke exit 2 on error

* `current_step` short string describing where the test has been invoked, for logging purposes
* `reference_file` file (can be gzipped) to which the subsequent ones are compared against
* `hyp_file` one or many files (can be gzipped) whose line number will be compared to the reference file
