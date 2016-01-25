clear

cd "/home/arndt/Dropbox/01 PhD/07 TA/stats1_2015/FDA"



*-------------------------------------------------------------------------------
* Wahlergebnisse
*-------------------------------------------------------------------------------

import delimited using btw2013endergebnis.csv, delimiters(";") clear


* Rename variables
rename nr no
rename gebiet district
rename gehrt landid
rename wahlberechtigte eligible
rename whler voters
* rename gltge valid1
* rename v18 valid2
rename cdu cdu1
rename v22 cdu2
rename spd spd1
rename v26 spd2
rename fdp fdp1
rename v39 fdp2
rename dielinke dielinke1
rename v34 dielinke2
rename grne greens1
rename v38 greens2
rename csu csu1
rename v42 csu2
rename piraten pirates1
rename v46 pirates2
rename afd afd1
rename v106 afd2 

* Keep only the renamed variables
keep no district landid eligible voters cdu* spd* dielinke* greens* csu* ///
	pirates* afd*

* Subset the data to districts only
drop in 1/2  // drop first two lines containing column labelling
drop if landid == "99" | district == "Bundesgebiet"  // drop federal states

* Destring the variables
destring landid-afd2, replace

* Create names for federal states
gen land = ""
replace land = "Schleswig-Holstein" if landid == 1
replace land = "Hamburg" if landid == 2 
replace land = "Lower Saxony" if landid == 3
replace land = "Bremen" if landid == 4
replace land = "North Rhine-Westphalia" if landid == 5
replace land = "Hesse" if landid == 6
replace land = "Rhineland-Palatinate" if landid == 7
replace land = "Baden-Württemberg" if landid == 8
replace land = "Bavaria" if landid == 9
replace land = "Saarland" if landid == 10
replace land = "Berlin" if landid == 11
replace land = "Brandenburg" if landid == 12
replace land = "Mecklenburg-Vorpommern" if landid == 13
replace land = "Saxony" if landid == 14
replace land = "Saxony-Anhalt" if landid == 15
replace land = "Thuringia" if landid == 16
order land, after(landid)

* Create the turnout variable
gen turnout = (voters/eligible) * 100
order turnout, after(voters)

* Turn cdu into cdu csu
replace cdu1 = csu1 if landid == 9
replace cdu2 = csu2 if landid == 9
rename cdu1 cducsu1
rename cdu2 cducsu2
drop csu*

* Turn number of votes into vote shares
foreach var of varlist cducsu1 cducsu2 spd1 spd2 dielinke1 dielinke2 ///
	greens1 greens2 pirates1 pirates2 afd1 afd2 {
replace `var' = (`var'/voters) * 100
}

saveold btw2013endergebnis.dta, replace


*-------------------------------------------------------------------------------
* Strukturdaten
*-------------------------------------------------------------------------------

import delimited using btw2013strukturdaten.csv, delimiters(";") clear

*rename variables
rename v2 no
rename v5 area
rename v6 population
rename v9 popdensity
rename v13 pop18_25
rename v14 pop25_35
rename v15 pop35_60
rename v16 pop60_75
rename v17 pop75_
rename v22 abitur
rename v27 localbusinesstax
rename v38 unemployment
rename v41 socialbenefits

* keep only renamed variables
keep no area population popdensity pop18_25 pop25_35 pop35_60 pop75_ ///
	abitur localbusinesstax unemployment socialbenefits
	
drop in 1/3  // drop first three lines
drop if no == ""  // drop empty lines

* drop all non district obs	
destring no, replace
drop if no > 900	

* remove space
replace area = subinstr(area, " ", "", .)
replace popdensity = subinstr(popdensity, " ", "", .)

* replace comma with dot
foreach var of varlist area population popdensity pop18_25 pop25_35 pop35_60 ///
	pop75_ abitur localbusinesstax unemployment socialbenefits {
		replace `var' = subinstr(`var', ",", ".", .)
}

* Destring the variables
destring area-socialbenefits, replace	

saveold btw2013strukturdaten.dta, replace

*-------------------------------------------------------------------------------
* Merge
*-------------------------------------------------------------------------------

use btw2013endergebnis.dta, clear

merge 1:1 no using btw2013strukturdaten.dta
drop _merge

label variable no "District ID"
label variable district "Name of district"
label variable landid "Federal State ID num"
label variable land "English name of federal state"
label variable eligible "Number of eligible citizens"
label variable voters "Number of eligible citizens that voted"
label variable turnout "Voter Turnout in %"
label variable cducsu1 "Vote Share for 'Erststimme' in %"
label variable cducsu2 "Vote Share for 'Zweitstimme' in %"
label variable spd1 "Vote Share for 'Erststimme' in %"
label variable spd2 "Vote Share for 'Zweitstimme' in %"
label variable dielinke1 "Vote Share for 'Erststimme' in %"
label variable dielinke2 "Vote Share for 'Zweitstimme' in %"
label variable greens1 "Vote Share for 'Erststimme' in %"
label variable greens2 "Vote Share for 'Zweitstimme' in %"
label variable pirates1 "Vote Share for 'Erststimme' in %"
label variable pirates2 "Vote Share for 'Zweitstimme' in %"
label variable afd1 "Vote Share for 'Erststimme' in %"
label variable afd2 "Vote Share for 'Zweitstimme' in %"
label variable area "Area in square kilometers - as of 31.12.2011"
label variable population "population in 1000 - as of 30.09.2012"
label variable popdensity "Population density (inhabitants per square km) - as of 31.12.2011"
label variable pop18_25 "Population between 18 and 25 in % - as of 31.12.2011"
label variable pop25_35 "Population between 25 and 35 in % - as of 31.12.2011"
label variable pop35_60 "Population between 35 and 60 in % - as of 31.12.2011"
label variable pop75_ "Population above 75 in % - as of 31.12.2011"
label variable abitur "Inhabitants with 'Abitur' (high school) in % "
label variable localbusinesstax "Local Business Tax Income in Euro/inhabitant - 2011"
label variable unemployment "Unemployment rate in % - end of December 2012"
label variable socialbenefits "Recipients of social benefits (SGB II) per 1000 inhabitants - as of 31.12.2012"

saveold btw2013.dta, replace
