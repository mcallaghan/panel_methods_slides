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
rename(BarkingDagenham-Westminster) foCrime=
reshape long foCrime, i(MonthYear) j(Borough) string
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
*@*lend
cap log close




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

xtsum MOPAC

egen BoMeanCrime = mean(MOPAC), by(Borough)


xtreg MOPAC OffStrength SgtStrength, fe

xtreg FoC2 MOPAC OffStrength SgtStrength, fe

xtreg OffStrength MOPAC FoC2, fe

/*
import excel data\bd0075hoursworkedbysexandethnicity_tcm77-384854.xls



*********
* Use cellrange to specify cells
clear all
import excel data\bd0075hoursworkedbysexandethnicity_tcm77-384854.xls, ///
	cellrange(A6:Y30)

*********
* tell stata that variable names are in the first row 
clear all
import excel data\bd0075hoursworkedbysexandethnicity_tcm77-384854.xls, ///
	cellrange(A6:Y30) ///
	firstrow

gen id = _n

reshape long inc, i(id) j(ethnicity)

copy http://www.ons.gov.uk/ons/rel/sape/parliament-constituency-pop-est/mid-2011--census-based-/rft---mid-2011-parliamentary-constituency-population-estimates.zip ///
	age.zip
	
copy http://data.dft.gov.uk/road-accidents-safety-data/DfTRoadSafety_Accidents_2014.zip ///
	accidents.zip
	
copy https://data.gov.uk/dataset/social_trends/datapackage.zip ///
	trends.zip
	
copy https://data.gov.uk/dataset/crime_statistics/datapackage.zip ///
	data/crime/crime.zip
	
copy https://data.police.uk/data/archive/latest.zip ///
	data/crimes/crimes.zip
	
copy https://www.gov.uk/government/uploads/system/uploads/attachment_data/file/363774/SFR34_2014_Underlying_Data_v2.zip ///
	data/edu.zip
	
copy https://data.gov.uk/dataset/help-to-buy-equity-loan-scheme-by-parliamentary-constituency/datapackage.zip ///
	help2buy.zip
	
copy http://constituencyopinion.org.uk/wp-content/uploads/2013/05/code_documentation.zip ///
	constituency.zip
	
unzipfile constituency.zip
	
unzipfile help2buy.zip, replace
	
unzipfile data/edu.zip, replace
	
unzipfile data/crimes/crimes.zip
	
unzipfile data/crime/crime.zip
	
unzipfile trends.zip, replace
	
unzipfile accidents.zip, replace

clear all
import delimited DfTRoadSafety_Accidents_2014.csv
	
unzipfile "age.zip", replace

*/


