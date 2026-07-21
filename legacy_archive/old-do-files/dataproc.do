use "N:\Private\NETWORKS AND CULTURE\taste-change\pc1985-90-95.dta", clear

*/creating cultural taste scales
forval i=3/5 {
	for var  music`i' movie`i' sports`i' paper`i' books`i' spevent`i' videos`i'  hobby`i' mags`i' tv`i'  friends`i':recode X 0=. 8/9=.
	}
for var play4 play5 art5 ballet5:recode X 0=. 8/9=.

for var music3 movie3 sports3 paper3 books3 spevent3  videos3  hobby3 mags3 tv3:gen Xbin=X<4
for var music4 movie4 sports4 paper4 books4 spevent4  play4 videos4  hobby4 mags4:gen Xbin=X<5
gen tv4bin=tv4<6
for var music5 movie5 sports5 paper5 books5 spevent5  play5 videos5  hobby5 mags5 art5 ballet5:gen Xbin=X<6
gen tv5bin=tv5<6


forval i=3/5 {
	egen numcultact`i'=rsum2(music`i'bin-tv`i'bin),allmiss
	}


*/recoding demographic variables*/
for var marital* childre* friends* chorgs5:recode X 0=.
recode marital5 9=2
recode marital4 2=5 3=4 4=3 5=6 6/9=2
for var marital4 marital5:recode X 3/4=4
lab val marital4 marital5
for var childre*:recode X 1/8=1 .=0

lab def wrkstat 1 "full time" 2 "part time" 3 "unemployed" 4 "retired" 5 "keeping house" 6 "other"
recode wrkstat5 0=1 2=1 3=5 5=6 6=2 7=2 8=3 9=6
recode wrkstat4 0=6 2=1 3=2 4=2 5=3 6=4 7=5 8=6
for var wrkstat*:lab val X wrkstat

gen nonwhite=race4~=1 
gen married4=marital4==1
gen married5=marital5==1
gen working4=wrkstat4<3
gen working5=wrkstat5<3
gen female=gender4==1
gen college5=educ5>=4 if educ5~=.
gen college4=educ5>=4 if educ4~=.
gen bigcity5=categor5==1 
gen bigcity4=categor4==1

*/creating network change indicators*/
foreach name in marital childre wrkstat areanam friends income educ college working married bigcity {
	gen chng`name'=`name'5~=`name'4 if `name'5~=.&`name'4~=.
	drop if `name'5==.|`name'4==.
	}
qui gen chngfam=chngmarital==1|chngchildre==1
for var income*:recode X 0=6
qui gen incomediff=income5-income4
qui gen educdiff=educ5-educ4
recode educdiff -100/0=0
qui gen chorgs=chorgs5~=3 if chorgs5~=.
qui gen chngmems=0
qui gen nummems4=0 if mempriv4~=.
qui gen nummems5=0 if mempriv5~=.
foreach name in   mempriv memunio mempoli memserv memspor memhobb memnat memchur memgree memfarm  memoth {
	qui replace chngmems=chngmems+1 if `name'5~=`name'4
	qui replace nummems4=nummems4+1 if `name'4>0&`name'4~=.
	qui replace nummems5=nummems5+1 if `name'5>0&`name'5~=.
	}
recode chngmems 1/6=1,g(chngmemsbin)
gen memdiff=nummems5-nummems4
gen numsocmems=0
qui gen numsocmems4=0 if mempriv4~=.
qui gen numsocmems5=0 if mempriv5~=.
foreach name in mempriv memserv memspor memhobb {
	qui replace numsocmems4=numsocmems4+1 if `name'4>0&`name'4~=.
	qui replace numsocmems5=numsocmems5+1 if `name'5>0&`name'5~=.
	qui gen keep`name'mem=`name'4==1&`name'5==1
	}
for var numsocmems4 numsocmems5:recode X 1/8=1,g(Xbin)
gen socmemdiff=numsocmems5-numsocmems4
gen keepmems= numsocmems4>=1& numsocmems5>=1

recode age5 18/44=1 45/54=2 55/100=3 0=3,g(agegp5)
tab agegp5,g(age5)

gen bigcitydiff=(categor5-categor4)*-1

lab var educ4 "Education (1985)"
lab var age4 "Age (1985)"
lab var gender4 "Gender (Male=1)"
lab var chngfriends "Social Interaction"
lab var chngfam "Family Arrangements"
lab var chngwrkstat "Work Status"
lab var chngareanam "Geographic Location"
lab var chngmemsbin "Organizational Memberships"
lab var nonwhite "Race (non-White=1)
lab var female "Gender (Women=1)"
lab var income4 "Family Income (1985)"

global semvars  stdcultscal4 stdcultscal5 numcultact4 numcultact5 friends5 friends4 numsocmems4 numsocmems5 music4 movie4 sports4 paper4 books4 spevent4  play4 videos4  hobby4 psport4 mags4 tv4  music5 movie5 sports5 paper5 books5 spevent5  play5 videos5  hobby5 psport5 mags5 tv5 female nonwhite age4 educ4 income4 married4 childre4 working4 bigcity4
outsheet $semvars using "C:\Documents and Settings\olizardo\Desktop\cultrecip.csv",comma nolab replace