clear
insheet using "C:\Users\olizardo\Google Drive\NetSense\DATA\Annon Data_\demsurveyMergedCodedDisID.csv"
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
save "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\tasteperson.dta",replace

/*getting demographic variables*/
clear
insheet using "C:\Users\olizardo\Google Drive\NetSense\DATA\Annon Data_\demsurveyMergedCodedDisID.csv"
keep egoid gender_1 ethnicity_1 momed_1 daded_1
foreach name in gender ethnicity momed daded {
	ren `name'_1 `name'
	}
save "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\egovars.dta",replace

/*getting alter taste data*/
clear
insheet using "C:\Users\olizardo\Google Drive\NetSense\DATA\Annon Data_\netsurveysMergedWideCodedDupFree.csv" 
keep egoid alterid alter*_* sameactivities*
lab def freq 1 "Not at all" 2 "Not that much" 3 "Somewhat" 4 "Very much" 99 "Don't know"
foreach name in music movies books sports games outdoor {
	forval i = 1 / 6 {
		encode alter`name'_`i',g(friend`name'_`i')
		drop alter`name'_`i'
		recode friend`name'_`i' 2 = . 1 = 99 3 = 1 4 = 2 5 = 3 6 = 4 
		lab val friend`name'_`i' freq
		}
	}
lab def match 0 "No Match" 1 "Match" 
forval i =  1 / 6 {
	forval j = 1 / 5 {
		encode sameactivitiesact0`j'_`i',g(act_match`j'_`i')
		recode act_match`j'_`i' 1 = 0 2 = 1 3 = .
		lab val act_match`j'_`i' match
		}
	}
drop sameact*
forval i = 1 / 6 {
	egen num_match_`i' = rowtotal(act_match1_`i' - act_match5_`i'), missing
	}
drop act_match*
foreach t of numlist 1 2 4 5 {
	gen decay_`t' = 0
	}
replace decay_1 = 1 if friendmusic_1 != . & friendmusic_2 == .
replace decay_2 = 1 if friendmusic_2 != . & friendmusic_4 == .
replace decay_4 = 1 if friendmusic_4 != . & friendmusic_5 == .
replace decay_5 = 1 if friendmusic_5 != . & friendmusic_6 == .
sort egoid alterid,stable
egen egoalterid = group(egoid alterid)
reshape long decay_ num_match_ friendbooks_ friendgames_ friendmovies_ friendmusic_ friendoutdoor_ friendsports_ ///
,i(egoalterid) j(time)
foreach name in decay num_match friendbooks friendgames friendmovies friendmusic friendoutdoor friendsports {
	ren `name'_ `name'
	}
drop if decay == .
joinby egoid time using "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\tasteperson.dta",unmatched(using)
egen miss = rowmiss(friend*)
drop if miss == 6
foreach x of varlist music - outdoor {
	ren `x' ego`x'
	}
foreach name in music movies books sports games outdoor {
	gen `name'_ex_match = friend`name' == ego`name'
	gen `name'_str_match = friend`name' == 4 & ego`name' == 4
	gen `name'_wk_match = friend`name' == 3 & ego`name' == 3
	gen `name'_neg_match = (friend`name' == 1 | friend`name' == 2) & (ego`name' == 1 | ego`name' == 2)
	gen `name'_dk = friend`name' == 99
	}
egen numdk = rowtotal(*dk)
ren num_match nmatch_open
egen nmatch_close = rowtotal(*_ex_match)
egen nmatch_pos = rowtotal(*_str_match)
egen nmatch_neg = rowtotal(*_neg_match)
egen nmatch_weak = rowtotal(*_wk_match)
save "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\tastesnet.dta", replace

/*getting name interpreter data*/
clear
insheet using "C:\Users\olizardo\Google Drive\NetSense\DATA\Annon Data_\netsurveysMergedWideCodedDupFree.csv" 
keep egoid alterid numberalter_* gender_* notredame_* reltype_* notredame_* closeness_* duration_* emotion* alterposition*
sort egoid alterid,stable
egen egoalterid = group( egoid alterid)
reshape long numberalter_ gender_  reltype_  notredame_  closeness_ alterposition_ ///
duration_ emotionloving_ emotionexciting_ emotionsignificant_ subjectivesimilar_,i(egoalterid) j(time)
foreach name in numberalter gender  reltype  notredame  closeness alterposition ///
duration emotionloving emotionexciting emotionsignificant subjectivesimilar {
	ren `name'_ `name'
	}
save "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\rel-vars.dta", replace
use "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\tastesnet.dta",clear
drop _merge
joinby egoalterid time using "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\rel-vars.dta",unmatched(using)
do "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\netvars-cleanup.do"
joinby egoid using "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\egovars.dta",unmatched(master)
ren gender ego_gender
gen alter_woman = alter_gender == "Female"
gen ego_woman = ego_gender == "Female" if ego_gender != ""
lab def gend 1 "Women" 0 "Men"
lab val ego_woman gend
lab val alter_woman gend
gen macoll = momed == "College Degree" | momed == "Graduate degree" | momed == "Some graduate school"
gen pacoll = daded == "College Degree" | daded == "Graduate degree" | daded == "Some graduate school"
egen parcoll = rowtotal(macoll pacoll)
drop if miss == .
gen friend = reltype == "Friend"
gen kin = reltype == "Sibling" | reltype == "Parent" | reltype == "Other family"
encode reltype,g(rel)
recode rel 1 = 2 4 = 2 5 = 2
encode ethnicity,g(race)
gen eth_black = race == 1
gen eth_white = race == 8
gen eth_asian = race == 3
gen eth_hisp = race == 4 | race == 6 | race == 7 
egen zablocki_scale = rowtotal(emotion*)
drop alterposition_*
save "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\tastesnet.dta", replace

/*
use "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\rel-vars.dta", clear
do "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\netvars-cleanup.do"
gen friend = reltype == "Friend"
gen kin = reltype == "Sibling" | reltype == "Parent" | reltype == "Other family"
gen weaktie = reltype == "Acquaintance"
tab close,g(closeness)
collapse ///
(mean) numbera duration  ///
(sum) closeness* weaktie friend kin ///
emotionloving emotionexciting emotionsignificant nd_contact, ///
by(egoid time)
joinby egoid time using "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\tasteperson.dta", ///
unmatched(master)
drop _merge
foreach name in music movies books sports games outdoor {
	gen `name'_str_pref = `name' == 4 
	gen `name'_wk_pref =  `name' == 3 
	gen `name'_neg_pref = `name' == 1 | `name' == 2
	}

egen npref_strong = rowtotal(*_str_pref)
egen npref_weak = rowtotal(*_wk_pref)
egen npref_neg = rowtotal(*_neg_pref)
save "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\cult-conv.dta",replace


save "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\cult-conv.dta",replace
