# (stub) define style options for html output

# Copyright 2018 eBay Inc.
# Developer: Daniel Stein
#
# Use of this source code is governed by an MIT-style license
# that can be found in the LICENSE file or at https://opensource.org/licenses/MIT.
source $( dirname ${BASH_SOURCE} )/../termColorFont/termColorFont.sh

# default style options for html
function REPORT_HTML_STYLE_DEFAULT() {
cat << EOF
<STYLE type="text/css">
body {
     font-family: Arial, sans-serif;
     font-size:14px;
   }
h1 {
     font-size:18px;
     background-color:#${TERM_COLOR_G[3]};
     padding: 5px 10px 5px 10px;
     color:#FFFFFF;
   } 
h2 {   
     font-size:18px;
     background-color:#FFFFFF;
     padding: 5px 10px 5px 10px;
     color:#${TERM_COLOR_G[3]};
   }
p {
     text-indent:30px;
     width:600px;
}
strong {
     font-weight: bold;
     color:#${TERM_COLOR_Y[5]};
}
em {
     color:#${TERM_COLOR_Y[5]};
     font-style:normal;
}
pre {
     font-family: monospace;
     background:#DDD;
     font-size: 95%;
     line-height: 140%;
     width:auto;
     display: block;
     padding-left:15px;
}
code {
     font-family: monospace;
     background:#DDD;
   }
table {
     padding: 5px 10px 5px 10px;
}
th {
     background:#${TERM_COLOR_A[4]};
     color:#FFF;
     font-weight: normal;
     font-style:normal;
}
.row0 {
     background:#${TERM_COLOR_A[2]};
}
.row1 {
     background:#${TERM_COLOR_A[1]};
}
.emphasis {
     background:#${TERM_COLOR_S[2]};
}
.strong {
     background:#${TERM_COLOR_S[4]};
     color:#FFF;
}
.div_diff {
     font-family: monospace;
     font-size: 95%;
     line-height: 140%;
     width:auto;
     display: block;
     padding-left:15px;
     border: solid 1px black;
}
.diff_default {
     color:#000;
}
.diff_only {
     color:#${TERM_COLOR_O[4]};
}
.diff_diff {
     font-weight: bold;
     color:#${TERM_COLOR_R[4]};
}
.diff_oldfile {
     font-weight: bold;
     color:#${TERM_COLOR_O[4]};
}
.diff_newfile {
     font-weight: bold;
     color:#${TERM_COLOR_A[4]};
}
.diff_statistics {
     background:#${TERM_COLOR_S[3]};
}
.diff_old {
     background:#${TERM_COLOR_O[3]};
}
.diff_new {
     background:#${TERM_COLOR_A[3]};
}
</STYLE>
EOF
}

