use "N:\Private\NETWORKS AND CULTURE\taste-change\PCS\pc1980-85-90.dta", clear
ren atplay3 play3
ren magazin2 mags2
ren evefrnd2 friends2
for var  music* movie* sports* paper* books* spevent* play* videos* hobby* mags* friends* dance* lounge*:recode X 0=. 8/9=.
for var  music4 movie4 sports4 paper4 books4 spevent4 play4 videos4 hobby4 mags4  friends4 dance4 lounge4:recode X 4=2 5=3
for var  music3 movie3 sports3 paper3 books3 spevent3 play3 videos3 hobby3 mags3 friends3 dance3 lounge3:recode X 4=3
lab def newlab 1 "Very Often" 2 "Sometimes" 3 "Hardly ever or never"
for var music* movie* sports* paper* books* spevent* play* videos* hobby* mags* friends* dance* lounge*:lab val X newlab

est drop _all
preserve
for var sports*:recode X 2/3=0
for var sports* age* educ* gender*:drop if X==.
reshape long sports,i(id) j(wave)
qui bysort id:gen n_waves=_N
drop if n_waves~=3
foreach varname in educ age gender {
	gen `varname'=.
	forval i=2/4 {
		replace `varname'=`varname'`i' if wave==`i'
		}
	}	
bysort id:gen lag_sports=sports[_n-1]
bysort id:gen lag_educ=educ[_n-1]
qui eststo:xi:xtlogit sports educ age i.gender if wave>2,i(id) re 
qui eststo:xi:xtlogit sports lag_sports educ age i.gender,i(id)
qui eststo:xi:xtlogit sports educ age i.gender lag_educ,i(id)
restore
esttab,starlevels(* 0.10  ** 0.05) compress	nolines stats(ll chi2 N) 