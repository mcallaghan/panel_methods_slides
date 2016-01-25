* Check http://huebler.blogspot.de/2012/08/stata-maps.html for instructions

ssc install spmap
ssc install shp2dta

cd "/home/arndt/Dropbox/01 PhD/07 TA/stats1_2015/FDA/map"

* Convert shapefile to Stata format
shp2dta using Geometrie_Wahlkreise_18DBT, data(btw13data) coor(btw13coor) ///
	genid(id) genc(c) replace
	
* Draw map with Stata
cd "/home/arndt/Dropbox/01 PhD/07 TA/stats1_2015/FDA"
use btw2013.dta, clear


gen id = no
replace turnout = round(turnout)
spmap turnout using map/btw13coor.dta, id(id)	

graphexportpdf map, dropeps
