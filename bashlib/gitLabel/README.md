gitLabel
========

various functions to help properly identify/label a git repository

### `GITLABEL_GET_README_DESCRIPTION(directory, paragraph, filename)`

 obtain paragraph from readme text file

 a paragraph is assumed to be enclosed by two consecutive line breaks
 by default, attempts to find second paragraph in README.md (assumed to be the description)

Parameters:

* `directory` a directory within a git repository (defaults to .)
* `paragraph` which paragraph contains the description (defaults to 2)
* `filename` name of the central readme file (defaults to README.md)

Returns:

* paragraph, as string

### `GITLABEL_GET_UPSTREAM_URL (directory)`

attempt to determine git upstream repository url

(NOTE) does not work in detached state

Parameters:

* `directory` a directory within a git repository (defaults to .)

Returns:

* upstream URL if successful, "" else

### `GITLABEL_GET_TAG(directory)`

check whether our current git commit matches a tag

Parameters:

* `directory` a directory within a git repository (defaults to .)

Returns:

* tag name/`GITLABEL_OK` if found, "untagged"/`GITLABEL_FAIL` else

### `GITLABEL_CHECK_UNCOMMITED_CHANGES(directory, untracked)`

checks whether files known to the git index contain uncommited (and maybe untracked) changes

* of interest are:
  * `M` updated in index
  * `A` added to index
  * `D` deleted from index
  * `R` renamed in index
  * `C` copied in index
* the following might be ignored
  * `?` untracked
* the following will be ignored (duh!)
  * `!` ignored

Parameters:

* `directory` a directory within a git repository (defaults to .)
* `untracked` if "strict", also throw error on untracked files

Returns:

* `GITLABEL_OK` if no uncommited changes, list of changes/`GITLABEL_FAIL` else

### `GITLABEL_SUGGEST_IMAGE_TAG(directory, [snapshot-suffix])`

Make a suggestion for a tag name of the current repo status

* If there are uncommitted files in the repo         --> `dev`  (and fail)
* If this is a tagged version                        --> `<tagname>`
* If there is a file called VERSION in the repo root --> `<VERSION>-<commit>`
* Else, if we have a branch name                     --> `<BRANCHNAME>-<commit>`
* (If everything fails                               --> `dev` (and fail)

Here, `<commit>` is the short commit ID (e.g. `1cae95e`). If you pass 
a different name as second parameter, e.g. `snapshot`, this will use that
parameter instead of the commit.

 E.g. `GITLABEL_SUGGEST_IMAGE_TAG .` --> `master-1cae95e`,
      `GITLABEL_SUGGEST_IMAGE_TAG . snapshot` --> `master-snapshot`



Parameters:

*  `directory`: a directory within a git repository (defaults to .)
*  `[snapshot]`: an optional suffix to be used instead of the git commit, e.g. 'snapshot'

Returns:

* `<suggestion>`/`GITLABEL_OK` if no uncommited changes, or dev/`GITLABEL_FAIL`


### `GITLABEL_COMMIT(directory)`

get current commit hash (but warn on uncommited changes)

Parameters:

* `directory` a directory within a git repository (defaults to .)

Returns:

* commit hash/`GITLABEL_OK` if no uncommited changes, commit hash/`GITLABEL_FAIL` else
