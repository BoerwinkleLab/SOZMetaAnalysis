%let progname = g013.sas;
ods pdf file = "g013.pdf"  style=styles.journal;

* input:
* xref:
* does: - K 2x2 tables
*********************************************;
libname X "";
title "&progname:                        ";
*********************************************;

* Example with two 2*2 tables;
data A0;
  input study $ a b c d compar;
  label compar = "Modality"; 
  cards;
  MOD0_C17   4   6   2  30     0
  MOD1_B10  12   6  10  16     1
  MOD1_R16   0   3   3  28     1
  MOD3_K19  18   7   8  16     3
  MOD3_L14   1   5   2  21     3
  MOD4_B17   0   2   7  27     4
  MOD4_B19  38   1   3  22     4
  run;

*********************************************;

data A;
  set A0; 
  count = a; row=1; col=1; output;
  count = b; row=1; col=2; output;
  count = c; row=2; col=1; output;
  count = d; row=2; col=2; output;
  keep study row col count;
  run;

*********************************************;

title2 "1. proc freq exact CI for the odds ratio in each table";
proc freq data=A;
  tables row*col;
  exact oddsratio;
  weight count;
  by study;
  run;
*********************************************;

data B;
  set A0;
  row=1; y = a; m=a+b; output;
  row=2; y = c; m=c+d; output;
  keep study compar row y m;
  run;
*********************************************;

* exact only;
title2 "2. proc logistic, exactonly, by study";
proc logistic data=B exactonly;
  class study compar row / param=ref;
  model y/m = row; 
  exact row / estimate=odds;
  by study;
  run;
*********************************************;

* exact only;
title2 "3. Homogeniety of the O.R. assumed, exactonly, by compar";
proc sort data=B; by compar; run;
proc logistic data=B exactonly;
  class study compar row / param=ref;
  model y/m = study row;
  exact row / estimate=odds;
  by compar;
  run;

