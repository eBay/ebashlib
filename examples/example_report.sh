#!/bin/bash

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.

# simple example script to show the reporting functionality

source $(dirname $0)/../bashlib/bashlib.sh

setUsage "Simple example script for shell options.\nusage: $(basename $0) [options]"
addOption -f --format  dest=FORMAT default="MARKDOWN" help="Output format, out of HTML, MARKDOWN, TERMINAL"
parseOptions "$@"

REPORT_SET_OUTPUT_FORMAT "${FORMAT}"

REPORT_START      "ebashlib Report Documentation"
REPORT_PARAGRAPH  "This example is a self-reference on the reporting functionality of bashlib.

You can execute this script with various format options via \`--format\`. Currently supported options
are \`HTML\`, \`MARKDOWN\`, \`TERMINAL\`." 
REPORT_CHAPTER    "Documentation"
REPORT_PARAGRAPH  "This tool battery allows you to write nice print-out reports in
various formats."

REPORT_SECTION    "Scope"
REPORT_PARAGRAPH  "We designed this tool so that:

* it is very _light-weight_ and can be plugged in into your scripts easily
* it supports many _markup options_ 
* it tries to _look nice_ on various output formats:
 * HTML
 * Markdown
 * ANSI Terminal

The functionality is strongly influenced
by the **Markdown** language, but comes with some of its own flavors (like
corporate identity colors, if supported in output format)."
REPORT_SECTION    "Out of scope"
REPORT_PARAGRAPH  "This tool is designed for *human readability*, not for machine processing:

 * it might not be fast and is not designed for huge outputs  
 * there might be special characters that will break text search (such as ANSI terminal 
   escape codes)

Instead, we recommend to use the *logging* functionality provided by bashlib.

Other disclaimers:

* it is (currently) not very customizable
* the output is not deterministic:
 * it will look different (but nice) in various formats
 * there's no guarantee that it will look the same in newer versions of bashlib
"


REPORT_CHAPTER    "Supported Markups"

REPORT_SECTION    "Paragraphs"
REPORT_PARAGRAPH  "Paragraphs are the main way to output larger texts.

They still look pretty if you type in very very very very very very very very very very very long lines (via folding, if necessary).
Also, you probably have a lot of stories to tell, and for
this you can use multiple lines like
this
(if you want to.)

New paragraphs start after an empty newline."

REPORT_SECTION    "Emphasis"
REPORT_PARAGRAPH  "Markdown emphasis like **strong**, *emphasized word(s)* or \`*code_words*\` is supported for paragraphs.
**Strong/emphasis 
markup**
can _spread
several lines_ in the source paragraph input, code words not.
"

REPORT_SECTION    "Codeblocks"
REPORT_CODE_BLOCK "Codeblocks will respect multiple lines that are given by 
_you.
(Because_ they *love* you.) 
   (yes, eve\n \those escape characters)

  code blocks also
       keep the text unchanged (except for special characters 
       such as < > or & in HTML)
"

REPORT_SECTION    "Tables"
REPORT_PARAGRAPH  "Tables are pipe-separated entries which also respect _emphasis_ and **strong** markups (no guarantee that they are look-alikes to paragraph markups, though).
Options can be given as a second variable. They are separated by \`;\` and can be assigned to all columns (default) or selected ones, in which case you can write:
\`<columnNr>,<columnNr>,...:OPTION\`. For example, the following table was rendered with \`HEADER;2,3:RIGHT;1:CENTER\`."
REPORT_TABLE      "
| Experiment | Precision | Recall |
| Sanity     | **0.5** | 0.3 |
| Tranquility | 0.3 | 0.2 |
| _Ubiquity_ | 1 | 0.3 |
" "HEADER;2,3:RIGHT;1:CENTER"
REPORT_PARAGRAPH  "Supported options:

* \`HEADER\` (if given, first row will look different)
* \`LEFT\` / \`CENTER\` / \`RIGHT\` (specify column alignment)
"

REPORT_SECTION    "Diff views"
REPORT_PARAGRAPH  "When you want to highlight differences between two files or directories,
you can render unified diffs (created by \`diff -u\`) with the \`REPORT_UNIFIED_DIFF\` function. 
Output example:"
REPORT_UNIFIED_DIFF "--- vonDenFischerUndSiineFru.txt
+++ vonDemFischerUnSiineFru.txt
@@ -1,20 +1,21 @@
+Vom Fischer und seiner Frau, 2. Auflage, 1819

-Von den Fischer und siine Fru.
+Von dem Fischer un siine Fru.

Daar was mal eens een Fischer un siine Fru, de waanten tosamen in’n Pispott, dicht an de See
– un de Fischer ging alle Dage hen un angelt, un ging he hen lange Tid."

REPORT_CHAPTER    "Last thoughts"
REPORT_PARAGRAPH  "Run with \`--format terminal\` for terminal output.

Oh, did you watch this on a terminal output and it was too fast to read?
Pipe it into less with the option \`less -R\` to enable the terminal escape colors."
REPORT_END
