use "N:\Private\NETWORKS AND CULTURE\taste-change\pc1985-95.dta", clear
for var  music* movie* sports* paper* books* spevent* play* videos* hobby* mags* tv* friends*:recode X 0=. 9=.
for var  music5 movie5 sports5 paper5 books5 spevent5 play5 videos5 hobby5 mags5 tv5:recode X 2/3=2 4/5=3 6/7=4
lab def newlab5 1 "Daily" 2 "Weekly" 3 "Monthly" 4 "Hardly ever or never"
for var  music5 movie5 sports5 paper5 books5 spevent5 play5 videos5 hobby5 mags5 tv5:lab val X newlab5



preserve
	contract music3 music5,zero nomiss
	list _freq,clean 
restore

discard



use "N:\Private\NETWORKS AND CULTURE\taste-change\pc1990-95.dta", clear
for var  music* movie* sports* paper* books* spevent* play* videos* hobby* mags* tv*:recode X 0=. 9=.
for var  music5 movie5 sports5 paper5 books5 spevent5 play5 videos5 hobby5 mags5 tv5:recode X 2/3=2 4/5=3 6/7=4
lab def newlab5 1 "Daily" 2 "Weekly" 3 "Monthly" 4 "Hardly ever or never"
for var  music5 movie5 sports5 paper5 books5 spevent5 play5 videos5 hobby5 mags5 tv5:lab val X newlab5


preserve
	contract music4 music5,zero nomiss
	list _freq,clean 
restore

use "N:\Private\NETWORKS AND CULTURE\taste-change\pc1985-90.dta",clear
for var  music* movie* sports* paper* books* spevent* play* videos* hobby* mags* tv*:recode X 0=. 9=.
for var  music3 movie3 sports3 paper3 books3 spevent3 videos3 hobby3 mags3 tv3: recode X 2=1 3=0 4=0 5=0
for var  music4 movie4 sports4 paper4 books4 spevent4 play4 videos4 hobby4 mags4 tv4:recode X 2=1 3=0 4=1 5=0

preserve
	contract music3 music4,zero nomiss
	list _freq,clean 
restore



