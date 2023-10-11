%let progname = g006.sas;
ods pdf file = "g006.pdf"  style=styles.journal;

* input: ma_data2.csv
* xref:

* does: - Mixed models
        Three random effects per study
          
*********************************************;
libname X "";
title "&progname: Three random effects per study ";
%let csv = ma_data.csv;
*********************************************;

title2 "&csv";
proc import datafile="&csv" out=A replace;
  guessingrows =  max;
  run;

data A;
  set A 
    (rename=(a=y11 b=y10 c=y01 d=y00)); * rows=rsfMRI, cols=comparative;

  n = y00 + y01 + y10 + y11;
  if not missing(n); 
  y1d = y10 + y11;
  yd1 = y01 + y11;
  keep id y00 y01 y10 y11 n;
  label y11 = "a";
  label y10 = "b";
  label y01 = "c";
  label y00 = "d";
  run;

proc sort data=A; by n id; run;
******************************************************************;

title2 "Three random effects per study";
proc nlmixed data=A qpoints=25 cov corr ecov ecorr;
  parms 
    beta1         2.3310
    beta2         1.8631
    beta3       0.006937
    log_g11       0.8691
    log_g22       0.3527
    log_g33       2.1988
  ; 

  eta1 = u1 + beta1;
  eta2 = u2 + beta2;
  eta3 = u3 + beta3;
  nu1 = 1/(1+exp(-eta1));  * margin 1;
  nu2 = 1/(1+exp(-eta2));  * margin 2;
  psi = exp(eta3);         * odds ratio;
  g11 = exp(log_g11);      * variance 1;
  g22 = exp(log_g22);      * variance 2;
  g33 = exp(log_g33);      * variance 3;

  * Compute p11 (cell 'd' in the 2x2 table);
  a_ = 1 - psi;
  if (abs(a_) < 1e-6) then p11 = nu1*nu2;
  else do;
    b_  = 1 - a_ * (nu1 + nu2);
    c_  = -psi * nu1 * nu2;
    p_  = -0.5 * (b_ + sign(b_) * sqrt(b_**2 - 4*a_*c_));
    r1_ = p_ / a_;
    r2_ = c_ / p_;
    if (r2_ > 0) then p11=r2_; else p11=r1_;    * Mardia's root;
  end;
  p10 = nu1 - p11;
  p01 = nu2 - p11;
  p00 = 1 - (nu1 + p01);
  ll = y00*log(p00)+y01*log(p01)+y10*log(p10)+y11*log(p11);

  model y00 ~ general(ll);
  random u1 u2 u3 ~ normal([0,0,0],[g11, 0, g22, 0, 0, g33]) subject = id;

  estimate "g11:"  g11;
  estimate "g22:"  g22;
  estimate "g33:"  g33;
  ods output ParameterEstimates=PARMS  CovMatParmEst=COV ;
  predict  eta1  out=PRED1(rename= (pred=eta1 lower=eta1l upper=eta1u));
  predict  eta2  out=PRED2(rename= (pred=eta2 lower=eta2l upper=eta2u));
  predict  eta3  out=PRED3(rename= (pred=eta3 lower=eta3l upper=eta3u));

  run;

proc print data=PRED1; run;
proc print data=PRED2; run;
proc print data=PRED3; run;

data PRED;
  merge PRED1 PRED2 PRED3;
  p1 = 1/(1+exp(-eta1));
  p1l= 1/(1+exp(-eta1l));
  p1u= 1/(1+exp(-eta1u));
  p2 = 1/(1+exp(-eta2));
  p2l= 1/(1+exp(-eta2l));
  p2u= 1/(1+exp(-eta2u));
  oddsratio = exp(eta3);
  or95pil   = exp(eta3l);
  or95piu   = exp(eta3u);
  run;

title2 "Prediction"; 
proc print data=PRED; 
  var id n p1 p2 oddsratio p1l p1u p2l p2u or95pil or95piu;
  run;

title2 "Prediction. eta3 is the log odds ratio";
proc print data=PRED; 
  var id n p1 p2 eta3      p1l p1u p2l p2u eta3l eta3u;
  run;
