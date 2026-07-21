use "N:\Private\taste-change\pc1985-95.dta", clear
*/recoding cultural taste variables*/
ren atplay3 play3
for var music* movie* books* spevent* play*:recode X 0=. 8/9=3
for var music3 movie3 books3 spevent3 play3:recode X 3/4=3
for var music5 movie5 books5 spevent5 play5:recode X 1/2=1 3/5=2 6=3 7=3
foreach name in music movie books spevent play  {
	lab val `name'5 `name'3
	gen chng`name'1=`name'5~=`name'3 if `name'5~=.&`name'3~=.
	gen chng`name'2=(`name'3<3&`name'5>2)|(`name'3>2&`name'5<3)
	gen chng`name'3=abs(`name'3-`name'5)
	}
forval i=1/3 {
	egen chngtaste`i'=rsum2(chng*`i'),allmiss
	}

*/recoding demographic variables*/
for var marital* childre* friends* chorgs5:recode X 0=.
recode marital5 9=2
recode marital3 2=5 3=4 4=3 5=6 6/9=2
lab val marital3 marital5
for var marital3 marital5:recode X 3/4=4
for var childre*:recode X 1/8=1 .=0
lab def wrkstat 1 "full time" 2 "part time" 3 "unemployed" 4 "retired" 5 "keeping house" 6 "other"
recode wrkstat5 0=1 2=1 3=5 5=6 6=2 7=2 8=3 9=6
recode wrkstat3 0=6 2=1 3=2 4=2 5=3 6=4 7=5 8=6
for var wrkstat*:lab val X wrkstat
recode friends5 3/4=3 5=4 6/7=5
recode friends3 8/9=.
lab val friends5 friends3
foreach name in marital childre wrkstat friends areanam income {
	lab val `name'5 `name'4
	gen chng`name'=`name'5~=`name'3 if `name'5~=.&`name'3~=.
	}
gen chorgs=chorgs5~=3 if chorgs5~=.
gen chngfam=chngmarital==1|chngchildre==1

egen chngscal=rsum2(chngfam chngwrkstat chorgs chngfriends chngareanam chngincome),allmiss

preserve
recode chngscal 5/6=5
recode chngtaste1 4/5=4
tab chngscal chngtaste2,chi2
polychoric chngscal chngtaste1
restore

global cultlist music movie books spevent play
global demchang chngfriends chorgs chngfam chngwrkstat chngincome chngareanam

foreach name in $cultlist  {
	preserve
	qui reshape long `name',i(id3) j(choice)
	qui gen tastechang=0 if `name'~=.
	qui by id3:replace tastechang=`name'-`name'[_n-1]
	qui recode tastechang .=0 -2/-1=1 1/2=1
	ren tastechang chng`name'
	sum chng`name'
	restore
	}
foreach name in $cultlist  {
	preserve
	qui reshape long `name',i(id3) j(choice)
	qui gen tastechang=0 if `name'~=.
	qui by id3:replace tastechang=`name'-`name'[_n-1]
	qui recode tastechang .=0 -2=1 2=1 -1=0 1=0
	ren tastechang chng`name'
	sum chng`name'
	restore
	}

est drop _all
local i=1
foreach name in $cultlist  {
	preserve
	qui reshape long `name',i(id3) j(choice)
	qui by id3:gen time=_n
	for var $demchang:qui replace X=0 if time==1
	qui gen tastechang=0 if `name'~=.
	qui by id3:replace tastechang=`name'-`name'[_n-1]
	qui recode tastechang .=0 -2/-1=1 1/2=1
	qui xi3:xtlogit tastechang $demchang i.gender3 age3 educ3 chngeduc,i(id3)
	est store mod`i'
	local i=`i'+1
	restore
	}
estout mod*, ///
cells(b(star fmt(%9.4f)) ///
t(par fmt(%9.2f))) ///
stats(chi2 rho N,fmt(%9.2f %9.2f %9.0f) star(chi2 rho)) ///
starlevels(+ 0.10 * 0.05 ** 0.01)  ///
label  varwidth(15)  style(fixed) legend 
