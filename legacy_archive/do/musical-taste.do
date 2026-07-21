clear
insheet using "C:\Users\olizardo\Google Drive\NetSense\WORK\Matt Work\demsurveyMergedCoded.csv"
gen counter = 1
drop if egoid == .
qui bysort egoid : gen dups = sum(counter)
drop if dups > 1

keep egoid musicpref*
local i 1
foreach name in Big_Band Bluegrass Blues Musicals Glee Classic_Rock Classical Country Dance Ethnic Folk ///
Gospel Jazz Latin Easy New_Age Opera Operetta Band Rap Reggae Rock {
	forval j = 1 / 6 {
		ren musicpref`i'_`j' `name'_`j'
		local ++j
		}
	local ++i
	}
	
reshape long Big_Band_ Bluegrass_ Blues_ Musicals_ Glee_ Classic_Rock_ Classical_ ///
Country_ Dance_ Ethnic_ Folk_ Gospel_ Jazz_ Latin_ Easy_ New_Age_ Opera_ ///
Operetta_ Band_ Rap_ Reggae_ Rock_ ,i(egoid) j(time)
drop musicprefother_*

lab def yesno 0 No 1 Yes
foreach name in Big_Band Bluegrass Blues Musicals Glee Classic_Rock Classical Country Dance Ethnic Folk ///
Gospel Jazz Latin Easy New_Age Opera Operetta Band Rap Reggae Rock {
	encode `name'_,g(`name')
	drop `name'_
	recode `name' 1 = 0 2 = 1
	lab val `name' yesno
	drop if `name' == .
	}
gen musictastechange = 0 
gen musictastegain = 0
gen musictasteloss = 0
foreach name in Big_Band Bluegrass Blues Musicals Glee Classic_Rock Classical Country Dance Ethnic Folk ///
Gospel Jazz Latin Easy New_Age Opera Operetta Band Rap Reggae Rock {
	qui bysort egoid : replace musictastechange = musictastechange + 1 if `name'[_n] != `name'[_n - 1] & time != 1
	qui bysort egoid : replace musictastegain = musictastegain + 1 if `name'[_n] == 1 & `name'[_n - 1] == 0 & time != 1
	qui bysort egoid : replace musictasteloss = musictasteloss + 1 if `name'[_n] == 0 &`name'[_n - 1] == 1 & time != 1
	}
	
keep egoid time musictaste*
save "C:\Users\olizardo\Google Drive\cultural-matching-ego-networks\music-taste.dta",replace
