set more off
clear all

cd C:\Users\m.callaghan\Documents\GitHub\panel_methods_slides\stata_guide\stata

cap log close
log using logs/byreg, text replace
*@*lstart
sysuse auto
sort foreign
by foreign: reg price mpg
*@*lend
cap log close


forvalues i = 1/20 {
  if mod(`i',2)==0 {
    di "`i' is even"
  } 
  else {
    di "`i' is odd"
  }
}

sysuse auto

forvalues i = 1/100 {
  if mod(`i',3)==0 & mod(`i',5)==0{
    di "fizzbuzz"
  } 
  else if mod(`i',5)==0{
    di "buzz"
  }
  else if mod(`i',3)==0{
    di "fizz"
  }
  else {
    di "`i'"
  }
}



*******
*FoCrime - import the data
clear all
cap log close
log using logs/foCrime_import, text replace
*** Copy the dataset onto our computer (if it doesn't exist already
*@*lstart
capture confirm file data/crime.xls
if _rc==601 {
	copy https://files.datapress.com/london/dataset/metropolitan-police-service-recorded-crime-figures-and-associated-data/2015-12-23T15:58:16/MASTER_mps-figures.xls ///
		data/crime.xls, replace
}
import excel data/crime.xls, ///
	sheet("Fear of Crime-Borough") /// Tell stata which sheet to import
	cellrange(A3:AG31) /// Specify the cells we want to import
	firstrow // tell stata that variable names are in the first row
	
cap rename (BarkingandDagenham HammersmithandFulham KensingtonandChelsea) ///
   (BarkingDagenham HammersmithFulham KensingtonChelsea) // Inconsistent names
cap rename A MonthYear // Merged cell caused problem
*@*lend
cap log close

*******
*FoCrime - clean the data
cap log close
log using logs/foCrime_clean, text replace
*@*lstart
sort MonthYear
by MonthYear: gen dup = cond(_N==1,0,_n)
drop if dup > 0 
*@*lend
cap log close



*******
*FoCrime - reshape the data
cap log close
log using logs/foCrime_reshape, text replace
*@*lstart
rename(BarkingDagenham-Westminster) FoC=
reshape long FoC, i(MonthYear) j(Borough) string
label variable FoC "Fear of Crime-Borough"
*@*lend
cap log close

save data/foCrime.dta, replace


********************************
* import all sheets using a loop

cap log close
log using logs/import_loop, text replace
*@*lstart
local sheets `" "Fear of Crime-Borough" "MOPAC Priority-Borough" "Officer Strength-Borough" "Sergeant Strength-Borough" "Special Strength-Borough" "PCSO Strength-Borough" "Staff Strength-Borough" "'	
local cranges A3:AG31 A3:AH58 A5:AG97 A4:AG36 A5:AG97 A5:AG97 A5:AG97
local varnames FoC MOPAC OffStrength SgtStrength SpclStrength PCSOStrength StaffStrength
local N : word count `sheets'

forvalues i = 1/`N' {
	local sheet : word `i' of `sheets'
	local crange : word `i' of `cranges'
	local varname : word `i' of `varnames'
 	clear   
	import excel data/crime.xls, ///
		sheet("`sheet'") ///
		cellrange("`crange'") ///
		firstrow	
	cap rename (BarkingandDagenham HammersmithandFulham KensingtonandChelsea) ///
      (BarkingDagenham HammersmithFulham KensingtonChelsea) // Inconsistent names
	cap drop HeathrowAirport
	cap rename A MonthYear // Merged cell caused problem	
	sort MonthYear
	by MonthYear: gen dup = cond(_N==1,0,_n)
	drop if dup > 0
	drop dup
	rename (BarkingDagenham-Westminster) `varname'=
	reshape long "`varname'", i(MonthYear) j(Borough) string
	label variable `varname' "`sheet'"
	save data/`varname'.dta, replace
}
*@*lend
cap log close

********************
* Merge the datasets
cap log close
log using logs/merge_loop, text replace
*@*lstart
clear
forvalues i = 1/`N' {
  local varname : word `i' of `varnames'
  if `i'==1 {
    use data/`varname'
  } 
  else {
    merge m:m MonthYear Borough using data/`varname'
	drop _merge
  }
}
*@*lend
cap log close


********************
* Destring foCrime

cap log close
log using logs/destring, text replace
*@*lstart
gen FoC2 = subinstr(FoC,"%","",.)
destring FoC2, replace
replace FoC2 = FoC2/100 if FoC2 > 1
*@*lend
cap log close

******************************
** Running regressions
******************************
** esttab
cap log close
log using logs/esttab.log, text replace
clear all
*@*lstart
sysuse auto
eststo A: quietly reg price mpg
eststo B: quietly reg price mpg rep78
esttab A B using ../word/reg_table_1.rtf, replace
*@*lend
esttab A B using ../slides/tex/reg_table_1.tex, replace
//avplots
cap log close

*******
* Run a regression and view post-estimation stats
cap log close
log using logs/post, text replace
clear all
*@*lstart
sysuse auto
quietly reg price mpg rep78
ereturn list
*@*lend
cap log close

*******
* Run a regression and view post-estimation stats
cap log close
log using logs/post_r2, text replace
clear all
*@*lstart
sysuse auto
reg price mpg rep78
di e(r2)
*@*lend
cap log close

*******
* Run a regression and view betas
cap log close
log using logs/post_mb, text replace
clear all
*@*lstart
sysuse auto
reg price mpg rep78
matrix list e(b)
*@*lend
cap log close

*******
* Run a regression and view var/covar
cap log close
log using logs/post_mv, text replace
clear all
*@*lstart
sysuse auto
reg price mpg rep78
matrix list e(V)
*@*lend
cap log close

*******
* Run a regression and view individual betas
cap log close
log using logs/post_ib, text replace
clear all
*@*lstart
sysuse auto
reg price mpg rep78
di _b[mpg]
di _se[mpg]
*@*lend
cap log close

*******
* Esttab with more options
cap log close
log using logs/esttab_2.log, text replace
clear all
*@*lstart
sysuse auto
eststo A: quietly reg price mpg
eststo B: quietly reg price mpg rep78
esttab A B using ../word/reg_table_2.rtf, ///
	stats(N r2 F) ///
	replace
*@*lend
esttab A B using ../slides/tex/reg_table_2.tex, ///
	stats(N r2 F) ///
	replace
//avplots
cap log close


******************************
** Graphs
******************************
set scheme s2color
******************************
** Scatter
cap log close
log using logs/graph_scatter.log, text replace
clear all
*@*lstart
sysuse auto
twoway scatter price mpg
graph export ../word/scatter.png, replace
*@*lend
cap log close

******************************
** Scatter Lfit
cap log close
log using logs/graph_overlay.log, text replace
clear all
*@*lstart
sysuse auto
twoway (scatter price mpg) (lfit price mpg)
graph export ../word/overlay.png, replace
*@*lend
cap log close

******************************
** Change scheme
cap log close
log using logs/scheme.log, text replace
clear all
*@*lstart
graph query, schemes
set scheme burd
sysuse auto
twoway (scatter price mpg) (lfit price mpg)
graph export ../word/scheme.png, replace
*@*lend
cap log close

******************************
** Add labels
cap log close
log using logs/graph_options.log, text replace
clear all
*@*lstart
sysuse auto
twoway (scatter price mpg, mlabel(make)) ///
	(lfit price mpg), ///
	title("Price and Miles per Gallon") 
	
graph export ../word/graph_options.png, replace
*@*lend
cap log close


******************************
cap log close
log using logs/graph_matrix_all.log, text replace
*@*lstart
clear all
sysuse auto
ds, has(type numeric)
graph matrix `r(varlist)'
*@*lend
cap log close


******************************
cap log close
log using logs/graph_matrix.log, text replace
*@*lstart
clear all
sysuse auto
graph matrix price mpg weight foreign
*@*lend
cap log close



reg FoC2 MOPAC OffStrength

avplots




reg FoC2 MOPAC OffStrength

reg MOPAC OffStrength


*******
* Encode borough numerically so that stata can match it
cap log close
log using logs/encode, text replace
*@*lstart
encode Borough, generate(nBorough)
xtset nBorough MonthYear
*@*lend
cap log close

cap gen sqOffStrength = OffStrength^2

*******
* Using estout
cap log close
log using logs/reg_1, text replace
*@*lstart
quietly xtreg FoC2 MOPAC PCSOStrength, fe
eststo A
quietly xtreg FoC2 MOPAC PCSOStrength OffStrength StaffStrength, fe
eststo B
esttab A B using ../word/reg_table_1.rtf, replace
*@*lend
cap log close




*******
* Run a regression and display within r2
cap log close
log using logs/reg_2, text replace
*@*lstart
xtreg FoC2 MOPAC OffStrength, fe
di e(r2_w)
*@*lend
cap log close

*******
* Run a regression and show coefficients
cap log close
log using logs/reg_b_matrix, text replace
*@*lstart
xtreg FoC2 MOPAC OffStrength, fe
matrix list e(b)
*@*lend
cap log close

*******
* Run a regression and show var matrix
cap log close
log using logs/reg_V_matrix, text replace
*@*lstart
xtreg FoC2 MOPAC OffStrength, fe
matrix list e(V)
*@*lend
cap log close

*******
* Accessing individual matrix items
cap log close
log using logs/reg_ind_matrix, text replace
*@*lstart
xtreg FoC2 MOPAC OffStrength, fe
di _b[OffStrength]
di _se[OffStrength]
*@*lend
cap log close

preserve
xtdata, fe clear
graph matrix MOPAC-FoC2
graph export ../word/graph1.png, replace
restore

graph matrix MOPAC-FoC2
graph export ../word/graph1.png, replace

xtsum MOPAC

xtline MOPAC, overlay legend(off)

xtline FoC2, overlay legend(off)

xtline OffStrength, overlay legend(off)

xtline SpclStrength, overlay legend(off)

xtline PCSOStrength, overlay legend(off)



xtreg FoC2 MOPAC OffStrength SgtStrength, fe

xtreg FoC2 MOPAC PCSOStrength, fe


xtreg FoC2 MOPAC PCSOStrength OffStrength, fe

xtreg FoC2 MOPAC c.PCSOStrength##c.PCSOStrength OffStrength, fe

xtreg FoC2 MOPAC OffStrength, fe

preserve
xtdata, fe clear
//hist FoC2
//hist MOPAC
//graph twoway (scatter FoC2 OffStrength) (lfit FoC2 OffStrength)
graph twoway (scatter FoC2 PCSOStrength) (qfit FoC2 PCSOStrength)
restore

cap gen sqPCSOStrength = PCSOStrength^2

xtreg FoC2 MOPAC PCSOStrength sqPCSOStrength, fe
eststo A: xtreg FoC2 MOPAC PCSOStrength sqPCSOStrength, fe
estadd scalar e_tp = -_b[PCSOStrength]/(2*_b[sqPCSOStrength])

eststo B: xtreg FoC2 MOPAC PCSOStrength sqPCSOStrength OffStrength, fe
estadd scalar e_tp = -_b[PCSOStrength]/(2*_b[sqPCSOStrength])

esttab A B, stats(e_tp)



hist MOPAC

egen BoMeanCrime = mean(MOPAC), by(Borough)

scatter FoC2 OffStrength || qfit FoC2 OffStrength

xtreg FoC2 


xtreg MOPAC OffStrength SgtStrength, fe

xtreg FoC2 MOPAC OffStrength SgtStrength, fe

xtreg OffStrength MOPAC FoC2, fe


xtreg FoC2 MOPAC OffStrength sqOffStrength, fe
eststo A: xtreg FoC2 MOPAC OffStrength sqOffStrength, fe
estadd scalar e_tp = -_b[OffStrength]/(2*_b[sqOffStrength])

eststo B: xtreg FoC2 MOPAC OffStrength sqOffStrength StaffStrength, fe
estadd scalar e_tp = -_b[OffStrength]/(2*_b[sqOffStrength])

esttab A B, stats(e_tp)


