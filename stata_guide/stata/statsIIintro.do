set more off
clear all

cd C:\Users\m.callaghan\Documents\GitHub\panel_methods_slides\stata_guide\stata

* Data's from here http://data.london.gov.uk/dataset/metropolitan-police-service-recorded-crime-figures-and-associated-data/resource/e831234d-2bde-4fff-8ab8-7e2e70f0677a
local crimeData https://files.datapress.com/london/dataset/metropolitan-police-service-recorded-crime-figures-and-associated-data/2015-12-23T15:58:16/MASTER_mps-figures.xls

import excel `crimeData'

*******
* Specify the MOPAC sheet
clear all
import excel `crimeData', ///
	sheet("MOPAC Priority-Borough") ///
	cellrange(A3:AI58) ///

*******
* Tell stata that varnames are in the first row
clear all
import excel `crimeData', ///
	sheet("MOPAC Priority-Borough") ///
	cellrange(A3:AH58) ///
	firstrow

rename(BarkingDagenham-Westminster) mopac=

reshape long mopac, i(MonthYear) j(Borough) string

save data/MOPAC.dta, replace

clear all 

import excel `crimeData', ///
	sheet("Officer Strength-Borough") ///
	cellrange(A5:AG97) /// Note the change
	firstrow
	
cap rename A MonthYear

rename(BarkingDagenham-Westminster) offStrength=

reshape long offStrength, i(MonthYear) j(Borough) string

save data/offStrength.dta, replace



*******
*SgtStrength
clear all 
import excel `crimeData', ///
	sheet("Sergeant Strength-Borough") ///
	cellrange(A4:AG36) /// Note the change
	firstrow
	
cap rename A MonthYear

rename(BarkingDagenham-Westminster) sgtStrength=

reshape long sgtStrength, i(MonthYear) j(Borough) string

save data/sgtStrength.dta, replace


*******
*FoCrime
clear all
import excel `crimeData', ///
	sheet("Fear of Crime-Borough") ///
	cellrange(A3:AG31) /// Note the change
	firstrow
	
cap rename BarkingandDagenham BarkingDagenham /// They use a different name in this sheet...
	
cap rename A MonthYear

rename(BarkingDagenham-Westminster) foCrime=

keep if MonthYear > td(2sep2008) | MonthYear < td(2aug2008) /// There were 2 values for sep 2008, best to delete them both

reshape long foCrime, i(MonthYear) j(Borough) string

save data/foCrime.dta, replace

*******
* Merge the datasets
foreach i in "MOPAC" "offStrength" "sgtStrength" {
	display "`i'"
	merge m:m MonthYear Borough using "data/`i'
	drop _merge
}

gen foCrime2 = subinstr(foCrime,"%","",.)

destring foCrime2, replace

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


