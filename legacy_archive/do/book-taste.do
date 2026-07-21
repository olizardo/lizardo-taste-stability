clear
insheet using "C:\Users\olizardo\Google Drive\NetSense\WORK\Matt Work\demsurveyMergedCoded.csv"
gen counter = 1
drop if egoid == .
qui bysort egoid : gen dups = sum(counter)
drop if dups > 1

local i 1
keep egoid typebook*
foreach name in Mysteries Thriller Romance SciFi Fiction SelfHelp History Bios NonFiction  {
	forval j = 1 / 6 {
		ren typebookread`i'_`j' `name'_`j'
		local ++j
		}
	local ++i
	}
reshape long Mysteries_ Thriller_ Romance_ SciFi_ Fiction_ SelfHelp_ History_ Bios_ NonFiction_,i(egoid) j(time)
drop typebookreadother*
lab def yesno 0 No 1 Yes
foreach name in Mysteries Thriller Romance SciFi Fiction SelfHelp History Bios NonFiction  {
	encode `name'_,g(`name')
	drop `name'_
	recode `name' 1 = 0 2 = 1
	lab val `name' yesno
	drop if `name' == .
	}
gen booktastechange = 0 
gen booktastegain = 0
gen booktasteloss = 0
foreach name in Mysteries Thriller Romance SciFi Fiction SelfHelp History Bios NonFiction  {
	qui bysort egoid : replace booktastechange = booktastechange + 1 if `name'[_n] != `name'[_n - 1] & time != 1
	qui bysort egoid : replace booktastegain = booktastegain + 1 if `name'[_n] == 1 & `name'[_n - 1] == 0 & time != 1
	qui bysort egoid : replace booktasteloss = booktasteloss + 1 if `name'[_n] == 0 &`name'[_n - 1] == 1 & time != 1
	}
	
keep egoid time booktaste*
save "C:\Users\olizardo\Google Drive\cultural-matching-ego-networks\book-taste.dta",replace
