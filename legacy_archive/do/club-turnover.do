clear
insheet using "C:\Users\olizardo\Google Drive\NetSense\WORK\Matt Work\demsurveyMergedCoded.csv"
gen counter = 1
drop if egoid == .
qui bysort egoid : gen dups = sum(counter)
drop if dups > 1
keep egoid clubscode*_*
for var clubscode*_* : destring X,replace ignore(NA)

reshape long clubscode1_ clubscode2_ clubscode3_ clubscode4_ clubscode5_ clubscode6_ clubscode7_ clubscode8_ ///
clubscode9_ clubscode10_,i(egoid) j(time)
gen egoclubid = _n
foreach name in clubscode1 clubscode2 clubscode3 clubscode4 clubscode5 clubscode6 clubscode7 clubscode8 clubscode9 clubscode10 {
	ren `name'_ `name'
	}
	
reshape long clubscode,i(egoclubid) 
drop if clubscode == .


cap gen clubjaccard = . 
qui levelsof egoid,l(egos)
foreach i of local egos {
	levelsof time if egoid == `i',l(waves)
	local nwaves : list sizeof local(waves)
	local j 1
	local k 2
	while `k' <= `nwaves' {
		local t1 : word `j' of `waves'
		local t2 : word `k' of `waves'
		levelsof clubscode if egoid == `i' & time == `t1',l(alters1)
		levelsof clubscode if egoid == `i' & time == `t2',l(alters2)
		local inter : list alters1 & alters2
		local union : list alters1 | alters2
		local s1 : list sizeof local(inter)
		local s2 : list sizeof local(union)
		replace clubjaccard = `s1' / `s2' if egoid == `i' & time == `t2'
		local ++j
		local ++k
		}
	}
gen clubturnover = 1 - clubjaccard
collapse clubturnover,by(egoid time)
replace clubturnover = 0 if time == 2
save "C:\Users\olizardo\Google Drive\cultural-matching-ego-networks\club-turnover.dta",replace
