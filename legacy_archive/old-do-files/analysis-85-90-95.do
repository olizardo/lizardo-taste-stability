do "N:\Private\NETWORKS AND CULTURE\taste-change\dataproc-80-85-90.do"
gen chorgs=chorgs4
recode chorgs 3=0 1/2=1

foreach var in music books sports videos {
	recode `var'4 4=2 5=3
	recode `var'3 4=3
	}

*/discrete time logit regression*/
global cultlist music books sports videos
global demchang chngfriends chngmems chngareanam chngeduc chngmarital chngwrkstat chngchildre   
global controls age educ income married childre working bigcity
est drop _all
local i=1
foreach name in $cultlist  {
	preserve
	qui reshape long `name',i(id) j(wave)
	for var $demchang:qui replace X=0 if wave==3
	qui gen tasteloss`name'=0 if `name'~=.
	*qui by id:replace tasteloss`name'=1 if (`name'[_n]==3&`name'[_n-1]<3) & wave==4
	qui by id:replace tasteloss`name'=1 if (`name'[_n]~=`name'[_n-1]) & wave==4
	foreach x in $controls {
		qui gen `x'=.
		qui qui replace `x'=`x'3 if wave==3
		qui replace `x'=`x'4 if wave==4
		}
	qui logit tasteloss`name' $demchang female $controls,cluster(id)
	postgr3 chngfriends
	est store mod`i'
	local i=`i'+1
	restore
	}
estout mod*, ///
cells(b(star fmt(%9.3f)) ///
t(par fmt(%9.2f))) ///
stats(chi2 r2_p N,fmt(%9.2f %9.2f %9.0f) star(chi2)) ///
starlevels(* 0.10)  ///
label  varwidth(33)  style(fixed) legend ///
drop(female $controls)

