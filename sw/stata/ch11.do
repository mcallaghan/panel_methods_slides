# delimit ;
clear;
cap log close;
*************************************************************;
* Replication program for Chapter 11 in SW3E;
*************************************************************;
log using ch11.log,replace;
set more 1;
***********************************;
* Read In Data; 
* (Note: Change path name so that it is appropriate for your computer);
use \tb\3e\supplements\replicationfiles\data\hmda_sw.dta;
********************************************;

gen deny = (s7==3);
gen pi_rat = s46/100;
gen black = (s13==3);

***********************************;
* Results on Page 1;
**********************************;
sort black;
summarize deny if (black==1);
summarize deny if (black==0);
************************************;
**** Equation 11.1;
************************************;
regress deny pi_rat, r;
************************************;
**** Equation 11.3;
************************************;
regress deny pi_rat black, r;
************************************;
**** Equation 11.7;
************************************;
probit deny pi_rat, r;
************************************;
**** Equation 11.8;
************************************;
probit deny pi_rat black, r;
************************************;
**** Equation 11.10;
************************************;
logit deny pi_rat black, r;
*************************************
**** Table 11.1 ;
************************************;
gen hse_inc = s45/100;
gen loan_val = s6/s50;
gen ccred = s43;
gen mcred = s42;
gen pubrec = (s44>0);
gen denpmi = (s53==1);
gen selfemp = (s27a==1);
gen married = (s23a=="M");
gen single = (married==0);
gen hischl = (school>=12);
gen probunmp = uria;
gen condo = (s51 == 1);
sum pi_rat hse_inc loan_val ccred mcred pubrec denpmi selfemp
 single hischl probunmp condo black deny;
*************************************
**** Table 11.2 ;
************************************;
gen ltv_med = (loan_val>=0.80)*(loan_val<=.95);
gen ltv_high = (loan_val>0.95); 
gen blk_pi = black*pi_rat;
gen blk_hse = black*hse_inc;
gen ccred3 = (ccred==3); 
gen ccred4 = (ccred==4);
gen ccred5 = (ccred==5);
gen ccred6 = (ccred==6);
gen mcred3 = (mcred==3);
gen mcred4 = (mcred==4);
** Preliminary Analysis ... compute means of all variables;
sum deny black pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi
 selfemp single hischl probunmp mcred3 mcred4 ccred3 ccred4 ccred5 ccred6
 condo; 
 
** col(1);
regress deny black pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi
 selfemp, r;
 ** col(2);
 logit deny black pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi
 selfemp;
logit deny black pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi
 selfemp, r;
 scalar w0 =  _b[black]*0
              + _b[ pi_rat]*  .3308136 
              + _b[ hse_inc]* .2553461 
              + _b[ ltv_med]* .3743697 
              + _b[ltv_high]* .0323529 
              + _b[   ccred]*  2.116387 
              + _b[   mcred]*  1.721008 
              + _b[  pubrec]* .0735294 
              + _b[  denpmi]* .0201681 
              + _b[ selfemp]* .1163866 
              + _b[   _cons]*  1;
scalar w1 = w0 + _b[black]*1;
dis "Prob for white at means = " 1/(1+exp(-w0));
dis "Prob for black at means = " 1/(1+exp(-w1));
dis "Difference in probs     = " (1/(1+exp(-w1))) - (1/(1+exp(-w0)));
 ** col(3);
 probit deny black pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi
 selfemp;
probit deny black pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi
 selfemp, r;
 scalar z0 =  _b[black]*0
              + _b[ pi_rat]*  .3308136 
              + _b[ hse_inc]* .2553461 
              + _b[ ltv_med]* .3743697 
              + _b[ltv_high]* .0323529 
              + _b[   ccred]*  2.116387 
              + _b[   mcred]*  1.721008 
              + _b[  pubrec]* .0735294 
              + _b[  denpmi]* .0201681 
              + _b[ selfemp]* .1163866 
              + _b[   _cons]*  1;
scalar z1 = z0 + _b[black]*1;
dis "Prob for white at means = " normprob(z0);
dis "Prob for black at means = " normprob(z1);
dis "Difference in probs     = " normprob(z1)-normprob(z0);
 ** col(4);
probit deny black pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi
 selfemp single hischl probunmp;
test single hischl probunmp;
probit deny black pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi
 selfemp single hischl probunmp, r;
scalar z0 =  _b[black]*0
              + _b[ pi_rat]*  .3308136 
              + _b[ hse_inc]* .2553461 
              + _b[ ltv_med]* .3743697 
              + _b[ltv_high]* .0323529 
              + _b[   ccred]*  2.116387 
              + _b[   mcred]*  1.721008 
              + _b[  pubrec]* .0735294 
              + _b[  denpmi]* .0201681 
              + _b[ selfemp]* .1163866               
              + _b[  single]* .3932773 
              + _b[  hischl]* .9836134
              + _b[probunmp]*  3.774496
              + _b[   _cons]*  1;
scalar z1 = z0 + _b[black]*1;
dis "Prob for white at means = " normprob(z0);
dis "Prob for black at means = " normprob(z1);
dis "Difference in probs     = " normprob(z1)-normprob(z0);
test single hischl probunmp;

** col(5);
probit deny black pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi
 selfemp single hischl probunmp mcred3 mcred4 ccred3 ccred4 ccred5 ccred6 condo;
test single hischl probunmp;
test mcred3 mcred4 ccred3 ccred4 ccred5 ccred6;
test condo;
probit deny black pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi
 selfemp single hischl probunmp mcred3 mcred4 ccred3 ccred4 ccred5 ccred6 condo, r;
scalar z0 =  _b[black]*0
              + _b[ pi_rat]*  .3308136 
              + _b[ hse_inc]* .2553461 
              + _b[ ltv_med]* .3743697 
              + _b[ltv_high]* .0323529 
              + _b[   ccred]*  2.116387 
              + _b[   mcred]*  1.721008 
              + _b[  pubrec]* .0735294 
              + _b[  denpmi]* .0201681 
              + _b[ selfemp]* .1163866               
              + _b[  single]* .3932773 
              + _b[  hischl]* .9836134
              + _b[probunmp]*  3.774496
              + _b[  mcred3]* .0172269              
              + _b[  mcred4]* .0088235             
              + _b[  ccred3]* .0529412
              + _b[  ccred4]* .0323529
              + _b[  ccred5]* .0764706
              + _b[  ccred6]* .0844538 
              + _b[   condo]* .2882353                                                                     
              + _b[   _cons]*  1;
scalar z1 = z0 + _b[black]*1;
dis "Prob for white at means = " normprob(z0);
dis "Prob for black at means = " normprob(z1);
dis "Difference in probs     = " normprob(z1)-normprob(z0);
test single hischl probunmp;
test mcred3 mcred4 ccred3 ccred4 ccred5 ccred6;
test condo;
** col(6);
probit deny black pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi
 selfemp single hischl probunmp blk_pi blk_hse;
test single hischl probunmp;
test black blk_pi blk_hse;
test blk_pi blk_hse;
probit deny black pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi
 selfemp single hischl probunmp blk_pi blk_hse, r;
scalar z0 =  _b[black]*0
              + _b[ pi_rat]*  .3308136 
              + _b[ hse_inc]* .2553461 
              + _b[ ltv_med]* .3743697 
              + _b[ltv_high]* .0323529 
              + _b[   ccred]*  2.116387 
              + _b[   mcred]*  1.721008 
              + _b[  pubrec]* .0735294 
              + _b[ selfemp]* .1163866               
              + _b[  denpmi]* .0201681 
              + _b[  single]* .3932773 
              + _b[  hischl]* .9836134
              + _b[probunmp]*  3.774496
              + _b[   _cons]*  1;
scalar z1 = z0 + _b[black]*1 
          + _b[blk_pi]*1* .3308136 
          + _b[blk_hse]*1* .2553461 ; 
dis "Prob for white at means = " normprob(z0);
dis "Prob for black at means = " normprob(z1);
dis "Difference in probs     = " normprob(z1)-normprob(z0); 
test single hischl probunmp;
test black blk_pi blk_hse;
test blk_pi blk_hse;
log close;
exit;
