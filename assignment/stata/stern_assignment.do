clear all
set more off

*set directory
cd "C:\Users\m.callaghan\Documents\Github\panel_methods_slides\assignment\stata"

*set up log file (close any existing logs first)
capture log close
log using stern_assignment.log, replace text

/*load the data (delimiters can be either tab or space or a combination,
collapse tells stata to treat a combination of delimiters as one delimiter 
*/
import delimited ../data/stern2.dat, delimiters("\t ",collapse)

*set up panel
xtset country year

xtdescribe
xtsum 

*histogram gdp and sopc (do we need to transform them
hist gdpppp, normal kdensity
graph export hist_gdp.png, replace
hist sopc, normal kdensity
graph export hist_sopc.png, replace


*create new transformed variables and squared term
cap gen lgdp = log(gdpppp)
cap gen lsopc = log(sopc)

*plot lgdp and lsopc
twoway (scatter lsopc lgdp)

*create squared term
cap gen lgdpsq = lgdp*lgdp

* create country year var
cap gen country_year = string(country) + "_" + string(year)


*inspect the distribution of the new variables
hist lgdp
hist gdpppp



capture log close
log using stern_assignment_q5.log, replace text
*regress using pooled ols
reg lsopc lgdp lgdpsq
est store pooled
cap log close

*graphical inspection for heteroscedasticity
rvfplot
*labeling countries might show if country effects are driving heteroscedasticity
rvfplot, yline(0) mlabel(country_year)
graph export pooled.png, replace
*do a Breusch-Pagan test for heteroscedasticity
estat hettest



xtline

*fixed effects regression
xtreg lsopc lgdp lgdpsq, fe
est store fix
cap predict fitted, xb
cap predict residual_e, e

scatter residual_e fitted, yline(0) mlabel(country_year)
graph export fe.png, replace

*random effects regression
xtreg lsopc lgdp lgdpsq, re
est store ran
predict r_fitted, xb
predict r_residual_e, e

scatter r_residual_e r_fitted, yline(0) mlabel(country_year)
graph export re.png, replace


*conduct a hausman test
hausman fix ran

*First difference
reg D.lsopc D.lgdp D.lgdpsq, noconstant
est store FD


esttab pooled fix ran FD


capture log close
