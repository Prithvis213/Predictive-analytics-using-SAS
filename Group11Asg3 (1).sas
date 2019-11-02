libname cc 'H:\';
/*Question1*/
data vac;
set cc.vacation19;
run;

/* Check contents of data */
proc contents data=vac;
run;

/* Convert kids to dummy variables */
data vac1; set vac;
if kids = 1 then kids1 = 1; else kids1 = 0;
if kids = 2 then kids2 = 1; else kids2 = 0;
if kids = 3 then kids3 = 1; else kids3 = 0;
if kids = 4 then kids4 = 1; else kids4 = 0;run;

/* Data Characteristics */
proc means data=vac1 n nmiss;
run;

proc freq;
run;

proc univariate;
run;

/* Checking Distribution of all Variables */
proc univariate data=vac1 noprint;
   histogram;run;

 
/* Regression */

/* Checking for Influence observations and Multi-Collinearity */ 

proc reg data=vac1;
model miles= income age kids1 kids2 kids3 kids4 / stb collin vif influence;
run;

/* Regression */
proc reg data=vac1;
model miles= income age kids1 kids2 kids3 kids4;
run;

/* Check for Heteroskedasticity */
proc model data=vac1;
parms b0 b1 b2 b3 b4 b5 b6;
miles = b0 + b1*income + b2*age + b3*kids1 + b4*kids2 + b5*kids3 + b6*kids4;
fit miles/white out=res1 outresid; 
run;

/* Weighted Least Squares */
proc model data=vac1;
parms b0 b1 b2 b3 b4 b5 b6;
income_inv=1/income;
miles = b0 + b1*income + b2*age + b3*kids1 + b4*kids2 + b5*kids3 + b6*kids4;
fit miles/white; 
weight income_inv;
run;

data vac2;set vac1;
wmiles= miles/income;
wage= age/income;
wkids1= kids1/income;
wkids2= kids2/income;
wkids3= kids3/income;
wkids4= kids4/income;
wincome=1/income;
run;

proc model data=vac2;
parms b0 b1 b2 b3 b4 b5 b6;
wmiles = b6 + b1*wage + b2*wkids1 + b3*wkids2 + b4*wkids3 + b5*wkids4 + b0*wincome;
fit wmiles / white ;run;

/* Weighted Least Squares with income^2 */
proc model data=vac1;
parms b0 b1 b2 b3 b4 b5 b6;
income_inv2=1/(income*income);
miles = b0 + b1*income + b2*age + b3*kids1 + b4*kids2 + b5*kids3 + b6*kids4;
fit miles/white; 
weight income_inv2;
run;

data vac3;set vac1;
smiles= miles/(income*income);
sage= age/(income*income);
skids1= kids1/(income*income);
skids2= kids2/(income*income);
skids3= kids3/(income*income);
skids4= kids4/(income*income);
sincome=1/(income*income);
run;

proc model data=vac3;
parms b0 b1 b2 b3 b4 b5 b6;
wmiles = b6 + b1*wage + b2*wkids1 + b3*wkids2 + b4*wkids3 + b5*wkids4 + b0*wincome;
fit wmiles / white ;run;

/*Question2*/

data sal;
input week sales;
cards;
1	160
2	390
3	800
4	995
5	1250
6	1630
7	1750
8	2000
9	2250
10	2500
;
run;

proc print data=sal;run;

data new;set sal;
cumd + sales;lagd =lag(cumd);sqrd=lagd*lagd;
proc reg outest=coeff;model sales = lagd sqrd;run;
proc print data=coeff;run;
data a2;set coeff;
M=(-lagd-(sqrt(lagd*lagd-4*intercept*sqrd)))/(2*sqrd);
p=intercept/m;
q=p+lagd;
tstar=log(q/p)*1/(p+q);
sstar=M*(p+q)*(p+q)/(4*q);
proc print;run;
data new2;set new;
M=26225.01;p=0.020581;q=0.33071;
array nt{10} t1-t10 (0 0 0 0 0 0 0 0 0 0);
do i = 1 to 10;
Pdload=p*(M-nt[i])+ q*(nt[i]/M)*(M-nt[i]);
nt[i]=nt[i]+pdload;
end;
proc gplot;plot pdload*week sales*week/overlay;run;
proc print data=new2; var week sales Pdload;
run;

/*Question3*/
libname w3 'H:\Ass3';
DATA cj;
INPUT brand	$ scent $ soft $ oz pr s1 s2 s3 s4 s5;
CARDS;
complete	fresh	n	48	4.99	1	3	3	2	2
complete	fresh	y	32	2.99	1	3	3	5	5
complete	lemon	n	32	2.99	1	2	7	5	1
complete	lemon	y	64	3.99	1	9	5	8	1
complete	U		n	64	3.99	1	9	7	8	7
complete	U		y	48	4.99	1	3	3	2	3
Smile		fresh	n	64	2.99	1	9	9	9	6
Smile		fresh	y	48	3.99	1	7	7	6	5
Smile		lemon	n	48	3.99	1	7	7	6	1
Smile		lemon	y	32	4.99	1	1	1	1	1
Smile		U		n	32	4.99	1	1	3	1	2
Smile		U		y	64	2.99	1	9	3	9	9
Wave		fresh	n	32	3.99	7	1	7	4	5
Wave		fresh	y	64	4.99	5	5	3	3	2
Wave		lemon	n	64	4.99	5	5	5	3	1
Wave		lemon	y	48	2.99	9	9	5	7	1
Wave		U		n	48	2.99	9	9	5	7	7
Wave		U		y	32	3.99	7	1	5	4	5
Wave		lemon	n	64	2.99	8	9	6	9	3
Smile		lemon	n	32	4.99	2	1	3	2	1
Smile		fresh	y	48	2.99	2	8	4	5	5
complete	U		y	32	2.99	2	4	2	5	6
complete	lemon	y	48	3.99	2	6	6	6	1
;
RUN;

PROC FREQ data = cj; table brand scent soft oz pr; RUN;

/*Dummy Varibales*/
data cj1;
set cj;
br_smile = 0; br_wave = 0; sc_u = 0; sc_fresh = 0; so_n = 0; oz_m = 0;oz_l = 0; pr_m = 0; pr_h = 0;
if brand = "Smile" then br_smile = 1;
if brand = "Wave" then br_wave = 1;
if scent = 'U' then sc_u = 1;
if scent = "fresh" then sc_fresh = 1;
if soft = "n" then so_n = 1;
if oz = 48 then oz_m = 1;
if oz = 64 then oz_l = 1;
if pr = 3.99 then pr_m = 1;
if pr = 4.99 then pr_h = 1;
PROC PRINT;RUN;

%macro regress;
%do i = 1 %TO 5;
PROC REG DATA=cj1 OUTEST=OUT&i;
       MODEL s&i = br_smile br_wave sc_u sc_fresh so_n oz_m oz_l pr_m pr_h/STB;
RUN;
%END;
%MEND regress;
%regress;

DATA INP1;SET OUT1;
PROC PRINT DATA=INP1;
RUN;

%MACRO PRINT2;
%DO i=1 %TO 5;
DATA INP&i;SET OUT&i;
PROC PRINT DATA=INP&i;
RUN;
%END;
%MEND PRINT2;

%PRINT2;



%MACRO Utility;
%DO i = 1 %TO 5;
       data Util&i;
       set INP&i;

util_complete = -(br_smile + br_wave)/3;
util_smile = ((2*br_smile) - br_wave)/3;
util_wave = ((2*br_wave) - br_smile)/3;

util_lemon = -(sc_u + sc_fresh)/3;
util_u = ((2*sc_u) - sc_fresh)/3;
util_fresh = ((2*sc_fresh) - sc_u)/3;

util_small = -(oz_m + oz_l)/3;
util_med = ((2*oz_m) - oz_l)/3;
util_lar = ((2*oz_l) - oz_m)/3;

util_low = -(pr_m + pr_h)/3;
util_mid = ((2*pr_m) - pr_h)/3;
util_high = ((2*pr_h) - pr_m)/3;

util_y = -so_n/2;
util_n = so_n /2;

BrandMaxMinDiff = max(util_wave, util_complete, util_smile) - min(util_wave, util_complete, util_smile);
ScentMaxMinDiff = max(util_u, util_fresh, util_lemon) - min(util_u, util_fresh, util_lemon);
SoftMaxMinDiff = max(util_y,util_n) - min(util_y,util_n);
OZMaxMinDiff = max(util_small , util_med, util_lar) - min(util_small , util_med, util_lar);
PriceMaxMinDiff = max(util_low, util_mid, util_high) - min(util_low, util_mid, util_high);

Total = (BrandMaxMinDiff + ScentMaxMinDiff+ SoftMaxMinDiff + OZMaxMinDiff + PriceMaxMinDiff);

RelBrand = BrandMaxMinDiff / Total;
RelScent = ScentMaxMinDiff / Total;
RelSoft = SoftMaxMinDiff / Total;
RelOZ = OZMaxMinDiff / Total;
RelPrice = PriceMaxMinDiff / Total;

RUN;
%END;   
%MEND Utility;

%Utility;

DATA Question1(KEEP=_DEPVAR_ util_complete util_smile util_wave util_u util_lemon util_fresh util_y util_n util_small util_med util_lar util_low util_mid util_high BrandMaxMinDiff ScentMaxMinDiff SoftMaxMinDiff OZMaxMinDiff PriceMaxMinDiff Total RelBrand RelScent RelSoft RelOZ RelPrice);
MERGE Util1 Util2 Util3 Util4 Util5;
BY _DEPVAR_;
PROC PRINT;RUN;

PROC TRANSPOSE DATA=Question1 OUT=Question1_format NAME=VARIABLES PREFIX=RESP;PROC PRINT;RUN;


%MACRO Prediction;
%DO i=1 %TO 5;
     data QS2&i (KEEP=_DEPVAR_ Util_A Util_B Util_C Util_D Util_E PR_A PR_B PR_C PR_D PR_E);
     set Util&i;
 
Util_A = util_complete + util_lemon + util_y + util_lar + util_low;
Util_B = util_smile + util_fresh + util_y + util_med + util_low;
Util_C = util_smile + util_u + util_y + util_med + util_mid;
Util_D = util_wave + util_u + util_y + util_med + util_low;
Util_E = util_smile + util_u + util_n + util_med + util_low;


TOTAL_EXP= exp(Util_A) + exp(Util_B) + exp(Util_C) + exp(Util_D) + exp(Util_E);

PR_A=exp(Util_A)/TOTAL_EXP;
PR_B=exp(Util_B)/TOTAL_EXP;
PR_C=exp(Util_C)/TOTAL_EXP;
PR_D=exp(Util_D)/TOTAL_EXP;
PR_E=exp(Util_E)/TOTAL_EXP;

RUN;
%END;
%MEND Prediction;

%Prediction;

%MACRO PROB_PRINT;
%DO i=1 %TO 5;
PROC PRINT DATA=QS2&i;
RUN;
%END;
%MEND PROB_PRINT;

%PROB_PRINT;

%MACRO R2C;
%DO j=1 %TO 5;
PROC TRANSPOSE DATA=QS2&j OUT=TRANP&j NAME=UTILITY PREFIX=RESP&j; 
RUN;
%END;
%MEND R2C;

%R2C;
/* Sort By Utility */
%MACRO SORDTR;
%DO j=1 %TO 5;
PROC SORT DATA=TRANP&j OUT=FINAL&j;
BY UTILITY;
RUN;
%END;
%MEND SORDTR;

%SORDTR;

/* Merge the all files into single file */
DATA FINAL;
MERGE FINAL1 FINAL2 FINAL3 FINAL4 FINAL5;
BY UTILITY;RUN;

PROC PRINT DATA=FINAL;RUN;

/* Print Predicted Values for each Respondent */
DATA detergent; SET FINAL(FIRSTOBS=1 OBS=5);
PROC PRINT DATA=detergent;RUN;

/* Predict Market Share  */
DATA detergent3; SET detergent;
MS=(RESP11+RESP21+RESP31+RESP41+RESP51)/5; RUN;

PROC PRINT DATA=detergent3;RUN;
