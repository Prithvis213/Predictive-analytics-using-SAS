/* Use the Churn data from a telecom company to understand what factors are good predictors of churn. Use a logistic regression model to build the best model (that is best in terms of model fit criteria).
Churn is the dependent variable that takes the value 1 if a customer has churned and 0 otherwise.
Make sure that there are no two explanatory variables that are highly correlated. Use correlation analysis to determine the correlation between the variables.
1.	Include a table of coefficients, t-values, and odds ratio. Interpret the logistic output explaining AIC/BIC, meaning of coefficients, significance, prediction accuracy (percent concordance), odds-ratios etc.
2.	Which are the top three factors that affect churn in your model.
3.	What other variables (that if collected) would help to improve the fit of the model.
4.	Compute the hit ratio for your model. Hit ratio is defined as the percentage of correct predictions using the logit model. Use the model to predict 1 or 0 using the same data.
*/

libname ss 'H:\';

data hw;
infile "H:\Churn_telecom.csv" DLM = ',' firstobs = 2 dsd missover;
INPUT rev_Mean mou_Mean totmrc_Mean da_Mean ovrmou_Mean ovrrev_Mean vceovr_Mean datovr_Mean roam_Mean rev_Range mou_Range totmrc_Range da_Range ovrmou_Range ovrrev_Range vceovr_Range datovr_Range roam_Range change_mou change_rev drop_vce_Mean drop_dat_Mean blck_vce_Mean blck_dat_Mean unan_vce_Mean unan_dat_Mean plcd_vce_Mean plcd_dat_Mean recv_vce_Mean recv_sms_Mean comp_vce_Mean comp_dat_Mean custcare_Mean ccrndmou_Mean cc_mou_Mean inonemin_Mean threeway_Mean mou_cvce_Mean mou_cdat_Mean mou_rvce_Mean owylis_vce_Mean mouowylisv_Mean iwylis_vce_Mean mouiwylisv_Mean peak_vce_Mean peak_dat_Mean mou_peav_Mean mou_pead_Mean opk_vce_Mean opk_dat_Mean mou_opkv_Mean mou_opkd_Mean drop_blk_Mean attempt_Mean complete_Mean callfwdv_Mean callwait_Mean drop_vce_Range drop_dat_Range blck_vce_Range  blck_dat_Range unan_vce_Range unan_dat_Range plcd_vce_Range plcd_dat_Range recv_vce_Range recv_sms_Range comp_vce_Range comp_dat_Range custcare_Range ccrndmou_Range cc_mou_Range inonemin_Range threeway_Range mou_cvce_Range mou_cdat_Range mou_rvce_Range owylis_vce_Range mouowylisv_Range iwylis_vce_Range mouiwylisv_Range peak_vce_Range peak_dat_Range mou_peav_Range mou_pead_Range opk_vce_Range opk_dat_Range mou_opkv_Range mou_opkd_Range drop_blk_Range attempt_Range complete_Range callfwdv_Range callwait_Range churn months uniqsubs actvsubs crtcount new_cell $ crclscod $ asl_flag $ rmcalls rmmou rmrev totcalls totmou totrev adjrev adjmou adjqty  avgrev avgmou avgqty avg3mou avg3qty avg3rev avg6mou avg6qty avg6rev REF_QTY tot_ret tot_acpt prizm_social_one $ div_type $ csa $ area $ dualband $ refurb_new $ hnd_price pre_hnd_price phones last_swap models hnd_webcap $ truck mtrcycle rv occu1 ownrent $ lor dwlltype $ marital $ mailordr $ age1 age2 wrkwoman $ mailresp $ children $ adults infobase $ income numbcars cartype $ HHstatin $ mailflag $ solflag $ dwllsize $ forgntvl educ1 proptype $ pcowner $ ethnic $ kid0_2 $ kid3_5 $ kid6_10 $ kid11_15 $ kid16_17 $ creditcd $ car_buy $ retdays eqpdays Customer_ID;
run;
PROC PRINT DATA = hw (obs = 20);RUN;
/*missing data check*/
proc means nmiss data =hw;run;
/* drop variables with more than 60% missing data */
data churn;
set hw;
drop crtcount rmcalls rmmou rmrev REF_QTY tot_ret tot_acpt pre_hnd_price last_swap occu1 educ1 numbcars retdays;
RUN;

proc means data = churn; class churn;output out = churn_mean; run;

PROC EXPORT data = churn_mean outfile = "'H:\churn_mean.csv" dbms = dlm replace ;
delimiter = ',';
RUN;
/* Checking for correlation - top 10 variables */
proc corr data = churn_mean; var change_mou roam_Mean roam_Range eqpdays mtrcycle vceovr_Range ovrrev_Range ovrmou_Range vceovr_Mean ovrrev_Mean; run;

/*Best possible model explored */
proc logistic data=churn;
class refurb_new prizm_social_one new_cell;
model churn(event='1') = refurb_new prizm_social_one new_cell months drop_blk_Range actvsubs change_mou roam_Mean roam_Range eqpdays mtrcycle uniqsubs mou_Range ovrmou_Range ovrmou_Mean rev_Range change_mou*eqpdays;
OUTPUT OUT=OUTDATA P=PRED_PROB;
run;
/* Correlation check for the best possible model explored */
proc corr data = churn; var months drop_blk_Range actvsubs change_mou roam_Mean roam_Range eqpdays mtrcycle uniqsubs mou_Range ovrmou_Range ovrmou_Mean rev_Range; run;

proc print data = OUTDATA (obs=10);run;

DATA finale;SET OUTDATA;
IF PRED_PROB>0.5 THEN P_final='yes';
IF PRED_PROB<=0.5 THEN P_final='no';
RUN;

proc print data = finale (obs=50);run;

/*  To get Confusion Matrix and calculate Hit Ratio */
proc freq data=finale;
tables churn*P_final;
run;
