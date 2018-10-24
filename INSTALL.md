Installation Guidelines
=======================

Thank you for considering to add this repo to your own code.

Basic Usage
-----------

Simply type `source <thisRepoFolder>/bashlib/bashlib.sh` into your bash script.

That is all there is to it, really. 

Troubleshooting
---------------

> Trouble / Trouble, trouble, trouble, trouble
-- Ray LaMontagne, "Trouble" (2004)

Ok, maybe some caveats:

* `bashlib` requires `bash`. Duh. It will abort if in any other shell environment
  as some functions no longer work. Mind you that, even if the shebang (`#!`)
  clearly states `/bin/bash` or similar, this can be short-circuited by invoking
  a script via `zsh ./your-bash-script` and then lead to strange behaviours.
* while the functions should run in most environments, we did not do extensive testing
  on all OS out there. This repo is in use with Ubuntu 12.04+ and MacOS 10.11.6+.
* really, always use `source`. If you invoke via `./`, you are starting the scripts
  in a new `bash` session, and after loading all the functions within this bash session,
  all functions disappear again once the loading is done.
* some functions will have return values other than 0. That is fine under most 
  circumstances. However, if you run bash scripts with the `-e` option (abort
  on failure), this might crash your code. You can add `|| true` after the
  functions to prevent that.
* while this is not the targeted usage, you can type the `source` command above
  directly from the terminal. Note though that there are some guardians in place
  that prevent functions from being loaded twice. Should you change some scripts,
  `source`-ing again might not do what you thought it does.

Repository submodule
--------------------

Instead of copying this code base into your own repo, we would recommend that
you include the most recent version as a submodule. 

Our versions are tagged commits and thus will not change even when ebashlib
develops further. The version numbering follows the guidelines of [Semantic
Versioning](http://semver.org/spec/v2.0.0.html).

This means, among other things, that our versions are tagged as
MAJOR.MINOR.PATCH, with:

* MAJOR releases introduce API-incompatible changes,
* MINOR releases introduce backward-compatible new features
* PATCH releases introduce backward-compatible bug fixes

Thus, you can safely upgrade to new MINOR or PATCH releases and be reasonably
sure that your code will not break. See the [Changelog](CHANGELOG.md) for an
overview of the current versions.

To add ebashlib into your repo, type:

```bash
git submodule add ssh://git@<github-repo>/eBay/ebashlib
git submodule init
git submodule update
```

Any user checking out your repository would need to type:

```bash
git submodule update --init --recursive
``` 

If you are operating behind a firewall with tunneled ports for github access,
you can edit your `.ssh/config` accordingly, e.g.:

```txt
Host my.corp.github
  Hostname localhost
  Port <yourPort>
  User git
```
