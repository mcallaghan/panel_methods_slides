clear all /* Deleting all data in memory */
set more off
capture log close  /* closes the log file if it is open */


log using panel.log, replace text
use ../data/dataset.dta, clear  /*opening the data file path relative to wd
where do file is located */


reg energy_consumption income_est
outtex, file(ols.tex) labels level detail legend key(stab) replace
est store ols
graph twoway (scatter energy_consumption income_est) (lfit energy_consumption income_est)




xtset LA_CODE MSOA_CODE
xtreg energy_consumption income_est, fe
outtex, file(fe.tex) labels level detail legend key(stab) replace
est store fe



xi: regress energy_consumption income_est i.LA_CODE
outtex, file(lsdv.tex) labels level detail legend key(stab) replace
est store lsdv
predict energy_consumption_fitted

separate energy_consumption, by(LA_CODE)
separate energy_consumption_fitted, by(LA_CODE)

graph twoway (scatter energy_consumption1-energy_consumption80 income_est) ///
	(line energy_consumption_fitted1-energy_consumption_fitted80 income_est) ///
	(lfit energy_consumption income_est, ///
	color(black) lwidth(thick) lpattern(dash)), legend(off) 
	

esttab ols fe using table1.tex, replace

capture log close
