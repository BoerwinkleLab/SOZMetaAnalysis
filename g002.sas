%let progname = g002.sas;
ods pdf file = "g002.pdf"  style=styles.journal;

* input:
* xref:
* does: -
*********************************************;
libname X "";
title "&progname:                        ";
*********************************************;
%macro m(a, b, c, d, row, col);
  count = &a; &row=1; &col=1; output;
  count = &b; &row=1; &col=2; output;
  count = &c; &row=2; &col=1; output;
  count = &d; &row=2; &col=2; output;
%mend;
*********************************************;

data A;
  input s a b c d;
  %m(a, b, c, d, row, col);
  cards;
  1 38 1 3 22
  2 18 7 8 16
  run;

proc freq data=A;
  tables row*col;
  exact oddsratio;
  weight count;
  by s;
  run;

proc freq data=A;
  tables s*row*col / exact oddsratio cmh;
  weight count;
  run;

proc genmod data=A;
  class s row col;
  model count = s|row|col / d=p;
  run;

proc genmod data=A;
  class s row col;
  model count = s|row s|col row|col / d=p;
  run;

data B;
  set A;
  row=1; y = a; m=a+b; output;
  row=2; y = c; m=c+d; output;
  run;

title2 "Exact "; 
proc logistic data=B exactonly;
  class s row / param=ref;
  model y/m = row; 
  exact row 
    / estimate=odds;
  by s;
  run;




