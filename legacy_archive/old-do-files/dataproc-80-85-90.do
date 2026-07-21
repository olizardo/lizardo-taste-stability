use "N:\Private\NETWORKS AND CULTURE\taste-change\pc1980-85-90.dta",clear
ren atplay3 play3
ren magazin2 mags2
*/creating cultural taste scales
forval i=3/4 {
	for var  music`i' movie`i' sports`i' paper`i' books`i' play`i' spevent`i' videos`i'  hobby`i' tv`i' mags`i'  friends`i':recode X 0=. 8/9=.
	}
for var  music2 movie2 sports2 paper2 books2 spevent2 hobby2 mags2 evefrnd2:recode X 0=. 8/9=.

*/recoding demographic variables*/
for var marital* childre* friends* chorgs*:recode X 0=.

lab def wrkstat 1 "full time" 2 "part time" 3 "unemployed" 4 "retired" 5 "keeping house" 6 "other"
for var wrkstat*:recode X 0=6 2=1 3=2 4=2 5=3 6=4 7=5 8=6
for var wrkstat*:lab val X wrkstat
recode friends3 4=3

gen white=race3==1 
gen married4=marital4==1
gen married3=marital3==1
gen working4=wrkstat4<3
gen working3=wrkstat3<3
gen female=gender3==1
gen college3=educ3>=4 if educ3~=.
gen college4=educ3>=4 if educ4~=.
gen bigcity3=categor3==1 
gen bigcity4=categor4==1
for var income*:recode X 0=6

*/creating network change indicators*/
foreach name in marital childre wrkstat areanam friends income educ college working married categor  {
	gen chng`name'=`name'3~=`name'4 if `name'3~=.&`name'4~=.
	drop if `name'3==.|`name'4==.
	}
recode age3 19/29=1 30/44=2 45/59=3 60/100=4,g(agegrp3)
tab agegrp3,g(agecat)

ren memothe4 memoth4
qui gen chngmems=0
qui gen nummems3=0 if mempriv3~=.
qui gen nummems4=0 if mempriv4~=.
foreach name in   mempriv memunio mempoli memserv memspor memhobb memnat memchur memgree memfarm  memoth {
	qui replace chngmems=chngmems+1 if `name'4~=`name'3
	qui replace nummems3=nummems3+1 if `name'3>0&`name'3~=.
	qui replace nummems4=nummems4+1 if `name'4>0&`name'4~=.
	}
recode chngmems 1/6=1,g(chngmemsbin)
gen memdiff=nummems4-nummems3
qui gen numsocmems3=0 if mempriv3~=.
qui gen numsocmems4=0 if mempriv4~=.
foreach name in mempriv memserv memspor memhobb {
	qui replace numsocmems3=numsocmems3+1 if `name'3>0&`name'3~=.
	qui replace numsocmems4=numsocmems4+1 if `name'4>0&`name'4~=.
	qui gen keep`name'mem=`name'3==1&`name'4==1
	}
for var numsocmems3 numsocmems4:recode X 1/8=1,g(Xbin)
gen socmemdiff=numsocmems4-numsocmems3
gen keepmems= numsocmems3>=1& numsocmems4>=1


lab var educ3 "Education (1985)"
lab var age3 "Age (1985)"
lab var gender3 "Gender (Male=1)"
lab var chngfriends "Social Interaction"
lab var chngmarital "Marital Status"
lab var chngchildre "Number of Children"
lab var chngwrkstat "Work Status"
lab var chngcategor "City Size"
lab var chngeduc "Educational Status"
lab var chngareanam "Geographic Location"
lab var chorgs4 "Organizational Memberships"
lab var white "Race (White=1)
lab var female "Gender (Women=1)"
lab var income3 "Family Income (1985)"

/*polychoric music3 movie3 sports3 paper3 books3  spevent3 videos3 hobby3 mags3 play3
mat R3=r(R)
polychoric music4 movie4 sports4 paper4 books4  spevent4 videos4 hobby4 mags4 play4
mat R4=r(R)
factormat R3,pcf n(544)
predict cultfac3
factormat R4,pcf n(505)
predict cultfac4
for var cultfac*:replace X=X*-1
*/

gen numsocmem4=0 if mempriv4~=.
for var mempriv4-memoth4:replace numsocmem4=numsocmem4+1 if X==1
gen numsocmem3=0 if mempriv3~=.
for var mempriv3-memoth3:replace numsocmem3=numsocmem3+1 if X==1

gen numcult3=0 if music3~=.
for var music3 movie3 play3 sports3 paper3 books3  spevent3 videos3 hobby3 mags3:replace numcult3=numcult3+1 if X<3

gen numcult4=0 if music4~=.
for var music4 movie4 play4 sports4 paper4 books4  spevent4 videos4 hobby4 mags4:replace numcult4=numcult4+1 if X<3

gen numcult2=0 if music2~=.
for var music2 movie2 sports2 paper2 books2 spevent2 hobby2 mags2:replace numcult2=numcult2+1 if X<3


*outsheet numcult4 numcult3   friends3 friends4 numsocmems4 numsocmems3 female nonwhite3 age3 educ3 income3 married3 childre3 working3 bigcity3 ses3 using "C:\Documents and Settings\olizardo\Desktop\cultrecip.csv",comma nolab replace

gen mems3= mempriv3==1|memserv3==1|memspor3==1|memhobb3==1|memoth3==1
gen mems4= mempriv4==1|memserv4==1|memspor4==1|memhobb4==1|memoth4==1

