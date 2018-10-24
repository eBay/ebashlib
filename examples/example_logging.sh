#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# simple example script to show the logging functionality

source $(dirname $0)/../bashlib/bashlib.sh

LOGGER_BLOCK "Simple logging demo"

LOGGER_INFO  "There is so much to log, such as"
LOGGER_TRACE "... really verbose variable contents"
LOGGER_DEBUG "... or function messages, progress update"
LOGGER_INFO  "... or major script milestones passed"
LOGGER_INFO  "Higher log levels will also output the calling script/line"
LOGGER_WARN  "... such as fishy behaviour"
LOGGER_ERROR "... and script failures"

LOGGER_BLOCK "Log levels are supported as well"
LOGGER_INFO  "Setting log level to [INFO]. You won't see the next [DEBUG] line"
LOGGER_SET_LOG_LEVEL ${LOG_INFO}
LOGGER_DEBUG "This line is not output because it is below the log level"
LOGGER_INFO  "Now, I am setting logging to [QUIET]. This is my last message"
LOGGER_SET_LOG_LEVEL ${LOG_QUIET}
LOGGER_INFO  "Which is a pity, you know? So much more to tell. Like that joke about 'git'"
LOGGER_INFO  "What's that? Everyone has his or her own version of that git joke? Well, go figure"
