%let progname = g004.sas;
ods pdf file = "g004.pdf" style=styles.journal;

* input: ma_data2.csv

* does: - Separate mixed models for the two margins
*********************************************;
libname X "";
title "&progname: Separate mixed models for rsfMRI and comparative";
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
  y1d = y10 + y11;
  yd1 = y01 + y11;
  p1raw = y1d/n;
  p2raw = yd1/n;
  run;

******************************************************************;
%macro m(y, pred, ttl, out);
title2  &ttl;
proc nlmixed data=A qpoints=25 cov corr ecov ecorr;

  parms 
    beta       2.1
    log_sigma  0.33
  ; 

  eta = u + beta;
  sigma   = exp(log_sigma);
  p = 1/(1+exp(-eta));
  model &y  ~ binomial(n, p);
  random u ~ normal(0, sigma*sigma) subject = id;

  *ods output ParameterEstimates=PARMS  CovMatParmEst=COV ;
  predict eta out=&out (rename= pred=&pred);

  run;
%mend;
******************************************************************;

%m(y1d, eta1, "1. rsfMRI", PRED1);

data PRED1;
  set PRED1;
  p1 = 1/(1+exp(-eta1));
  p1l = 1/(1+exp(-lower));
  p1u = 1/(1+exp(-upper));
  run;

proc sort data=PRED1; by n id; run;
proc print data=PRED1;
  var id n p1raw p1 p1l p1u;
  run;


%m(yd1, eta2, "2. Comparative", PRED2);

data PRED2;
  set PRED2;
  p2 = 1/(1+exp(-eta2));
  p2l = 1/(1+exp(-lower));
  p2u = 1/(1+exp(-upper));
  run;

proc sort data=PRED2; by n id; run;
proc print data=PRED2;
  var id n p2raw p2 p2l p2u;
  run;

data PRED;
  merge PRED1 PRED2;
  run;

title2 "Both";
proc print data=PRED;
  var id n p1raw p1 p1l p1u p2raw p2 p2l p2u;
  run;
