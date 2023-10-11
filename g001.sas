%let progname = g001.sas;
ods pdf file = "g001.pdf"  style=styles.journal;

* input: ma_data2.csv
* does: - Descriptive
*********************************************;
libname X "";
title "&progname:";
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
  label zero_margins = "Count of zero margins";

  label y11 = "a";
  label y10 = "b";
  label y01 = "c";
  label y00 = "d";

  run;

proc contents data = A order=varnum noprint out=C(rename= name=variable); run;
title2 "Variables";
proc print data=C;  var label type length format; id variable; run;

proc sort data=A; by id n; run;
title2 "Sorted by id";
proc print    data=A; 
  var  id y00 y01 y10 y11 n zero_margins modality;
  sum     y00 y01 y10 y11 n;
  run;

proc sort data=A; by n id; run;
title2 "Sorted by n";
proc print    data=A; 
  var  id y00 y01 y10 y11 n zero_margins;
  sum     y00 y01 y10 y11 n;
  run;

title2 "Modality";
proc freq data=A;
  tables modality * modality_type / missing nocol norow nopercent;
  run;
