cap gen logdur = ln(duration)
xtlogit decay c.nmatch_open##b7.rel  c.nmatch_close##b7.rel c.time, i(egoid)
margins,dydx(nmatch_open) over(rel)
marginsplot,horiz xline(0) scheme(s1mono) ///
plot1opts(recast(scatter) mfc(black) msiz(large)) ///
 title("N. of Matches (Open Choice)") ylab(,nogrid) ///
ciopts(recast(rspike)) name(open,replace)

margins,dydx(nmatch_close) over(rel)
marginsplot,horiz xline(0) scheme(s1mono) ///
plot1opts(recast(scatter) mfc(black) msiz(large)) ///
 title("N. of Matches (Forced Choice)") ylab(,nogrid) ///
ciopts(recast(rspike)) name(close,replace)

graph combine open close,cols(1) ysize(6.5) xcommon

/*
local llimits -.75 -.75 -.75
local rlimits .25 .52 .25 
local hops .25 .25 .25 
local titles Positive_Strong Positive_Weak Negative
local i 1
foreach stub in str wk neg  {
	local title : word `i' of `titles'
	local llimit : word `i' of `llimits'
	local rlimit : word `i' of `rlimits'
	local hop : word `i' of `hops'
	coefplot mod, ///
	xline(0, lc(yellow) lw(thick)) scheme(economist) keep(*`stub'*)  ///
	msize(vlarge) mfc(red) mc(red) name(`stub'2,replace) ///
	ciopts(lc(red) lw(thick)) title("`title'") ///
	xscal(range(`limit' .5)) xlab(`llimit'(`hop')`rlimit') ///
	coeflabels( ///
		1.music_`stub'_match = Music ///
		1.movies_`stub'_match = Movies ///
		1.books_`stub'_match = Books ///
		1.sports_`stub'_match = Sports ///
		1.games_`stub'_match = Games ///
		1.outdoor_`stub'_match = Outdoors ///
		)
	window manage close graph
	local ++i
	}
graph combine str2 wk2, rows(1) xsize(6.5)  title("Kin") name(kin,replace)

graph combine friends kin, rows(2) xsize(6.5) iscale(.7) ysize(6.5) plotr(fc(white))

