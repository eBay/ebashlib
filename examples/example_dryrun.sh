#!/bin/bash 

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# simple example script to show the dryrun functionality

source $(dirname $0)/../bashlib/bashlib.sh

setUsage "dryrun example\nusage: $( basename $0 ) [options]\n\nOptions:\n"
addOption -n --dryrun dest=DRYRUN    flagTrue help="output command only, do not execute"
parseOptions "$@"

# on general behavior
DRYRUN_EXEC echo -e "this is a demo" "for the" "dryrun functionality\n"
DRYRUN_EXEC echo -n -e "\$DRYRUN is set to $DRYRUN. Depending on this value
the command is either output or executed

with line breaks and all\n"

DRYRUN_EXEC echo "To SEE the command itself, invoke this example again with the -n option" | \
    DRYRUN_EXEC sed 's/SEE/see/g'
DRYRUN_EXEC echo "... but BEE careful with pipes, each command needs to be preceeded by DRYRUN_EXEC again" | \
    sed 's/BEE/be/g'

# on redirects
DRYRUN_EXEC echo "(and redirects might complicate things even more..." 
DRYRUN_EXEC echo "... and in the end it does really matter" > "$( dirname $0)/I_dried_so_hard_and_got_so_far.txt"
DRYRUN_EXEC echo "... just there! Did you see the command above? No? Look into the example then." 

# on pretending to write into files
DRYRUN_EXEC echo "If, in dryrun, you want to just display the file that you write into" | DRYRUN_WRITE_TO_FILE "$( dirname $0)/drydisplay.txt"

DRYRUN_EXEC echo "there are some readable functions called DRYRUN_WRITE_TO_FILE and DRYRUN_APPEND_TO_FILE" | \
    DRYRUN_APPEND_TO_FILE "$( dirname $0)/drydisplay.txt"
DRYRUN_EXEC echo "... also, this line is written to stdout, but some more steps might be hidden from you." | DRYRUN_APPEND_TO_FILE 

