Report
======

These scripts support reporting output for with various format options.

Currently supported options are 
* `HTML`, 
* `MARKDOWN`, 
* `TERMINAL`.


Public functions
----------------

#### `REPORT_SET_OUTPUT_FORMAT( format: string)`

> function to set output format

currently supported output:

* HTML
* MARKDOWN
* TERMINAL

#### `REPORT_START( title: string )`

> function to be called for the beginning of each report

Title will be used 
* as document name, if applicable, and 
* as first chapter

#### `REPORT_END()`

> function to be called at the end of each report

#### `REPORT_CHAPTER( chapterHeader )`

> function generating a new chapter

#### `REPORT_SECTION( sectionHeader )`

> function generating a new section

#### `REPORT_PARAGRAPH( text )`

> function generating a new section

#### `REPORT_CODE_BLOCK( codeblock )`

> function to include a code block that is to be outputted in monospace

#### `REPORT_TABLE( tableInput, tableOptions )`

> function to output tables

* `tableInput` text field containing the table; assumed to be 
 * one row per line
 * "|" separated
* `tableOptions` 
 * `HEADER` (if given, first row will look different)
 * `LEFT` / `CENTER` / `RIGHT` (specify column alignment)

Demonstration
=============

(This chapter was basically created by the tool itself, see `examples/example_report.sh`)

This tool battery allows you to write nice print-out reports in
various formats.

Scope
-----

We designed this tool so that:

* it is very _light-weight_ and can be plugged in into your scripts easily
* it supports many _markup options_ 
* it tries to _look nice_ on various output formats:
 * HTML
 * Markdown
 * ANSI Terminal

The functionality is strongly influenced
by the **Markdown** language, but comes with some of its own flavors (like
corporate identity colors, if supported in output format).

Out of scope
------------

This tool is designed for *human readability*, not for machine processing:

 * it might not be fast and is not designed for huge outputs  
 * there might be special characters that will break text search (such as ANSI 
terminal 
   escape codes)

Instead, we recommend to use the *logging* functionality provided by bashlib.

Other disclaimers:

* it is (currently) not very customizable
* the output is not deterministic:
 * it will look different (but nice) in various formats
 * there's no guarantee that it will look the same in newer versions of bashlib

Supported Markups
=================

Paragraphs
----------

Paragraphs are the main way to output larger texts.

They still look pretty if you type in very very very very very very very very 
very very very long lines (via folding, if necessary).
Also, you probably have a lot of stories to tell, and for
this you can use multiple lines like
this
(if you want to.)

New paragraphs start after an empty newline.

Emphasis
--------

Markdown emphasis like **strong**, *emphasized word(s)* or `*code_words*` is 
supported for paragraphs.
**Strong/emphasis 
markup**
can _spread
several lines_ in the source paragraph input, code words not.

Codeblocks
----------

```
Codeblocks will respect multiple lines that are given by 
_you.
(Because_ they *love* you.)

  code blocks also
       keep the text unchanged (except for special characters 
       such as < > or & in HTML)

```
Tables
------

Tables are pipe-separated entries which also respect _emphasis_ and **strong** 
markups (no guarantee that they are look-alikes to paragraph markups, though).
Options can be given as a second variable. They are separated by `;` and can be 
assigned to all columns (default) or selected ones, in which case you can write:
`<columnNr>,<columnNr>,...:OPTION`. For example, the following table was 
rendered with `HEADER;2,3:RIGHT;1:CENTER`.

|  Experiment |  Precision |  Recall |
| :---: | ---: | ---: |
|  Sanity     |  **0.5** |  0.3 |
|  Tranquility |  0.3 |  0.2 |
|  _Ubiquity_ |  1 |  0.3 |

Supported options:

* `HEADER` (if given, first row will look different)
* `LEFT` / `CENTER` / `RIGHT` (specify column alignment)

Diff views
----------

When you want to highlight differences between two files or directories,
you can render unified diffs (created by `diff -u`) into the 
`REPORT_UNIFIED_DIFF` function. 
Output example:

```diff
--- vonDenFischerUndSiineFru.txt
+++ vonDemFischerUnSiineFru.txt
@@ -1,20 +1,21 @@
+Vom Fischer und seiner Frau, 2. Auflage, 1819

-Von den Fischer und siine Fru.
+Von dem Fischer un siine Fru.

Daar was mal eens een Fischer un siine Fru, de waanten tosamen in’n Pispott, dicht an de See
– un de Fischer ging alle Dage hen un angelt, un ging he hen lange Tid.
```

License
=======

Copyright 2018 eBay Inc.
Developer/Architect: Daniel Stein

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.

Third-Party Notices
-------------------

This module incorporates material from the third party code listed below:

https://github.com/chadbraunduin/markdown.bash
Author: Chad Braun-Duin, https://github.com/chadbraunduin

Use of this source code is governed by an MIT-style
license that can be found in the LICENSE file or at
https://opensource.org/licenses/MIT.
