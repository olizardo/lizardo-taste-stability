use "N:\Private\SOCIOLOGY OF CULTURE\taste-change\PCS\pc1980-85-90.dta", clear
cd "N:\Private\SOCIOLOGY OF CULTURE\taste-change"

preserve 
	reshape long books,i(id) j(wave)
	drop if books==.
	tab books wave
	qui bysort wave:gen taste_change=abs(books[_n+1]-books[_n])
	recode taste_change 2=1 0/1=0
	tab taste_change
	sort id wave books taste_change,stable
	list id books taste_change wave in 1/20,clean
restore






