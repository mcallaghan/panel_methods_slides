
clear
cap log close
*************************************************************
* Replication program for Chapter 11 in SW3E
*************************************************************

log using logs\1_preparation.log, replace
*@*lstart
set more 1
***********************************
* Read In Data 
* (Note: Change path name so that it is appropriate for your computer)
use hmda_sw.dta
********************************************

gen deny = (s7==3)
gen pi_rat = s46/100
gen black = (s13==3)
*@*lend
cap log close

log using logs\2_describe.log, replace
*@*lstart
***********************************
* Results on Page 1
**********************************
sort black
summarize deny if (black==1)
summarize deny if (black==0)
*@*lend
cap log close
*translate logs\2_describe.smcl logs\2_describe.txt, replace

log using logs\3_controlvars.log, replace
*@*lstart
*************************************
**** Table 11.1 
************************************
gen hse_inc = s45/100
gen loan_val = s6/s50
gen ccred = s43
gen mcred = s42
gen pubrec = (s44>0)
gen denpmi = (s53==1)
gen selfemp = (s27a==1)
gen married = (s23a=="M")
gen single = (married==0)
gen hischl = (school>=12)
gen probunmp = uria
gen condo = (s51 == 1)
sum pi_rat hse_inc loan_val ccred mcred pubrec denpmi selfemp ///
 single hischl probunmp condo black deny
*@*lend
cap log close

log using logs\4_catvars.log, replace
*@*lstart
*************************************
**** Table 11.2 
************************************
gen ltv_med = (loan_val>=0.80)*(loan_val<=.95)
gen ltv_high = (loan_val>0.95) 
gen blk_pi = black*pi_rat
gen blk_hse = black*hse_inc
gen ccred3 = (ccred==3) 
gen ccred4 = (ccred==4)
gen ccred5 = (ccred==5)
gen ccred6 = (ccred==6)
gen mcred3 = (mcred==3)
gen mcred4 = (mcred==4)
*@*lend
cap log close

** Preliminary Analysis ... compute means of all variables
sum deny black pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi ///
 selfemp single hischl probunmp mcred3 mcred4 ccred3 ccred4 ccred5 ccred6 ///
 condo 

log using logs\5_lpm.log, replace
*@*lstart 
** define list of basic regressors
local controls pi_rat hse_inc ltv_med ltv_high ccred mcred pubrec denpmi selfemp
** col(1)
regress deny i.black `controls', r
eststo LPM
*@*lend
cap log close

log using logs\6_logit.log, replace
*@*lstart
** col(2) - Logit with robust standard errors
logit deny i.black `controls', r
eststo Logit_2
quietly estadd margins black, atmeans
mat m = e(margins_b)
estadd scalar prob_white = m[1,1]
estadd scalar prob_black = m[1,2]
estadd scalar prob_diff = m[1,2] - m[1,1]
margins black, atmeans vsquish
*@*lend
cap log close

log using logs\7_probit.log, replace
*@*lstart 
** col(3) - Probit with robust standard errors
probit deny i.black `controls', r
quietly estadd margins black, atmeans
mat m = e(margins_b)
estadd scalar prob_white = m[1,1]
estadd scalar prob_black = m[1,2]
estadd scalar prob_diff = m[1,2] - m[1,1]
eststo Probit_3
margins black, atmeans
*@*lend
cap log close

log using logs\8_controls.log, replace
*@*lstart 
** col(4) - Probit with more controls
probit deny i.black `controls' single hischl probunmp, r
testparm single hischl probunmp
quietly estadd margins black, atmeans
mat m = e(margins_b)
estadd scalar prob_white = m[1,1]
estadd scalar prob_black = m[1,2]
estadd scalar prob_diff = m[1,2] - m[1,1]
eststo Probit_4

disp r(F)
*@*lend
cap log close

log using logs\9_controls_2.log, replace
*@*lstart 
** col(5) - Probit with even more controls
probit deny i.black `controls' single hischl probunmp mcred3 mcred4 ccred3 ///
 ccred4 ccred5 ccred6 condo, r
quietly estadd margins black, atmeans
mat m = e(margins_b)
quietly estadd scalar prob_white = m[1,1]
quietly estadd scalar prob_black = m[1,2]
quietly estadd scalar prob_diff = m[1,2] - m[1,1]
eststo Probit_5
test single hischl probunmp
test mcred3 mcred4 ccred3 ccred4 ccred5 ccred6
test condo
*@*lend
cap log close

log using logs\10_interaction.log, replace
*@*lstart 
** col(6) - Probit with interaction
probit deny i.black `controls' ///
 single hischl probunmp i.black#c.pi_rat i.black#c.hse_inc 
quietly estadd margins black, atmeans
mat m = e(margins_b)
quietly estadd scalar prob_white = m[1,1]
quietly estadd scalar prob_black = m[1,2]
quietly estadd scalar prob_diff = m[1,2] - m[1,1]
eststo Probit_inter

test single hischl probunmp
test 1.black 1.black#c.pi_rat 1.black#c.hse_inc
test 1.black#c.pi_rat 1.black#c.hse_inc
*@*lend
cap log close


log using logs\11_summary.log, replace
*@*lstart 
esttab LPM Logit_2 Probit_3 Probit_4 Probit_5 Probit_inter using ..\word\sum_table.doc, ///
	stats(prob_white prob_black prob_diff)  mtitle replace
*@*lend
cap log close



log using logs\12_graph.log, replace
*@*lstart 
logit deny i.black `controls', r
margins black, atmeans
marginsplot
graph export graphs\margins_black.png, replace
*@*lend
cap log close

exit
