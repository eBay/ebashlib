Developer's Guidelines
======================

Thanks for your willingness to contribute to this code base.

This repo aims to 

* follow very high coding standards and 
* strict release policies.

In the following sections, we highlight the most important standards directly or
link to further reading. Please note that these policies are not intended to
sound bossy, but merely to ensure high quality so that its clients -- our
colleagues -- can use them with trust.

Documentation
-------------

All sub-folders in this repository **MUST HAVE** a non-trivial README.md stored
which highlights the purpose and scope of the scripts contained therein. It is
**strongly recommended** that these READMEs make proper use of the Markdown
notation.

All files **MUST HAVE** a non-trivial file header explaining the purpose of this
file.

It is **strongly recommended** that all functions have a short description, or at
least a function name that is self-explanatory.

It is **strongly recommended** that all variables of a function as well as its
return value is documented.

Coding Style
------------

### recommended bash casing

* `GLOBAL_BASH_VARIABLE="should be upper case with underscores"`
* `local localBashVariable="camelCase, and declared local"`
* `thisIsAFunctionVariable="camel case, starting with small letter"`
* `function GLOBAL_FUNCTION()`

### recommended `.vimrc` options:

``` vimrc
set tabstop=4
set expandtab
set shiftwidth=2
set cinoptions=g0,(0
```

* `expandtab will convert tabs to spaces, in this case, `tabstop`, i.e., 4
* `shiftwidth` controls how much inserts you have when you do reindent operations
* `cinoptions` automatic indentation options for brackets:
  * `g0`: Place scope declarations N characters from the indent of the
          block they are in.
  * `(0`:  When in unclosed parentheses, indent N characters from the line
           with the unclosed parentheses.

Versioning
----------

This repository follows the versioning guidelines of [Semantic
Versioning](http://semver.org/spec/v2.0.0.html).  This means, among other
things, that a release is tagged as MAJOR.MINOR.PATCH, with:

* MAJOR releases introduce API-incompatible changes,
* MINOR releases introduce backward-compatible new features
* PATCH releases introduce backward-compatible bug fixes

All versions **MUST BE** documented in the changelog. For critical bug fix PATCHes from
version 1 onward, *all* MINOR releases of a non-deprecated MAJOR must be
patched. The deprecation of a MAJOR must be announced asap in the central README and the 
changelog.

Branching
---------

This repository follows the branching guidelines of [A successful
Git branching model](http://nvie.com/posts/a-successful-git-branching-model/).

This means, among other things, that there are two branches with
infinite timeline:

* master
* develop

Supporting branches are:

* `release-X.X.X` (release candidate, to be merged into the `master` branch)
* `hotfix-X.X.X` (hotfix of a master version, to be merged into `develop` and `master` branch)
* `anyOtherBranch` (where features are developed, to be merged into `develop` branch)

Until we shift the documentation to this README, confer the link above for a
thorough explanation of the branch meanings.

