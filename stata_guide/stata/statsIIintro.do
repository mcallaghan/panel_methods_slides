set more off
clear all

cd C:\Users\m.callaghan\Documents\GitHub\panel_methods_slides\stata_guide\stata

confirm file data/crime.xls



*******
*FoCrime - import the data
clear all
cap log close
log using logs/foCrime_import, text replace
*@*lstart
*** Copy the dataset onto our computer (if it doesn't exist already
capture confirm file data/crime.xls
if _rc==601 {
	copy https://files.datapress.com/london/dataset/metropolitan-police-service-recorded-crime-figures-and-associated-data/2015-12-23T15:58:16/MASTER_mps-figures.xls ///
		data/crime.xls, replace
}
import excel data/crime.xls, ///
	sheet("Fear of Crime-Borough") /// Tell stata which sheet to import
	cellrange(A3:AG31) /// Specify the cells we want to import
	firstrow // tell stata that variable names are in the first row
	
cap rename BarkingandDagenham BarkingDagenham // Inconsistent name
cap rename A MonthYear // Merged cell caused problem
*@*lend
cap log close


*******
*FoCrime - reshape the data
cap log close
log using logs/foCrime_reshape, text replace
*@*lstart
rename(BarkingDagenham-Westminster) foCrime=
keep if MonthYear > td(2sep2008) | MonthYear < td(2aug2008) // There were 2 values for sep 2008, best to delete them both
reshape long foCrime, i(MonthYear) j(Borough) string
*@*lend
cap log close

save data/foCrime.dta, replace





********************************
* import all sheets using a loop

cap log close
log using logs/import_loop, text replace
*@*lstart
foreach sheet in "Fear of Crime-Borough" "MOPAC Priority-Borough" ///
	"Officer Strength-Borough" "Sergeant Strength-Borough" ///
	"Special Strength-Borough" "PCSO Strength-Borough" "Staff Strength-Borough" {
	if "`sheet'"=="Fear of Crime-Borough" {
		local crange "A3:AG31"
		local varname "foCrime"
	}
	if "`sheet'"=="MOPAC Priority-Borough" {
		local crange "A3:AH58"
		local varname "mopac"
	}
	if "`sheet'"=="Officer Strength-Borough" {
		local crange "A5:AG97"
		local varname "offStrength"
	}
	if "`sheet'"=="Sergeant Strength-Borough" {
		local crange "A4:AG36"
		local varname "sgtStrength"
	}
	if "`sheet'"=="Special Strength-Borough" {
		local crange "A5:AG97"
		local varname "spclStrength"
	}
	if "`sheet'"=="PCSO Strength-Borough" {
		local crange "A5:AG97"
		local varname "PCSOStrength"
	}
	if "`sheet'"=="Staff Strength-Borough" {
		local crange "A5:AG97"
		local varname "staffStrength"
	}
	
	clear all
	
	import excel data/crime.xls, ///
		sheet("`sheet'") ///
		cellrange("`crange'") ///
		firstrow
		
	if "`sheet'"=="Fear of Crime-Borough" {
		keep if MonthYear > td(2sep2008) | MonthYear < td(2aug2008)
	}	
	
	cap rename BarkingandDagenham BarkingDagenham // Inconsistent name
	cap rename A MonthYear // Merged cell caused problem
	
	rename(BarkingDagenham-Westminster) `varname'=

	reshape long `varname', i(MonthYear) j(Borough) string

	save data/`varname'.dta, replace
}
*@*lend
cap log close

forvalues i in 1/20 {
	if mod(`i',2)==0 {
		di "`i'"
	}
}




********************
* Merge the datasets
cap log close
log using logs/merge_loop, text replace
*@*lstart
foreach i in "foCrime" "mopac" "offStrength" "sgtStrength"  ///
	"PCSOStrength" "spclStrength" {
	display "`i'"
	merge m:m MonthYear Borough using "data/`i'
	drop _merge
}
*@*lend
cap log close



********************
* Destring foCrime

cap log close
log using logs/destring, text replace
*@*lstart
gen foCrime2 = subinstr(foCrime,"%","",.)
destring foCrime2, replace
*@*lend
cap log close




reg foCrime2 mopac offStrength

reg mopac offStrength


*******
* Encode borough numerically so that stata can match it
encode Borough, generate(nBorough)
xtset nBorough MonthYear

xtreg mopac offStrength sgtStrength, fe

xtreg foCrime2 mopac offStrength sgtStrength, fe

xtreg offStrength mopac foCrime2, fe

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


