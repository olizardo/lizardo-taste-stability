use "N:\Private\taste-change\pc1985-95.dta", clear
*/recoding cultural taste variables*/
recode tv5 3/5=1 0/1=3 6/9=3
ren atplay3 play3
for var music* movie* books* spevent* play* mags* paper*:recode X 0=3 8/9=3
*for var music3 movie3 books3 sports3 spevent3 play3 videos3 mags3 tv3 paper3:recode X 3/4=3
for var music5 movie5 books5 spevent5 play5 mags5 paper5:recode X 1/2=1 3/5=2 6=3 7=4
foreach name in music movie books spevent play mags paper {
	lab val `name'5 `name'3
	}
gen cultscal3=0 if music3~=.
gen cultscal5=0 if music5~=.
foreach name in music movie books spevent play mags paper {
	replace cultscal3=cultscal3+1 if `name'3==1
	replace cultscal5=cultscal5+1 if `name'5==1
	gen gain`name'=`name'3>2&`name'5<3 if `name'3~=.
	}
gen cultscaldiff=cultscal5-cultscal3
recode cultscal3 6/9=6,g(cultscal3trunc)
lab def cultscal3 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6+"
lab val cultscal3trunc cultscal3


*/recoding demographic variables*/
for var marital* childre* friends* chorgs5:recode X 0=.
recode marital5 9=2
recode marital3 2=5 3=4 4=3 5=6 6/9=2
for var marital3 marital5:recode X 3/4=4
lab val marital3 marital5
for var childre*:recode X 1/8=1 .=0

lab def wrkstat 1 "full time" 2 "part time" 3 "unemployed" 4 "retired" 5 "keeping house" 6 "other"
recode wrkstat5 0=1 2=1 3=5 5=6 6=2 7=2 8=3 9=6
recode wrkstat3 0=6 2=1 3=2 4=2 5=3 6=4 7=5 8=6
for var wrkstat*:lab val X wrkstat

gen friendscat=friends5
lab val friendscat friends5
recode friends5 1/2=1 3/5=2 6/7=3,g(recfriends5)
recode friends3 8/9=.
lab val recfriends5 friends3
gen revfriends5=(recfriends5-4)*-1
gen revfriends3=(friends3-4)*-1
gen keepfrdfreq=revfriends5==3&revfriends3==3

gen nonwhite=race3~=1 
gen married3=marital3==1
gen married5=marital5==1
gen working3=wrkstat3<3
gen working5=wrkstat5<3
gen female=gender3==1
gen college5=educ5>=4 if educ5~=.
gen college3=educ5>=4 if educ3~=.
gen bigcity5=categor5==1 
gen bigcity3=categor3==1

*/creating network change indicators*/
foreach name in marital childre wrkstat areanam friends income educ college working married bigcity {
	gen chng`name'=`name'5~=`name'3 if `name'5~=.&`name'3~=.
	drop if `name'5==.|`name'3==.
	}
qui gen chngfam=chngmarital==1|chngchildre==1
for var income*:recode X 0=6
qui gen incomediff=income5-income3
qui gen educdiff=educ5-educ3
recode educdiff -100/0=0
qui gen chorgs=chorgs5~=3 if chorgs5~=.
qui gen chngmems=0
qui gen nummems3=0 if mempriv3~=.
qui gen nummems5=0 if mempriv5~=.
foreach name in   mempriv memunio mempoli memserv memspor memhobb memnat memchur memgree memfarm  memoth {
	qui replace chngmems=chngmems+1 if `name'5~=`name'3
	qui replace nummems3=nummems3+1 if `name'3>0&`name'3~=.
	qui replace nummems5=nummems5+1 if `name'5>0&`name'5~=.
	}
recode chngmems 1/6=1,g(chngmemsbin)
gen memdiff=nummems5-nummems3
gen numsocmems=0
qui gen numsocmems3=0 if mempriv3~=.
qui gen numsocmems5=0 if mempriv5~=.
foreach name in mempriv memserv memspor memhobb {
	qui replace numsocmems3=numsocmems3+1 if `name'3>0&`name'3~=.
	qui replace numsocmems5=numsocmems5+1 if `name'5>0&`name'5~=.
	qui gen keep`name'mem=`name'3==1&`name'5==1
	}
for var numsocmems3 numsocmems5:recode X 1/8=1,g(Xbin)
gen socmemdiff=numsocmems5-numsocmems3
gen keepmems= numsocmems3>=1& numsocmems5>=1

recode age5 18/44=1 45/54=2 55/100=3 0=3,g(agegp5)
tab agegp5,g(age5)

gen bigcitydiff=(categor5-categor3)*-1
*format educ3 age3 chngfriends chngmems chngareanam chngwrkstat chngfam  revfriends3 nummems3 cultscal3 cultscaldiff female educ5  age51 age52 age53 married5 childre5 working5 nonwhite bigcity5 %9.2f
center age3 educ3 childre3

lab var educ3 "Education (1985)"
lab var age3 "Age (1985)"
lab var gender3 "Gender (Male=1)"
lab var chngfriends "Social Interaction"
lab var chngfam "Family Arrangements"
lab var chngwrkstat "Work Status"
lab var chngareanam "Geographic Location"
lab var chngmemsbin "Organizational Memberships"
lab var nonwhite "Race (non-White=1)
lab var female "Gender (Women=1)"
lab var income3 "Family Income (1985)"