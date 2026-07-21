clear
insheet using "C:\Users\olizardo\Google Drive\cultural-matching-ego-networks\netsurveysMergedWideCodedFD.csv" 

keep ego* alterid numberalter_*
reshape long numberalter_,i(egoalterid) j(time)
drop if number == "NA"

cap gen jaccard = . 
qui levelsof egoid,l(egos)
foreach i of local egos {
	levelsof time if egoid == `i',l(waves)
	local nwaves : list sizeof local(waves)
	local j 1
	local k 2
	while `k' <= `nwaves' {
		local t1 : word `j' of `waves'
		local t2 : word `k' of `waves'
		levelsof alterid if egoid == `i' & time == `t1',l(alters1)
		levelsof alterid if egoid == `i' & time == `t2',l(alters2)
		local inter : list alters1 & alters2
		local union : list alters1 | alters2
		local s1 : list sizeof local(inter)
		local s2 : list sizeof local(union)
		replace jaccard = `s1' / `s2' if egoid == `i' & time == `t2'
		local ++j
		local ++k
		}
	}
destring numberal,ignore(NA) replace
collapse jaccard numberal,by(egoid time)
gen turnover = 1 - jaccard
save "C:\Users\olizardo\Google Drive\cultural-matching-ego-networks\egonet-turnover.dta",replace



