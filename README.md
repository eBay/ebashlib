ebashlib
========

A script battery which gathers several generic helper scripts for other
repositories.

Motivation
----------

> _simple tools...   done right!_

Spent hours again debugging your code until you found that one script did not
have the file ownership you expected?  Does your bash logging output look
cluttered and hard to read? Tired of writing complicated argument parsers every
time you start a new bash script? 

Simply type `source <thisRepoFolder>/bashlib/bashlib.sh` into your bash script so
that you have access to:

* logging functions:
  * for simple and large log files, or
  * for complex, pretty-printed reports
* code maturity functions:
  * sanity file checks 
  * unit tests
  * regression tests
* linux/macOS bash compatibility functions
* easy to use shell option parsing (via davvil/shellOptions as submodule)

Further Reading
===============

* *Eager to try it out yourself?* See the [Examples](examples/README.md)
* *Hesitant whether you may use it?* See the [License](LICENSE).
* *Already convinced?* See the [Installation Guidelines](INSTALL.md) on how to
  use this repo.
* *Returning client?* See the [Changelog](CHANGELOG.md) for the latest additions. 
* *Want to contribute?* See the [Developer's Guidelines](DEVELOPING.md) on coding
  best practices.

Acknowledgements
================

Main Developer: 

* Daniel Stein

Additional code contributions from:

* Gregor Leusch 
* Leonard Dahlmann 

Feedback and legal support:

* Brian Haslam

Submodule `shellOptions` by:

* Davi(i)d Vilar

Testers
-------

(alphabetically):

* José de Souza
* Sivan Elkis
* Michael Kozielski
* Shahram Khadivi
* Prashant Mathur
* Evgeny Matusov
* Pavel Petrushkov

Inspiration
-----------

> "Inspiration is when you forget where you took it from" 
-- source: uh... unknown? Me?

This code base could not have existed without all the developer forums out
there. Help me, StackOverflow, you're our only hope. In particular, acknowledgement and thanks to Keith Smith:

See e.g., https://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
https://stackoverflow.com/a/1116890
Keith Smith, https://stackoverflow.com/users/12347/keith-smith

Notable inspiration from a mutual
  "there's-got-to-be-a-way-you-can-do-this-in-bash" peer, for Markdown to HTML
conversion: Chad Braun-Duin, in his amazing markdown.bash project. Kudos! 

Other than that, we tried hard to attribute properly in the code. If you feel 
that we missed a reference, please drop us a line.

License
-------
Copyright 2018 eBay Inc.
Main developer: Daniel Stein

Use of this source code is governed by an MIT-style license that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.
