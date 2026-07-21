do "N:\Private\NETWORKS AND CULTURE\taste-change\dataproc-85-90.do",clear

gen moviebin1=movie4==5 if movie4~=.
gen moviebin2=movie5>5 if movie5~=.

gen musicbin1=music4>3 if music4~=.
gen musicbin2=music5>4 if music5~=.

gen sportsbin1=sports4==5 if sports4~=.
gen sportsbin2=sports5>5 if sports5~=.

foreach name in music movie sports paper books  spevent play videos hobby mags tv {
	local j=1
	forval i=4/5 {
		qui gen `name'bin`j'=`name'`i'==1 if `name'`i'~=.
		local j=`j'+1
		}
	}
 
polychoric music3 movie3 sports3 paper3 books3 spevent3 videos3 hobby3 mags3 music4 movie4 sports4 paper4 books4 spevent4 videos4 hobby4 mags4

polychoric music4 movie4 sports4 paper4 books4 spevent4 play4 videos4 hobby4 mags4 tv4 music5 movie5 sports5 paper5 books5 spevent5 play5 videos5 hobby5 mags5 tv5

polychoric music3 movie3 sports3 paper3 books3 spevent3 videos3 hobby3 mags3 music5 movie5 sports5 paper5 books5 spevent5 videos5 hobby5 mags5





*/estimating cultural taste change models*/

*/discrete time logit regression*/
global cultlist music movie spevent books play paper mags
global demchang chngfriends chngmemsbin chngareanam chngwrkstat   chngfam chngincome chngeduc 
global controls age educ income married childre working bigcity
est drop _all
local i=1
foreach name in $cultlist  {
	qui reshape long `name',i(id) j(choice)
	qui by id:gen time=_n
	for var $demchang:qui replace X=0 if time==1
	qui gen chng`name'=0 if `name'~=.
	qui by id:replace chng`name'=`name'-`name'[_n-1]
	qui recode chng`name' .=0 -3/-1=1 1/3=1
	foreach x in $controls {
		qui gen `x'=.
		qui qui replace `x'=`x'3 if time==1
		qui replace `x'=`x'4 if time==2
		}
	qui xi3:logit chng`name' $demchang female nonwhite $controls,cluster(id3)
	est store mod`i'
	*foreach var of varlist chngfriends chngmemsbin chngareanam {
	*	postgr3 `var',nodraw gen(`name'`var') table
	*	}
	local i=`i'+1
	for var $demchang:qui replace X=X[_n+1] if time==1
	drop time chng`name' $controls
	*drop `name'chng*
	qui reshape wide `name',i(id3) j(choice) 
	}
estout mod*, ///
cells(b(star fmt(%9.3f)) ///
t(par fmt(%9.2f))) ///
stats(chi2 r2_p N,fmt(%9.2f %9.2f %9.0f) star(chi2)) ///
starlevels(+ 0.10 * 0.05 ** 0.01)  ///
label  varwidth(33)  style(fixed) legend ///
drop(female nonwhite age educ income married childre working bigcity)

*/estimating the effect of cultural taste on network stability*/
do "N:\Private\taste-change\taste-change-taste-change-dataproc.do"
cap drop yhat*
global mod   cultscal3trunc female nonwhite age3 educ3 income3 married3 childre3 working3 bigcity3 educdiff incomediff bigcitydiff chngmems chngareanam chngwrkstat chngfam 
est drop _all
qui xi3:logit keepfrdfreq $mod
est store mod1
qui postgr3 cultscal3trunc, gen(yhatfrd) nodraw
qui xi3:logit keepmems $mod
est store mod2
qui postgr3 cultscal3trunc, gen(yhatmem) nodraw
estout mod*, ///
cells(b(star fmt(%9.3f)) ///
t(par fmt(%9.2f))) ///
stats(chi2 r2_p N,fmt(%9.2f %9.2f %9.0f) star(chi2)) ///
starlevels(+ 0.10 * 0.05 ** 0.01)  ///
label  varwidth(33)  style(fixed) legend  

*/creating predicted probability graph*/
format cultscal3 %9.0f
line  yhatfrd yhatmem cultscal3trunc,sort ///
legend(label(1 "Retention of high frequency" "of socal interaction")label(2 "Retention of Orgs. Memberships")) ///
xtitle("N. of Cultural Tastes (1985)") ///
ytitle("Predicted Probability (1995)") ///
yline(.2678133 .3882064,lc(gray)) ///
text(.26 4 "Expected Retention Probability (Interaction)",size(vsmall) color(gray)) ///
text(.38 4 "Expected Retention Probability (Memberships)",size(vsmall) color(gray)) ///
ylab(0(.1).6,glc(gs8) glp(dot)) xlab(0(1)6,val)

*/testing proportional odds assumption*/
xi3:omodel logit friends5 revfriends3 cultscal3 cultscaldiff $mod

