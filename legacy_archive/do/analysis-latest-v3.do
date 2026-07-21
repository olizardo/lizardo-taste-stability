cd "C:\Users\olizardo\Google Drive\cultural-matching-ego-networks"
use egonet-turnover.dta, clear
qui bysort egoid: gen alterdiff = abs(numberalter_[_n] - numberalter_[_n-1])
joinby egoid time using club-turnover.dta, unmatched(master)
drop _merge
joinby egoid time using music-taste.dta, unmatched(master)
drop _merge
joinby egoid time using activ-taste.dta, unmatched(master)
drop _merge
joinby egoid time using book-taste.dta, unmatched(master)
drop _merge
joinby egoid time using cult-taste.dta, unmatched(master)

local i 1
local titles Music Activities Books Culture
foreach name in music activ book cult {
	local title : word `i' of `titles'
	quietly {
		xtpoisson `name'tastechange turnov clubturn c.time##c.time,i(ego) 
		est store mod1
		xtpoisson `name'tastegain turnov clubturn c.time##c.time,i(ego) 
		est store mod2
		xtpoisson `name'tasteloss turnov clubturn c.time##c.time,i(ego) 
		est store mod3
		}
	lab var turnover "Ego Network Turnover"
	lab var clubturnover "Club Turnover"
	coefplot ///
		(mod2, lab(Taste Gain) ///
		mfc(red) mc(red) msize(vlarge) ciopts(lc(red))) ///
		(mod3, lab(Taste Loss) ///
		mfc(blue) mc(blue) msize(vlarge) ciopts(lc(blue))), ///
		scheme(economist) drop(_cons *time) ///
		xline(0) level(90) xsize(3.5) ysize(4) msiz(large) ///
		plotr(color(white)) graphr(color(white)) ///
		legend(region(color(white))) ///
		name(`name',replace) title("`title'")
		window manage close graph
	local ++i
	}
graph combine music activ, ///
rows(1) xsize(6.5) ysize(4) ///
iscale(.6) graphr(color(white)) xcommon
