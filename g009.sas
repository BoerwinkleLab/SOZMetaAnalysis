%let progname = g009.sas;
ods pdf file = "g009.pdf"  style=styles.journal;

* input: ma_data2.csv
* does: - Fixed effects analysis of odds ratios
          Exact confidence intervals for odds ratios
          No 0 margins, of course
*********************************************;
libname X "";
title "&progname: Exact confidence intervals for odds ratios (fixed effects)";
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
  zero_margins = (0 = y0d) + (0 = y1d) + (0 = yd0) + (0 = yd1);
  if (0 = zero_margins);
  label y11 = "a";
  label y10 = "b";
  label y01 = "c";
  label y00 = "d";
  label y00 = "d";
  label zero_margins = "Count of zero margins";
  label id = "Study ID"; 
  run;

proc sort data=A; by n id; run;
title2 "Sorted by n";
proc print    data=A; 
  var  id n y00 y01 y10 y11  zero_margins;
  sum     n y00 y01 y10 y11  zero_margins;
  run;
*********************************************;
data B;
  set A;
  row=1; y = y00; m=y0d; output;
  row=2; y = y10; m=y1d; output;
  run;

title2 "  ";
proc logistic data=B exactonly;
  class n row / param=ref;
  model y/m = row; 
  exact row / estimate=parm;    *  / estimate=odds;
  by n;   * all n's are different, already sorted by n;
  run;

endsas;


Obs  id               y00    y01    y10    y11    n     est          lower  upper
                                                      
  1  Gnanadas 2017      0      1      1      4    6     5.000*         0     95.000
  2  Hunyadi 2014       0      3      3      4   10     0.478*         0      4.046
  3  Hunyadi 2015a      0      7      7      4   18     0.081*         0      0.515
  4  Lee 2014           1      5      2     21   29     2.038     0.030      47.122
  5  Reyes 2016         0      3      3     28   34     2.716*         0     21.863
  6  Boerwinkle 2017    0      2      7     27   36     1.701*         0     14.933
  7  Chen 2017          4      6      2     30   42     9.243      1.060    124.400
  8  Bettus 2010       12      6     10     16   44     3.112      0.777     13.775
  9  Khoo 2019         18      7      8     16   49     4.955      1.315     20.833
 10  Boerwinkle 2019   38      1      3     22   64   221.743     24.007   >999.999

