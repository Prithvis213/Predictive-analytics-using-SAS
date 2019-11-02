libname ss 'h:\';

data spag;
infile "H:\THEEND.csv" DLM=',' firstobs=2;
format UPC $20.;
input IRI_KEY WEEK SY GE VEND ITEM UNITS DOLLARS F $ D PR UPC $;
run;
proc print data=spag (obs=10);run;

data prod;
infile "H:\prod_sauce.csv" DLM=',' firstobs=2;
format UPC $20.;
input L1 $ L2 $ L3 $ L4 $ L5 $ L9 $ Level $ UPC $ SY  GE  VEND ITEM SPECIFICATION $ VOL_EQ PRODUCT_TYPE $ FLAVOR_SCENT $ ADDITIVES $ TYPE_OF_ITALIAN_SAUCE $ STYLE $ CONSISTENCY $ HEAT_LEVEL $;
run;

proc print data=prod (obs=10);run;

proc sort data=spag; by UPC;
proc sort data=prod; by UPC;
data spag_merge;
merge spag (IN=aa) prod; if aa;by UPC; run;
proc print data=spag_merge (obs=4000);run;

PROC EXPORT data = spag_merge outfile = "'H:\spagsauc_merged.csv" dbms = dlm replace ;
delimiter = ',';
RUN;

/*Q1*/
proc means data = spag_merge sum; 
class L5;
var DOLLARS;
output out = a2(drop = _type_ _freq_) sum=Dollars ;
format L5 $20.;
run; 


proc print data = a2;run;

proc sort data = a2; by descending Dollars; run;

proc print data = a2;run;

PROC EXPORT data = a2 outfile = "'H:\top_brands.csv" dbms = dlm replace ;
delimiter = ',';
RUN;

/*Q2*/
proc means data = spag_merge sum; 
class L4;
var DOLLARS;
output out = a3(drop = _type_ _freq_) sum=Dollars ;
run; 


proc print data = a3;run;

proc sort data = a3; by descending Dollars; run;

proc print data = a3;run;

PROC EXPORT data = a3 outfile = "'H:\top_companies.csv" dbms = dlm replace ;
delimiter = ',';
RUN;

/*Q3*/
LIBNAME cc 'E:\Prithvi\';

DATA cc.spagsauc_data_new(keep= IRI_KEY WEEK L1 L2 L3 L4 L5 VOL_EQ UNITS DOLLARS FEATURE DISP PR PRODUCT_TYPE FLAVOR_SCENT ADDITIVES TYPE_OF_ITALIAN_SAUCE STYLE CONSISTENCY HEAT_LEVEL UPC OU EST_ACV MARKET_NAME OPEN ClSD MSK_NAME);
infile 'E:\Soham\Total_Merged-1.csv' firstobs=2 DLM= ',' DSD MISSOVER;
length UPC $17. IRI_KEY $12. WEEK_1 SY $2. GE $1. VEND $5. ITEM $5. UNITS_1 DOLLARS_1 F D_1 PR L1 $33. L2 $17. L3 $28. L4 $28. L5 $29. 
	   L9 $32. Level $5. SY_1 $2. GE_1 $1. VEND_1 $5. ITEM_1 $5. specification $80. VOL_EQ_1 PRODUCT_TYPE $19. FLAVOR_SCENT $12. ADDITIVES $20. TYPE_OF_ITALIAN_SAUCE $20. STYLE $19.
	   CONSISTENCY $12. HEAT_LEVEL $20. OU $2. EST_ACV MARKET_NAME $22. OPEN CLSD MSK_NAME $13.;

INPUT  UPC $ IRI_KEY $ WEEK SY $ GE $ VEND $ ITEM $ UNITS_1 DOLLARS_1 F D_1 PR L1 $ L2 $ L3 $ L4 $ L5 $ 
	   L9 $ Level $ SY_1 $ GE_1 $ VEND_1 $ ITEM_1 $ specification $ VOL_EQ_1 PRODUCT_TYPE $ FLAVOR_SCENT $ ADDITIVES $ TYPE_OF_ITALIAN_SAUCE $ STYLE $
	   CONSISTENCY $ HEAT_LEVEL $ OU $ EST_ACV MARKET_NAME $ OPEN CLSD MSK_NAME $;
	   

L1 = strip(L1);
L2 = strip(L2);
L3 = strip(L3);
L4 = strip(L4);
L5 = strip(L5);
L9 = strip(L9);
UPC = strip(UPC);
specification = strip(specification);
PRODUCT_TYPE = strip(PRODUCT_TYPE);
FLAVOR_SCENT= strip(FLAVOR_SCENT);
ADDITIVES = strip(ADDITIVES);
TYPE_OF_ITALIAN_SAUCE = strip(TYPE_OF_ITALIAN_SAUCE);
STYLE = strip(STYLE);
CONSISTENCY = strip(CONSISTENCY);
HEAT_LEVEL = strip(HEAT_LEVEL);
OU = strip(OU);
Market_Name = strip(Market_Name);
MskdName = compress(MskdName);
VOL_EQ = VOL_EQ_1*1;
DOLLARS = DOLLARS_1*1;
UNITS = UNITS_1*1;
D = D_1 * 1;


if D = 1 or D = 2 then DISP = 1; else DISP = 0;
if F ne ('NONE') then FEATURE = 1; else FEATURE = 0;
if L5 = 'PREGO' then L5 = 'PREGO';
else if L5 = 'HUNTS' then L5 = 'HUNTS';
else if L5 = 'RAGU OLD WORLD STYLE' then L5 = 'RAGU OLD WORLD STYLE';
else if L5 = 'RAGU' then L5 = 'RAGU';
else if L5 = 'CLASSICO' then L5 = 'CLASSICO';
else if L5 ='FIVE BROTHERS' then L5 = 'FIVE BROTHERS'; 
else L5 = 'Others'; 
run;

PROC PRINT DATA=cc.spagsauc_data_new(obs=10);run;

PROC CONTENTS DATA = cc.spagsauc_data1;run;

proc means data = cc.spagsauc_data1;
class L5; 
var DOLLARS DISP FEATURE; run;

proc means data =cc.spagsauc_data1 sum;
class Market_Name;
var Dollars;
output out = a4(drop = _type_ _freq_) sum=Dollars ;
run; 

proc sort data = a4; by descending Dollars; run;

proc print data = a4;run;

/*Q4*/
proc sql;
select L5, avg(dollars/(units*vol_eq)) as AvgPrice ,sum(disp*units)/sum(units) as AvgDisplay,sum(feature*units)/sum(units) as AvgFeature
from cc.spagsauc_data_new
group by L5;
quit;

/*Q5*/
proc means data =cc.spagsauc_data_new;
class MARKET_NAME;
var Dollars;
output out = a5(drop = _type_ _freq_) sum=Dollars ;
run; 

proc sort data = a5; by descending Dollars; run;

proc print data = a5;run;

/*Q6*/
proc means data =cc.spagsauc_data_new;
class Msk_Name;
var Dollars;
output out = q6(drop = type freq) sum=Dollars ;
run; 

proc sort data = q6; by descending Dollars; run;

proc print data = q6;run;

/*Q7*/
PROC SQL;
CREATE TABLE q7 as
SELECT L5,WEEK,avg((DOLLARS/UNITS)/VOL_EQ)as per_unit_price
From spagsauc_data_new
Group by L5,WEEK;
QUIT;
PROC SGPLOT DATA = q7;
SERIES X = Week Y = per_unit_price / group=L5;
TITLE 'Average Unit Price By Week By Brand';
RUN;

/*Q9*/
proc sql; 
create table top_store as select 
IRI_KEY, SUM(DOLLARS) as total_sales from cc.spagsauc_data_new
where L5='PREGO'
group by IRI_KEY
order by total_sales DESC;
quit;

proc print data = top_store;run;

proc sql;
create table a6 as select IRI_KEY, ((DOLLARS/UNITS)/VOL_EQ) as per_unit from cc.spagsauc_data_new
where IRI_KEY in ('225023','288146','279714','646857','231084','225963') and L5 = 'PREGO';
quit; 

proc sql; 
create table a7 as select IRI_KEY, per_unit, case 
when IRI_KEY = '225023' then 'Large'
when IRI_KEY = '288146' then 'Large'
when IRI_KEY = '279714' then 'Large'
else 'Small' 
end as size
from a6;
quit;

proc print data = a7;run;

/*Q9*/
proc ttest data = a7; class size; var per_unit;run;

data cc.spagsauc_data_new; set cc.spagsauc_data_new; 
price_per_unit = ((DOLLARS/UNITS)/VOL_EQ);
run; 

proc print data = cc.spagsauc_data_new(obs=10); run;
/*Q10*/
 proc sql; 
create table prego_reg as select *
 from spagsauc_data_new
where L5='PREGO';
quit;
proc ttest data = prego_reg; class DISP; var DOLLARS;run;

proc sql; 
create table prego_spag as select DOLLARS, case
when TYPE_OF_ITALIAN_SAUCE = 'SPAGHETTI' then 'SPAGHETTI'
else 'NOT SPAGHETTI'
end as TYPE
from prego_reg;
quit;

proc print data = prego_reg(obs=100);run;
proc ttest data = prego_spag ; class TYPE; var DOLLARS;run;
proc ttest data = prego_reg; class DISP; var DOLLARS;run;

/*Q11*/

proc reg data = cc.spagsauc_data_new;
model DOLLARS = price_per_unit DISP FEATURE
   / tol vif collin;
   run;

proc sql; 
create table prego_reg as select *
 from cc.spagsauc_data_new
where L5='PREGO';
quit;

proc print data = prego_reg(obs=10);run;

proc reg data = prego_reg;
model DOLLARS = price_per_unit DISP FEATURE
   / tol vif collin;
   run;

proc reg data = prego_reg;
model DOLLARS = price_per_unit DISP FEATURE price_per_unit*DISP*FEATURE;
   run;

data prego_reg; set prego_reg; 
inter_var = price_per_unit*DISP*FEATURE;
run; 

proc print data = prego_reg(obs=10);run;

proc reg data = prego_reg;
model DOLLARS = price_per_unit DISP FEATURE inter_var;
   run;

data prego_reg; set prego_reg; 
price_sq = price_per_unit*price_per_unit;
run; 

proc print data = prego_reg(obs=10);run;

proc reg data = prego_reg;
model DOLLARS = price_per_unit price_sq;
   run;

proc reg data = prego_reg;
model DOLLARS = price_per_unit DISP FEATURE / spec;
output out = reg_model
   run;

proc model data=prego_reg;
parms b0 b1 b2 b3;
feature_inv=1/FEATURE;
DOLLARS=b0+b1*Price_Per_Unit+ b2*DISP+ b3*FEATURE;
fit DOLLARS / white;
weight feature_inv;
run;

data prego_reg; set prego_reg; 
disp_feat = DISP*FEATURE;
run; 

proc reg data = prego_reg; 
model price_per_unit = DISP FEATURE disp_feat;
run; 

proc means data = prego_reg; run;
