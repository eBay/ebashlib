Changelog
=========

Version 0.10.1
--------------

* bug fixes (gitlabel):
  * correct behaviour for uncomitted branches
  * unit tests

Version 0.10.0 ("[Monica](https://en.wikipedia.org/wiki/Monica_Zetterlund)")
----------------------------------------------------------------------------

* general clean-up of READMEs

* bug fixes:
  * assertEqualNumberOfLines now works under MacOS as well

Version 0.9.0 ("[Pops Staples](https://en.wikipedia.org/wiki/Pops_Staples)")
----------------------------------------------------------------------------

* regression tests:
  * adding float precision file diff
* dryrun functionality
* git label functionality

* bug fixes:
  * limax
    * changing (correcting) behaviour for existant directory but (yet) missing file
  * guardians in bashlib
    * always return 0 so that bashlib does not abort in `-e` mode

Version 0.8.1
-------------

* regression tests:
  * bugfix for number of lines comparison for failed tests

Version 0.8.0 ("[Charlie](https://en.wikipedia.org/wiki/Charlie_Christian)")
----------------------------------------------------------------------------

* logging: 
  * convenience functions for log levels
  * output of origin script/line on `WARN` and above
* regression tests: 
  * better readability of diff reports
  * stdout/stderr output on failed assert-raise commands
* limax (functions that behave alike on linux and MacOS systems)
  * for linux' `readlink -f` and `mktemp -d` commands


Version 0.7.1 ("[Hoagy](https://en.wikipedia.org/wiki/Hoagy_Carmichael)")
-------------------------------------------------------------------------

* regression tests:
  * clean-up & readability, several verbosity levels

* (minor cosmetic fixes)

Version 0.6.0 ("[Skip](https://en.wikipedia.org/wiki/Skip_James)")
------------------------------------------------------------------

* regression tests:
  * assert raise

Version 0.5.0 ("[Ivie](https://en.wikipedia.org/wiki/Ivie_Anderson)")
---------------------------------------------------------------------

* unified diff view for reports
* regression tests:
  * assert
  * file diff
  * test groups/output

Version 0.4.0 ("[Bessie](https://en.wikipedia.org/wiki/Bessie_Smith)")
----------------------------------------------------------------------

* table support for reports

Version 0.3.0 ("[Bix](https://en.wikipedia.org/wiki/Bix_Beiderbecke)")
----------------------------------------------------------------------

* color support
* pretty-print report for:
  * `HTML`
  * `MarkDown`
  * `Terminal` (w. ANSI-256 color support)

Version 0.2.0 ("[Satie](https://en.wikipedia.org/wiki/Erik_Satie)")
-------------------------------------------------------------------

* unit tests:
  * now with test suits
  * including setUp and tearDown support
  * with output convenience (e.g., offending script/line on failure)
* logging:
  * supports log levels
  * supports "quiet" mode

Version 0.1.0 ("[Chet](https://en.wikipedia.org/wiki/Chet_Baker)")
------------------------------------------------------------------

* main manifesto
* bashlib scripts for support of:
  * logging (basic)
  * shell options 
  * file checks (basic)
  * unit tests (basic)
* examples
