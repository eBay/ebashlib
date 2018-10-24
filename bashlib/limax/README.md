limax
=====

Ties together functionality that works with bash commands on both linux and mac OS.
Because sometimes, mismatches in creating temp dirs or following sym links can be
as obnoxious as having a colony of Limax Flavus in your garden.

Public functions
----------------

### `LIMAX_READLINK ( file/path )`

echos the canonical path of the file/path (as `readlink -f` would in linux)

return codes:

| value   | constant                        | meaning                         |
| ------- | ------------------------------- | ---------                       |
| 0       | `LIMAX_RETURN_OK`               | everything ok                   |
| 1       | `LIMAX_RETURN_FILE_NOT_FOUND`   | file not found / dead link      |
| 2       | `LIMAX_RETURN_DIR_NOT_FOUND`    | directory not found / dead link |
| 3       | `LIMAX_RETURN_MAX_SYMLINKS`     | too many links (default: 20)    |

### `LIMAX_MKTEMPDIR ( prefix="tmp" )`

creates a temporary dir (via `mktemp`)

