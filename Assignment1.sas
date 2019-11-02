/* Creating a permanent SAS dataset */ 
LIBNAME cc 'H:\';
DATA cc.car_insurance_19;
Infile "H:\car_insurance_19.csv" delimiter = ',' missover firstobs = 2 DSD LRECL = 32767;
 	format Customer $7.;
	format State $12.;
	format Customer_Lifetime_Value best15.;
	format	Response $4.;
	format	Coverage $10.;
	format	Education $15.0;
	format	Effective_To_Date $11.;
	format	EmploymentStatus $15.;
	format	Gender $6.;
	format	Income best10.;
	format	Location_Code $10.;
	format	Marital_Status $10.;
	format	Monthly_Premium_Auto best12.;
	format	Months_Since_Last_Claim best12.;
	format	Months_Since_Policy_Inception best12.;
	format	Number_of_Open_Complaints best12.;
	format 	Number_of_Policies best12.;
	format	Policy_Type $15.;
	format	Policy $15.;
	format	Renew_Offer_Type $15.;
	format	Sales_Channel $15.;
	format	Total_Claim_Amount best12.;
	format	Vehicle_Class $20.;
	format	Vehicle_Size $15.; 
input
	Customer $
	State $
	Customer_Lifetime_Value
	Response $
	Coverage $
	Education $
	Effective_To_Date
	EmploymentStatus $
	Gender $
	Income
	Location_Code $
	Marital_Status $
	Monthly_Premium_Auto
	Months_Since_Last_Claim
	Months_Since_Policy_Inception
	Number_of_Open_Complaints
	Number_of_Policies
	Policy_Type $
	Policy $
	Renew_Offer_Type $
	Sales_Channel $
	Total_Claim_Amount
	Vehicle_Class $
	Vehicle_Size $
;run;
/* Read from SAS dataset */ 
LIBNAME q 'H:\';
DATA car;
SET q.car_insurance_19;
run;

proc print;run;

/* 1.	What is the distribution of gender, vehicle size, and vehicle class? */
proc freq data = car;table Gender Vehicle_Size Vehicle_Class; run;

/* 2.	What is the average customer life time value of each level of gender, vehicle size, and vehicle class? */ 
proc means data = car;var Customer_Lifetime_Value; class Gender Vehicle_Size Vehicle_Class;run;

/* 3.	Do Large cars have a higher lifetime value than medsize cars. Do a ttest and report on your findings. */
data car2;set car;if Vehicle_Size="Medsize" or Vehicle_Size="Large";
proc ttest; var Customer_Lifetime_Value; class Vehicle_Size;run;

/* 4.	Is there a significant difference between men and women in customer life time value? */
proc ttest data=car; var Customer_Lifetime_Value; class Gender;run;
/* 5.Use ANOVA to test whether there is difference in customer lifetime value across different sales channels. Which sales channel generates the highest lifetime value?*/
proc anova; class Sales_Channel; 
model Customer_Lifetime_Value=Sales_Channel; run;
proc means;var Customer_Lifetime_Value; class Sales_Channel;run;

/* 6.What demographic factors (education, income, marital_status) affect customer lifetime value?. */
proc corr;var Income Customer_Lifetime_Value;run; 
proc univariate; var Customer_Lifetime_Value; run;
data car3; set car;
if Customer_Lifetime_Value le 3994 then clv=1;
if Customer_Lifetime_Value ge 8963 then clv=3;
if Customer_Lifetime_Value lt 8963 and Customer_Lifetime_Value gt 3994 then clv=2;run;

proc freq ; table clv*Education/chisq;run;
proc freq ; table clv*Marital_Status/chisq;run;

/* 7.Is there a relationship between renew_offer_type and response (use Chi-sq test)? Which offer type generates the highest response rate?*/
proc freq data = car;table Renew_Offer_Type*Response/chisq;run;

/* 8.	Do different renew_offer_types have different lifetime values? Which offer type is the best? */ 
data car4; set car;
if Customer_Lifetime_Value le 3994 then clv=1;
if Customer_Lifetime_Value ge 8963 then clv=3;
if Customer_Lifetime_Value lt 8963 and Customer_Lifetime_Value gt 3994 then clv=2;run;

proc freq ;table Renew_Offer_Type*clv/chisq;run;

/* 9.Is the effectiveness of renew_offer_type different across different states with respect to lifetime value? */ 
proc freq data=car4; table clv*Renew_Offer_Type*State/chisq;run;

/* 10. What other interesting insights that are useful to the company in terms of action can be obtained from the data? Write any 3 and indicate which type of analysis is appropriate.*/
proc anova data = car; class EmploymentStatus; 
model Customer_Lifetime_Value=EmploymentStatus; run;
proc means data = car;var Customer_Lifetime_Value; class EmploymentStatus;run;
/* Yes there is difference in mean CLV for each Employment Levels.

proc freq data=car4; table clv*Renew_Offer_Type*State/chisq;run;
