clear
insheet using "C:\Users\olizardo\Google Drive\NetSense\WORK\Matt Work\demsurveyMergedCoded.csv"
gen counter = 1
drop if egoid == .
qui bysort egoid : gen dups = sum(counter)
drop if dups > 1

local i 1
keep egoid culturalevents*
foreach name in JazzPerf LatinPerf Symphony OperaPerf MusicalPerf Theater Ballet ///
OutDoor ArtMuseum ScienceMuseum OtherMuse ArtFestival {
	forval j = 1 / 4 {
		ren culturalevents`i'_`j' `name'_`j'
		local ++j
		}
	local ++i
	}
reshape long JazzPerf_ LatinPerf_ Symphony_ OperaPerf_ MusicalPerf_ Theater_ Ballet_ ///
OutDoor_ ArtMuseum_ ScienceMuseum_ OtherMuse_ ArtFestival_,i(egoid) j(time)

lab def yesno 0 No 1 Yes
foreach name in JazzPerf LatinPerf Symphony OperaPerf MusicalPerf Theater Ballet ///
OutDoor ArtMuseum ScienceMuseum OtherMuse ArtFestival {
	encode `name'_,g(`name')
	drop `name'_
	recode `name' 1 = 0 2 = 1
	lab val `name' yesno
	drop if `name' == .
	}
gen culttastechange = 0 
gen culttastegain = 0
gen culttasteloss = 0
foreach name in JazzPerf LatinPerf Symphony OperaPerf MusicalPerf Theater Ballet ///
OutDoor ArtMuseum ScienceMuseum OtherMuse ArtFestival {
	qui bysort egoid : replace culttastechange = culttastechange + 1 if `name'[_n] != `name'[_n - 1] & time != 1
	qui bysort egoid : replace culttastegain = culttastegain + 1 if `name'[_n] == 1 & `name'[_n - 1] == 0 & time != 1
	qui bysort egoid : replace culttasteloss = culttasteloss + 1 if `name'[_n] == 0 &`name'[_n - 1] == 1 & time != 1
	}
	
keep egoid time culttaste*
save "C:\Users\olizardo\Google Drive\cultural-matching-ego-networks\cult-taste.dta",replace
