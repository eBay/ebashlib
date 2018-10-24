bashlib
=======

Simply type `source <thisRepoFolder>/bashlib/bashlib.sh` into your bash script.

You will then have access to the functions in these subcategories:

dryrun
------

* providing functionality to not invoke scripts under certain conditions
* includes handling of file redirects

fileSanity
----------

* checks if file exists, runs, works as predicted
* checks whether files have the same line numbers

gitLabel
--------

* using git commands to obtain more knowledge about a repository
* suggest tag names on the basis of repo status

limax
-----

* functions that behave alike on linux and MacOS systems
 * for linux' `readlink -f` and `mktemp -d` commands

logging
-------

* standardized log level output
* sections/plaintext output

regressionTest
--------------

* conduct regression testing on your programs, like
 * assert an expected output
 * ensure that resulting files look as expected

report
------

* pretty-print report for:
 * `HTML`
 * `MarkDown`
 * `Terminal` (w. ANSI-256 color support)

shellOptions
------------

* easy-to-integrate shell option parsing
* automatically generated help message
* required fields, short/long options, default values

termColorFont
-------------

* color support for terminals

unitTest
--------

* standardized assertions for equal values
* including setUp/tearDown and testSuite support
