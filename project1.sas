LIBNAME cc 'E:\Soham\';

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

if L5 = 'RAGU OLD WORLD STYLE' then L5 = 'RAGU';
else if L5 = 'RAGU CHUNKY GARDEN STYLE' then L5 = 'RAGU';
else if L5 = 'RAGU HEARTY' then L5 = 'RAGU';
else if L5 = 'RAGU CHEESE CREATIONS' then L5 = 'RAGU';
else if L5 = 'RAGU ROBUSTO' then L5 = 'RAGU';
else if L5 = 'RAGU LIGHT' then L5 = 'RAGU';
else if L5 = 'RAGU CHICKEN TONIGHT' then L5 = 'RAGU';
else if L5 = 'RAGU THICK & HEARTY' then L5 = 'RAGU';
else if L5 = 'PREGO' then L5 = 'PREGO';
else if L5 = 'PREGO CHUNKY GARDEN' then L5 = 'PREGO';
else if L5 = 'PREGO EXTRA CHUNKY' then L5 = 'PREGO';
else if L5 = 'PREGO PRIMORE' then L5 = 'PREGO';
else if L5 = 'CLASSICO' then L5 = 'CLASSICO';
else if L5 = 'CLASSICO CREATIONS' then L5 = 'CLASSICO';
else if L5 = 'HUNTS' then L5 = 'HUNTS';
else if L5 = 'HUNTS LIGHT' then L5 = 'HUNTS';
else if L5 = 'HUNTS SUMMER SELECT' then L5 = 'HUNTS';
else if L5 = 'HUNTS ANGELA MIA' then L5 = 'HUNTS';
else if L5 = 'PRIVATE LABEL' then L5 = 'PRIVATE LABEL';
else L5 = 'Others';  
run;

proc print data = cc.spagsauc_data_new(obs=10);run;

data cc.spagsauc_data_new; set cc.spagsauc_data_new; 
if L5 = 'Others' then delete;
run;

proc sql;
create table sales_data as
select a.*, b.tot_units
from cc.spagsauc_data_new a 
inner join (select IRI_KEY, week, L5, sum(UNITS) as tot_units
			from cc.spagsauc_data_new
			group by IRI_KEY, week, L5) b 
on a.IRI_KEY = b.IRI_KEY and a.week = b.week and a.L5 = b.L5;
quit;

data sales_data; set sales_data; 
cost_per_oz = ((DOLLARS/UNITS)/VOL_EQ);
run;

data sales_data;
retain IRI_KEY week brand L4 L5 COLUPC cost_per_oz wt_price units tot_units PR PR_wt D disp_wt F Feature Feature_wt;
set sales_data;
format PR_wt 4.2 disp_wt 4.2 Feature_wt 4.2 cost_per_oz 4.2 wt_price 4.2;
wt_price = cost_per_oz*units/tot_units;
PR_wt = PR*units/tot_units;
disp_wt = disp*units/tot_units;
Feature_wt = Feature*units/tot_units;
run;

proc print data = sales_data(obs=10);run;

proc sql;
create table sales_brandwise as
select IRI_KEY, week, L5,
sum(wt_price) as tot_wt_brand_price,
sum(PR_wt) as tot_PR_wt, 
sum(disp_wt) as tot_disp_wt, 
sum(Feature_wt) as tot_Feature_wt
from sales_data
group by IRI_KEY, week, L5;
quit;

proc sql;
create table iri_lt4_brands as 
select iri_key, week, count(*) as cnt from sales_brandwise group by 1,2 having cnt < 5;
quit;

proc sql;
create table iri_weeks as 
select distinct iri_key, week from sales_brandwise where iri_key not in (select distinct iri_key from iri_lt4_brands)
order by 1,2;
quit;

data iri_weeks;
set iri_weeks;
retain week1;
by IRI_KEY;
id = 1;
if first.IRI_KEY then do;
	week1 = 0;
	id = 0;
end;
diff= week - week1;
week1 = week;
run;

proc sql;
create table iri_allweek as
select IRI_KEY, sum(diff) as sum, count(distinct week) as cnt from iri_weeks where id =1
group by 1;
quit;

data iri_allweek;
set iri_allweek;
miss = (sum=cnt);
run;

proc sql;
create table sales_brandwise_allweek as
select * from sales_brandwise where IRI_KEY in (select distinct IRI_KEY from iri_allweek where miss=1)
order by IRI_KEY, week ;
quit;

data brand1 brand2 brand3 brand4 brand5;
set sales_brandwise_allweek;
if L5 = 'CLASSICO' then output brand1;
else if L5 = 'RAGU' then output brand2;
else if L5 = 'PREGO' then output brand3;
else if L5 = 'HUNTS' then output brand4;
else output brand5;
run;

proc sql;
create table all_brand_wt_price as
select
a.IRI_KEY, a.week,

a.tot_wt_brand_price as wt_price_brand1,
a.tot_PR_wt as PR_wt_brand1,
a.tot_disp_wt as disp_wt_brand1,
a.tot_Feature_wt as Feature_wt_brand1,

b.tot_wt_brand_price as wt_price_brand2,
b.tot_PR_wt as PR_wt_brand2,
b.tot_disp_wt as disp_wt_brand2,
b.tot_Feature_wt as Feature_wt_brand2,

c.tot_wt_brand_price as wt_price_brand3,
c.tot_PR_wt as PR_wt_brand3,
c.tot_disp_wt as disp_wt_brand3,
c.tot_Feature_wt as Feature_wt_brand3,

d.tot_wt_brand_price as wt_price_brand4,
d.tot_PR_wt as PR_wt_brand4,
d.tot_disp_wt as disp_wt_brand4,
d.tot_Feature_wt as Feature_wt_brand4,

e.tot_wt_brand_price as wt_price_brand5,
e.tot_PR_wt as PR_wt_brand5,
e.tot_disp_wt as disp_wt_brand5,
e.tot_Feature_wt as Feature_wt_brand5


from brand1 a 
inner join brand2 b on a.IRI_KEY = b.IRI_KEY and a.week = b.week
inner join brand3 c on a.IRI_KEY = c.IRI_KEY and a.week = c.week
inner join brand4 d on a.IRI_KEY = d.IRI_KEY and a.week = d.week
inner join brand5 e on a.IRI_KEY = e.IRI_KEY and a.week = e.week
order by a.IRI_KEY, a.week;
quit;

%macro brands(brand,brand_num);
proc sql;
create table brand_&brand_num. as
select 
b.*,

b.wt_price_brand1*b.PR_wt_brand1 as price_PR1,
b.wt_price_brand2*b.PR_wt_brand1 as price_PR2,
b.wt_price_brand3*b.PR_wt_brand1 as price_PR3,
b.wt_price_brand4*b.PR_wt_brand1 as price_PR4,
b.wt_price_brand5*b.PR_wt_brand1 as price_PR5,

b.wt_price_brand1*b.Feature_wt_brand1 as price_F1,
b.wt_price_brand2*b.Feature_wt_brand2 as price_F2,
b.wt_price_brand3*b.Feature_wt_brand3 as price_F3,
b.wt_price_brand4*b.Feature_wt_brand4 as price_F4,
b.wt_price_brand5*b.Feature_wt_brand5 as price_F5,

b.PR_wt_brand1*b.Feature_wt_brand1 as PR_F1,
b.PR_wt_brand2*b.Feature_wt_brand2 as PR_F2,
b.PR_wt_brand3*b.Feature_wt_brand3 as PR_F3,
b.PR_wt_brand4*b.Feature_wt_brand4 as PR_F4,
b.PR_wt_brand5*b.Feature_wt_brand5 as PR_F5,

case when a.tot_units is null then 0
else a.tot_units end as tot_units

from all_brand_wt_price b
inner join (select IRI_KEY, week, L5,sum(UNITS) as tot_units
			from sales_data
			where L5 = &brand.
			group by IRI_KEY, week, L5 ) a
on a.IRI_KEY = b.IRI_KEY and a.week = b.week
order by IRI_KEY, week;
quit;

proc panel data=brand_&brand_num.;
model tot_units =   wt_price_brand1 wt_price_brand2 wt_price_brand3 wt_price_brand4 wt_price_brand5
					disp_wt_brand1 disp_wt_brand2 disp_wt_brand3 disp_wt_brand4 disp_wt_brand5
					Feature_wt_brand1 Feature_wt_brand2 Feature_wt_brand3 Feature_wt_brand4 Feature_wt_brand5
					PR_wt_brand1 PR_wt_brand2 PR_wt_brand3 PR_wt_brand4 PR_wt_brand5

					price_PR1 price_PR2 price_PR3 price_PR4 price_PR5
					price_F1 price_F2 price_F3 price_F4 price_F5
					PR_F1 PR_F2 PR_F3 PR_F4 PR_F5
				    / fixtwo vcomp=fb plots=none;
id IRI_KEY week;
run;

%mend;
%brands('CLASSICO',1);
%brands('RAGU',2);
%brands('PREGO',3);
%brands('HUNTS',4);
%brands('PRIVATE LABEL',5);
