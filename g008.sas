%let progname = g008.sas;
ods pdf file = "g008.pdf"  style=styles.journal;

* input: ma_data2.csv
* does: - Fixed effects analysis of odds ratios in a set of 2*2 tables
          Loglinear model, heterogeniety of odds ratios test
          No 0 margins and n>=20
*********************************************;
libname X "";
title "&progname: No 0 margins and n>=20, loglinear model (fixed effects)";
%let csv = ma_data.csv;
*********************************************;

title2 "&csv";
proc import datafile="&csv" out=A replace;
  guessingrows =  max;
  run;


data A;
  set A (rename=(a=y11 b=y10 c=y01 d=y00)); * rows=rsfMRI, cols=comparative;

  n = y00 + y01 + y10 + y11;
  y0d = y00 + y01;
  yd0 = y00 + y10;
  y1d = y10 + y11;
  yd1 = y01 + y11;

  if ( 5 = modality) then modality = 1; else
  if (14 = modality) then modality = 4; 
  label modality = "Modality (0/1/2/3/4)";

  zero_margins = (0 = y0d) + (0 = y1d) + (0 = yd0) + (0 = yd1);
  if (n >= 20 and 0 = zero_margins);
  label zero_margins = "Number of zero margins";

  label y11 = "a";
  label y10 = "b";
  label y01 = "c";
  label y00 = "d";

  run;


proc sort data=A; by n id; run;
title2 "Sorted by n";
proc print    data=A; 
  var  id y00 y01 y10 y11 n zero_margins modality;
  sum     y00 y01 y10 y11 n;
  run;
*********************************************;

%macro m(a, b, c, d, row, col);
  count = &a; &row=1; &col=1; output;
  count = &b; &row=1; &col=2; output;
  count = &c; &row=2; &col=1; output;
  count = &d; &row=2; &col=2; output;
%mend;

data A;
  set A;
  %m(y00, y01, y10, y11, rsfMRI, compar);
  keep  id n rsfMRI compar count modality;
  label id = "Study ID"; 
  label n  = "Sample size";
  label rsfMRI =  "rsfMRI (1=-, 2=+)";
  label compar =  "Comparative (1=-, 2=+)";
  run;

proc contents data = A order=varnum noprint out=C(rename= name=variable); run;
title2 "Variables";
proc print data=C; var label; id variable; run;


title2 "1. Log(odds ratio): 0";
proc genmod data=A;
  class id rsfmri compar;
  model count =  id|rsfmri id|compar / d=p;
  lsmeans;
  run;

title2 "2. Log(odds ratio): 1";
proc genmod data=A;
  class id rsfmri compar;
  model count =  id|rsfmri id|compar rsfmri|compar / d=p;
  lsmeans;
  run;

title2 "3. Log(odds ratio): 1+modality";
ods output covb = covb ParameterEstimates=ParameterEstimates;
/*ods trace on;*/
proc genmod data=A;
  class id rsfmri compar modality;
  model count =  id|rsfmri id|compar rsfmri|compar|modality / d=p covb;
run;

title2 "4. Log(odds ratio): 1+id";
ods output covb = covb ParameterEstimates=ParameterEstimates;
proc genmod data=A;
  class id rsfmri compar modality;
  model count =  id|rsfmri|compar / d=p covb; 
  run;

/*title2 "3.a Log(odds ratio): 1+modality";*/

/*data A;*/
/*set A;*/
/*rsfMRI_c2 = (rsfMRI = 1);*/
/*compar_c2 = (compar=1);*/
/*run;*/
/*ods pdf file = "g008-jv.rtf"  style=styles.journal;*/
/*ods output covb = covb ParameterEstimates=ParameterEstimates;*/
/*proc genmod data=A;*/
/*  class id modality;*/
/*  model count =  id|rsfMRI_c2 id|compar_c2 rsfMRI_c2|compar_c2|modality / covb d=p;*/
/*  run;*/
/*ods pdf close;*/

/*export data to file called data.csv*/
proc export data=covb
    outfile="covb_studylevel.csv"
    dbms=csv
    replace;
run;

proc export data=ParameterEstimates
    outfile="ParameterEstimates_studylevel.csv"
    dbms=csv
    replace;
run;



