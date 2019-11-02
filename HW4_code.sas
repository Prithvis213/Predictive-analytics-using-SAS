data a1;
infile 'h:\WAGE.dat' firstobs=2;
input edu hr wage famearn selfempl salaried  married numkid age locunemp;run;

proc iml;
N=3;
Samples = 334;
ID = repeat(T(1:Samples),1, N);
SampleID = colvec(ID);
create CS from SampleID[colname = {"CS_ID"}];
append from SampleID;
close CS;
proc iml;
N=334;
Samples = 86;
ID = repeat(84:Samples,1, N);
RepID = colvec(ID);
create TS from RepID[colname = {"TS_ID"}];
append from RepID;
close TS;

proc print data = a1;run;

data a2; 
set CS;
set TS;
set a1;
run;

proc print data = a2; run;

data a2; 
SET a2;
lwage = log(wage);  
RUN;

data a2;
set a2;
if numkid = 0 then kid0 = 1;else kid0 = 0; 
if numkid = 1 then kid1 = 1;else kid1 = 0;
if numkid = 2 then kid2 = 1;else kid2 = 0;
if numkid = 3 then kid3 = 1;else kid3 = 0;
if numkid = 4 then kid4 = 1;else kid4 = 0;
run;

proc print data = a2;run;

proc corr data=a2;run;
/*Q1.1*/
proc reg data = a2;
model lwage = age edu numkid hr married salaried selfempl locunemp
   / tol vif collin;
   run;

proc reg data = a2;
model lwage = age edu hr married salaried selfempl locunemp kid1 kid2 kid3 kid4 
   / tol vif collin;
   run;

proc reg data = a2;
model lwage = age edu hr married salaried selfempl kid1 kid2 kid3 kid4
   / tol vif collin;
   run;

proc reg data = a2;
model lwage = age edu hr married salaried selfempl kid1 kid2 kid3 
   / tol vif collin;
   run;

proc reg data = a2;
model lwage = age edu hr married salaried selfempl kid1  
   / tol vif collin;
   run;
   proc model data=a2;
parms b0 b1 b2 b3 b4 b5 b6 b7;
lwage = b0 + b1*age + b2*edu + b3*hr + b4*married + b5*salaried + b6*selfempl + b7*kid1;
fit lwage/white out=res1 outresid; 
run;

/*Q1.2*/
data a2; 
SET a2;
agesq = age*age;  
RUN;

proc print data = a2;run;

proc reg data = a2;
model lwage = age edu hr married salaried selfempl kid1 agesq 
   / tol vif collin;
   run;
/*Q1.3*/
proc panel data=a2;   
ID CS_ID TS_ID; 
model lwage = age edu hr married salaried selfempl kid1 agesq/ fixone BP; 
run;

proc panel data=a2;   
ID CS_ID TS_ID; 
model lwage = age edu hr married salaried selfempl kid1 agesq/ fixtwo BP2;
run;

proc panel data=a2;   
ID CS_ID TS_ID; 
model lwage = age edu hr married salaried selfempl kid1 agesq/ ranone BP; 
run;

proc panel data=a2;   
ID CS_ID TS_ID; 
model lwage = age edu hr married salaried selfempl kid1 agesq/ rantwo BP2;
run;

infile "H:\pims.csv" DLM=','firstobs=2;
input ms	qual price plb dc pion ef phpf plpf	psc	papc ncomp mktexp tyrp pnp custtyp ncust custsize penew	cap	rbvi emprody union;
run;

proc print data= pion (obs=10);run;
PROC SYSLIN DATA=pion 2SLS;
ENDOGENOUS ms qual plb price dc ;
INSTRUMENTS pion ef phpf plpf psc papc ncomp mktexp tyrp pnp custtyp ncust custsize penew cap rbvi emprody union;
model ms=qual plb price pion ef phpf plpf psc papc ncomp mktexp ;
model qual=price dc pion ef tyrp mktexp pnp;
model plb=dc pion tyrp ef pnp custtyp ncust custsize;
model price=ms qual dc pion ef tyrp mktexp pnp;
model DC=ms qual pion ef tyrp penew cap rbvi emprody union;
RUN;

proc reg data=pion;
model ms= qual plb price pion ef phpf plpf psc papc ncomp mktexp;
run;
