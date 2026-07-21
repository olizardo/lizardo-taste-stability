clear
insheet using "C:\Users\olizardo\Google Drive\NetSense\WORK\Matt Work\demsurveyMergedCoded.csv"
gen counter = 1
drop if egoid == .
qui bysort egoid : gen dups = sum(counter)
drop if dups > 1

keep egoid interestitems*_*
local names music movies books sports games outdoor
forval i = 1 / 6 {
	forval j = 1 / 6 {
		local name : word `i' of `names'
		ren interestitems`i'_`j' `name'_`j'
		}
	}	
for var music_6 - outdoor_1 : replace X = "Not at all" if X == "Not Sure"
replace music_4 = "Somewhat" if music_4 == "Not at all"
replace music_4 = "Very much" if music_4 == "Not that much"

replace music_6 = "Very much" if music_6 == "Somewhat"
replace music_6 = "Somewhat" if music_6 == "Not that much"
replace music_6 = "Not that much" if music_6 == "Not at all"

replace sports_5 = "Not at all" if sports_5 == "Not that much"
replace sports_5 = "Not that much" if sports_5 == "Somewhat"
replace sports_5 = "Somewhat" if sports_5 == "Very much"
replace sports_5 = "Very much" if sports_5 == "5"

replace books_5 = "Not at all" if books_5 == "Not that much"
replace books_5 = "Not that much" if books_5 == "Somewhat"
replace books_5 = "Somewhat" if books_5 == "Very much"
replace books_5 = "Very much" if books_5 == "5"

replace games_4 = "Very much" if games_4 == "Somewhat"
replace games_4 = "Somewhat" if games_4 == "Not that much"
replace games_4 = "Not that much" if games_4 == "Not at all"

replace games_6 = "Very much" if games_6 == "Somewhat"
replace games_6 = "Somewhat" if games_6 == "Not that much"
replace games_6 = "Not that much" if games_6 == "Not at all"

replace outdoor_5 = "Not at all" if outdoor_5 == "Not that much"
replace outdoor_5 = "Not that much" if outdoor_5 == "Somewhat"
replace outdoor_5 = "Somewhat" if outdoor_5 == "Very much"
replace outdoor_5 = "Very much" if outdoor_5 == "5"

replace outdoor_6 = "Very much" if outdoor_6 == "Somewhat"
replace outdoor_6 = "Somewhat" if outdoor_6 == "Not that much"
replace outdoor_6 = "Not that much" if outdoor_6 == "Not at all"

lab define cult 1 "Not at all" 2 "Not that much" 3 "Somewhat" 4 "Very much"
foreach x of varlist music_6 - outdoor_1 {
	encode `x',g(`x'_enc) label(cult)
	drop `x'
	ren `x'_enc `x'
	}

reshape long music_ movies_ books_ sports_ games_ outdoor_,i(egoid)  j(time) 
foreach name in music movies books sports games outdoor {
	ren `name'_ `name'
	}
egen missed = rowmiss(music - outdoor)
drop if missed == 6

lab def yesno 0 No 1 Yes
foreach name in music movie books sports games outdoor  {
	recode `name' 1/3 = 0 4 = 1
	lab val `name' yesno
	}
gen activtastechange = 0 
gen activtastegain = 0
gen activtasteloss = 0
foreach name in music movie books sports games outdoor  {
	qui bysort egoid : replace activtastechange = activtastechange + 1 if `name'[_n] != `name'[_n - 1] & time != 1
	qui bysort egoid : replace activtastegain = activtastegain + 1 if `name'[_n] == 1 & `name'[_n - 1] == 0 & time != 1
	qui bysort egoid : replace activtasteloss = activtasteloss + 1 if `name'[_n] == 0 &`name'[_n - 1] == 1 & time != 1
	}
save "C:\Users\olizardo\Google Drive\cultural-matching-ego-networks\activ-taste.dta",replace
