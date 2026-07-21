destring subjectivesimilar,replace ignore("NA")
destring duration,replace ignore("NA")
destring alterposition, replace ignore("NA")
encode closeness,g(close) label(closeness)
drop closeness
recode close 5 = . 1 = 3 2 = 1 4 = 2 3 = 4
lab def close 1 "Distant" 2 "Less than Close" 3 "Close" 4 "Especially Close"
lab val close close
gen nd_contact = notredame ==  "Are attending" | notredame == "Did attend" | ///
notredame == "Graduated last semester" | notredame == "Graduated this semester"
foreach x of varlist emotionloving emotionexciting emotionsignificant {
	encode `x',g(`x'2)
	drop `x'
	ren `x'2 `x'
	recode `x' 3 = . 1 = 0 2 = 1
	}
destring numberalter, replace ignore("NA")
cap drop _merge
ren gender alter_gender
