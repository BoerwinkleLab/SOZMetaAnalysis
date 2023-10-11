%let progname = g003.sas;
ods pdf file = "g003.pdf"  style=styles.journal;

* input: ma_data2.csv
* does: - Fixed effects analysis
          Empirical logistic transform
*********************************************;
libname X "";
title "&progname: The odds ratio, empirical logistic transform (fixed effects)";
%let csv = ma_data.csv;
*********************************************;

title2 "&csv";
proc import datafile="&csv" out=A replace;
  guessingrows =  max;
  run;

data A;
  set A (rename=(a=y11 b=y10 c=y01 d=y00)); * rows=rsfMRI, cols=comparative;

  n = y00+y01+y10+y11;
  if not missing(n); 
  k = 0.5;
  oddsratio = ((y00+k)*(y11+k))/((y01+k)*(y10+k));
  se = sqrt(1/(y00+k) + 1/(y11+k) + 1/(y01+k) + 1/(y10+k));
  or95cil = oddsratio / exp(1.96 * se);
  or95ciu = oddsratio * exp(1.96 * se);
  y1d = y10 + y11;
  yd1 = y01 + y11;
  p1 = y1d / n;  * rsfMRI;
  p2 = yd1 / n;  * comparative;
/*  keep id n p1 p2 oddsratio or95cil or95ciu se;*/
  label id = "Study ID"; 
  label n  = "Sample size";
  label oddsratio =  "Odds ratio"; 
  label se      = "SE of the log odds ratio";
  label or95cil = "Odds ratio, 95% CI, lower limit";
  label or95ciu = "Odds ratio, 95% CI, upper limit";
  label p1 = "Prevalence of + for rsfMRI"; 
  label p2 = "Prevalence of + for comparative";
  run;

proc contents data = A order=varnum noprint out=C(rename= name=variable); run;
title2 "Variables";
proc print data=C; var label; id variable; run;

title2 "Sorted by id";
proc sort     data=A; by id; run;
proc print    data=A; 
  var id n p1 p2 oddsratio or95cil or95ciu;
  run;

title2 "Sorted by n ";
proc sort     data=A; by n id; run;
proc print    data=A; 
  var id n p1 p2 oddsratio or95cil or95ciu;
  run;

title2 "Sorted by odds ratio";
proc sort     data=A; by oddsratio id; run;
proc print    data=A; 
  var id n p1 p2 oddsratio or95cil or95ciu;
  run;

title2 "Sorted by se";
proc sort     data=A; by se id; run;
proc print    data=A; 
  var id n p1 p2 oddsratio or95cil or95ciu se;
  run;
