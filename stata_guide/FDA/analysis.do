cd "/home/arndt/Dropbox/01 PhD/07 TA/stats1_2015/FDA"

use btw2013.dta, clear

replace east = landid >=12
drop if landid == 11
