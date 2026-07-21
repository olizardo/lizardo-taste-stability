use "N:\Private\SOCIOLOGY OF CULTURE\taste-change\PCS\pc1980-85-90.dta", clear
cd "N:\Private\SOCIOLOGY OF CULTURE\taste-change"

ren atplay3 play3
ren magazin2 mags2
ren evefrnd2 friends2

/*recoding missing values*/
for var  music* movie* sports* paper* books* spevent* play* videos* hobby* mags* friends* dance* lounge*:recode X 0=. 8/9=.

/*recoding frequency categories to tripartite scheme*/
for var  music4 movie4 sports4 paper4 books4 spevent4 play4 videos4 hobby4 mags4  friends4 dance4 lounge4:recode X 4=2 5=3
for var  music3 movie3 sports3 paper3 books3 spevent3 play3 videos3 hobby3 mags3 friends3 dance3 lounge3:recode X 4=3

/*relabaling culture variables*/
lab def newlab 1 "Very Often" 2 "Sometimes" 3 "Hardly ever or never"
for var music* movie* sports* paper* books* spevent* play* videos* hobby* mags* friends* dance* lounge*:lab val X newlab

*/recoding demographic variables*/
for var marital* childre* friends* chorgs*:recode X 0=.
for var marital*:recode X 9=2
lab def wrkstat 1 "full time" 2 "part time" 3 "unemployed" 4 "retired" 5 "keeping house" 6 "other"
for var wrkstat*:recode X 0=6 2/4=2 5=3 6=4 7=5 8=6 9=6
cap lab def wrkstat 1 "Full time" 2 "Part time" 3 "Unemployed" 4 "Retired" 5 "Keeping house" 6 "Other"
for var wrkstat*:lab val X wrkstat
for var educ*:recode X 0=1 9=1
for var chorgs*:recode X 8=3
ren province provinc4

chng_logit hobby




