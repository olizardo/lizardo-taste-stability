do "N:\Private\NETWORKS AND CULTURE\taste-change\dataproc-80-85-90.do"

foreach var of varlist music4 movie4 sports4 paper4 books4  spevent4 play4 videos4 hobby4 mags4 {
	recode `var' 4=3 5=4 
	lab val `var' music3
	}

local names Music Movies Sports_Team Paper Books Sports_Event Play Videos Hobbys Magazines
cap gen gamma=.
cap gen name=""
local i=1
foreach varname in music movie sports paper books  spevent play videos hobby mags {
	qui tab `varname'3 `varname'4,gamma
	qui replace gamma=`r(gamma)' in `i'
	local varname: word `i' of `names'
	qui replace name="`varname'" in `i'
	local i=`i'+1
	}
list name gamma in 1/10,clean

global vars videos3 videos4
preserve
	contract $vars
	qsymm _freq $vars,se mod(qs) deltatest alphatest
restore


*/estimating cultural taste change models*/
global cultlist music movie sports paper books  spevent videos hobby mags
global controls age3 educ3 income3 married3 childre3 working3 bigcity3 female nonwhite3
global demchang  chngfriends chorgs4 chngeduc chngmarital chngchildre chngwrkstat chngareanam 
est drop _all
local i=1
foreach name in $cultlist  {
	preserve 
		quietly {
			reshape long `name',i(id) j(wave)
			for var $demchang:replace X=0 if wave==3
			gen chng`name'=0 if `name'~=.
			by id:replace chng`name'=1 if `name'[_n]~=`name'[_n-1] & wave==4
			xi3:logit chng`name' $demchang $controls,cluster(id) /*discrete time logit regression*/
			est store mod`i'
			local i=`i'+1
			}
	restore
	}
estout mod*, ///
cells(b(star fmt(%9.3f)) ///
t(par fmt(%9.2f))) ///
stats(chi2 r2_p N, fmt(%9.2f %9.2f %9.0f) star(chi2)) ///
starlevels(* 0.10)  ///
label  varwidth(25)  style(fixed) legend ///
drop(female nonwhite3 age3 educ3 income3 married3 childre3 working3 bigcity3)

ren friends3 evefrnd3
gen friends3=.
local i=1
foreach num of numlist -1.1046  -0.0832   1.1878 {
	replace friends3=`num' if evefrnd3==`i'
	local i=`i'+1
	}
ren friends4 evefrnd4
gen friends4=.
local i=1
foreach num of numlist  -0.5484  -0.4217  -0.0140   0.3560   0.6281 {
	replace friends4=`num' if evefrnd4==`i'
	local i=`i'+1
	}
for var friends3 friends4:replace X=X*-1
	
*/estimating the effect of cultural taste on network stability*/
est drop _all
global indvars educ married childre age bigcity
foreach depvar in friends numsocmems {
	preserve
		foreach name in numcult $indvars {
			rename `name'3 `name'
			}
		qui eststo:regress `depvar'4 numcult female $indvars
		foreach name in numcult $indvars {
			rename `name' `name'3
			}		
		reshape long `depvar',i(id) j(wave)
		foreach varname in numcult $indvars {
			qui gen `varname'=.
			forval i=3/4 {
				qui replace `varname'=`varname'`i' if wave==`i' 
				}
			}
		quietly {		
			eststo:xtreg `depvar' numcult female $indvars,re i(id)
			eststo:xtivreg `depvar' female $indvars (numcult=music2 movie2 sports2 paper2 books2 spevent2 hobby2 mags2 evefrnd2),re i(id)
			}	
	restore
	}
esttab,starlevels(+ 0.10 * 0.05) compress	nolines stats(r2 r2_w r2_b chi2 N) 


