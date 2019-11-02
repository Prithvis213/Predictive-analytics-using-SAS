LIBNAME q 'H:\';
DATA cred;
SET q.CC10;
run;

proc print data = cred(obs=10);run;

/*calculating profit*/
data cred; 
set cred;
profit = totfc + 0.016*tottrans;
run; 

proc print data = cred;run;

proc means data = cred;var profit; run;

proc means data = cred;var profit;class rewards; run;

/*plotting profit to check distribution*/
proc sgplot data = cred noautolegend;
  histogram profit;
  density profit /type = normal lineattrs=(color=blue);
run;

/*Adding active variable to the table*/
data cred; 
set cred;
if profit = 0.00 then active = 0; else active =1;
run;  


data cred; 
set cred;
lprofit = log(profit);
run; 

proc print data = cred;run; 

/*Question1*/
PROC QLIM data=cred;
model profit = age tottrans rewards numcard dm ds ts net standard gold platinum quantum sectorA sectorB sectorC sectorD sectorE sectorF;
endogenous profit ~ censored (lb=0 ub=5000);
Run; 

PROC QLIM data=cred;
model profit = age tottrans rewards numcard dm ds ts net standard gold platinum quantum sectorA sectorB sectorC sectorD sectorE sectorF;
endogenous profit ~ censored (lb=0 ub=3000);
Run;

/*Question2*/
proc qlim data=cred; model active = age rewards limit numcard dm ds ts net standard gold platinum quantum sectorA sectorB sectorC sectorD sectorE sectorF /discrete; 
model lprofit = age tottrans rewards limit numcard dm ds ts net standard gold platinum quantum sectorA sectorB sectorC sectorD sectorE sectorF / select(active=1); 
run; 

/*Question3*/
data cred_active; set cred; 
if active = 1;
run;

proc means data = cred_active; var dur;run;

proc phreg data=cred_active;
model dur= age tottrans rewards limit numcard dm ds ts net standard gold platinum quantum sectorA sectorB sectorC sectorD sectorE sectorF;
run;

/*Question4*/
PROC LIFEREG data =cred_active outest=a;
model dur= age tottrans rewards limit numcard dm ds ts net standard gold platinum quantum sectorA sectorB sectorC sectorD sectorE sectorF / dist=weibull;
output out=b xbeta=lp;
run;

/*Question5*/
proc lifetest data=cred plots=(s) graphics outsurv=a;
time dur*active(0);
strata sectorA;
symbol1 v=none color=black line=1;
symbol2 v=none color=black line=2;
run;




