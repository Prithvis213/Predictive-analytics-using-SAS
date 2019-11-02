/* Q1. I have given you a panel data on wages (Wage data) in which N=334, T=3 years (1984-1986).
For each ID, the data is sorted by year. You need to create the ID and year variables.
Columns	Variable name	Description
C1	Edu	Education in years
C2	Hr	Work hours per year
C3	Wage	Dollar wage per hour
C4	Famearn	Family earnings in dollars per year
C5	Self	Dummy for self-employed
C6	Sal	Dummy for salaried
C7	Mar	Dummy for married
C8	Numkid	Number of children
C9	Age	
C10	unemp	Local unemployment percentage

We need to do a regression to understand the determinants of “natural log (wages)” that is {ln(wage)}.
We need to understand the effect of the following variables: age, edu, numkid, hr, mar, sal, self, unemp.
*/ 

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
/*Q1.1	Find the best linear regression model. Check for multicollinearity and take appropriate actions. */
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

/*Q1.2 Develop a model to test if there are nonlinear effects for some variables. Which variables have non-linear effect on ln(wages).*/
data a2; 
SET a2;
agesq = age*age;  
RUN;

proc print data = a2;run;

proc reg data = a2;
model lwage = age edu hr married salaried selfempl kid1 agesq 
   / tol vif collin;
   run;
   
/*Q1.3 Using the same model, run fixed effects models and random effects models
i.e., FIXEDONE, FIXEDTWO, RANONE, RANTWO.
Create a table of coeffic
ients side-by side with significant coefficients shown in bold (you may do this in Excel). 
*/
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

/* Q2. I have provided a dataset PIMS.dat which has data on industrial goods manufacturers. The variables in the data are in the following order. These variables and definitions are given in the paper by Robinson and Fornell (1985) on pioneering advantages (see Tables 1, 2 and 3). As in the paper by Robinson and Fornell (1985), we will estimate a simultaneous system of five equations. While the paper considered consumer goods industries, we are interested in replicating the analysis for industrial goods industries.
MS	Relative market share
QUAL	Relative quality
PRICE	Relative price
PLB	Product line width
DC	Relative direct costs
PION	Whether a firm is a pioneer (1) or not (0)
EF	Whether a firm is an early follower (1) or not (0)
PHPF	Pioneer *high purchase frequency
PLPF	Pioneer *low purchase frequency
PSC	Pioneer *seasonal product change
PAPC	Pioneer *annual/periodic product change
NCOMP	Number of competitors
MKTEXP	Relative marketing expenditures (similar to ‘relative advertising and promotion’)
TYRP	Twenty year pioneer
PNP	Percentage of new products
CUSTTYP	Relative customer type
NCUST	Relative Number of customers
CUSTSIZE	Relative customer size
PENEW	Plant and equipment newness
CAP	Capacity utilization
RBVI	Relative backward vertical integration
EMPRODY	Employee productivity
UNION	Percentage of employees unionized

Please estimate a 2SLS model with the following five equations.
model MS=qual plb price pion ef phpf plpf psc papc ncomp mktexp
model Qual=price dc pion ef tyrp mktexp pnp
model PLB=dc pion tyrp ef pnp custtyp ncust custsize
model Price=ms qual dc pion ef tyrp mktexp pnp
model DC=ms qual pion ef tyrp penew cap rbvi emprody union
1.	Run the 2SLS model using SAS (PROC SYSLIN) and estimate the effect of pioneering on market share. Be sure to consider the direct effects as well as the indirect effects. (read the paper on pioneering advantages for this interpretation).

2.	Run a simple regression model of market share as given in the first equation. What is the effect of pioneering on market share using this simple model? How does this effect change across different models.
 */

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
