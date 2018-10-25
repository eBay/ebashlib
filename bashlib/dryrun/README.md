dryrun
======

functionality to either execute or echo command in dryrun

Public functions
----------------

### `DRYRUN_EXEC [command]`

Either prints or executes a command, based on `DRYRUN` variable.

*NOTE*: if the overall command output is redirected into a file, the
function aims to warn the user about this on STDERR but continue to write
the dryrun output into the file given by the user.

### `DRYRUN_WRITE_TO_FILE(file)`

If DRYRUN is set to true, show filename it would write to, otherwise writes stdin into file.

### `DRYRUN_APPEND_TO_FILE(file)`

If DRYRUN is set to true, show filename it would append to, otherwise append stdin to file.

### `DRYRUN_SET_DRYRUN`

Setter for dryrun mode (i.e., commands invoked by `DRYRUN_EXEC`
are only echoed to STDOUT, but not executed)

### `DRYRUN_UNSET_DRYRUN`

Un-setter for dryrun (i.e., commands invoked by `DRYRUN_EXEC` are 
executed).
    
