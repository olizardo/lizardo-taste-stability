gen race = .
replace race = 1 if eth == "White/Caucasian"
replace race = 2 if eth == "African American/Black"
replace race = 3 if eth == "Mexican American/Chicano" | eth == "Puerto Rican" | eth == "Other Latino" 
replace race = 4 if eth == "Asian American/Asian"
replace race = 5 if eth == "Other"
lab def race 1 White 2 Black 3 Hispanic 4 Asian 5 Other
lab val race race
