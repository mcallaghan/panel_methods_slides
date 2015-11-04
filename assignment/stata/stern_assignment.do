clear all
set more off

*set directory
cd "C:\Users\m.callaghan\Documents\Github\panel_methods_slides\assignment\stata"

*set up log file (close any existing logs first)
capture log close
log using stern_assignment.log, replace text

capture log close
log using stern_assignment_q2.log, replace text
*@*lstart
/*load the data (delimiters can be either tab or space or a combination,
collapse tells stata to treat a combination of delimiters as one delimiter 
*/
import delimited ../data/stern2.dat, delimiters("\t ",collapse)

* uncomment to remove kuwait 
* drop if country==98

*set up panel
xtset country year

xtdescribe 
xtsum sopc gdpppp

*histogram gdp and sopc (do we need to transform them
hist gdpppp, normal kdensity
graph export hist_gdp.png, replace
hist sopc, normal kdensity
graph export hist_sopc.png, replace


*create new transformed variables and squared term
cap gen lgdp = log(gdpppp)
cap gen lsopc = log(sopc)
*@*lend
log close

log using stern_assignment_q3.log, replace text
*@*lstart
*plot lgdp and lsopc
twoway (scatter lsopc lgdp)
graph export lsopc_lgdp.png, replace
*@*lend
log close

log using stern_assignment_q5.log, replace text
*@*lstart
*create squared term
cap gen lgdpsq = lgdp*lgdp
*regress using pooled ols
reg lsopc lgdp lgdpsq
est store pooled

*random effects regression
xtreg lsopc lgdp lgdpsq, re
est store ran

*fixed effects regression
xtreg lsopc lgdp lgdpsq, fe
est store fix

*@*lend
log close


log using stern_assignment_q6.log, replace text
*@*lstart
*conduct a Breusch-Pagan test for heteroscedasticity
quietly reg lsopc lgdp lgdpsq
estat hettest

*conduct a hausman test
hausman fix ran

*@*lend
log close

log using stern_assignment_q9.log, replace text
*@*lstart

eststo ran_world: quietly xtreg lsopc lgdp lgdpsq, re
estadd scalar e_tp = exp(-_b[lgdp]/(2*_b[lgdpsq]))

eststo ran_oecd: quietly xtreg lsopc lgdp lgdpsq if oe==1000, re
estadd scalar e_tp = exp(-_b[lgdp]/(2*_b[lgdpsq]))

eststo ran_non_oecd: quietly xtreg lsopc lgdp lgdpsq if oe==2000, re
estadd scalar e_tp = exp(-_b[lgdp]/(2*_b[lgdpsq]))


esttab ran_world ran_oecd ran_non_oecd, stats(tp e_tp)
*@*lend
log close

log using stern_assignment_q11.log, replace text
*@*lstart
*First difference
reg D.lsopc D.lgdp D.lgdpsq, noconstant
est store FD

*@*lend
log close


capture log close
