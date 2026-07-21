prog def chng_logit
syntax namelist 
tokenize namelist
est drop _all
local i=1
foreach var in `namelist' {
		preserve 
		reshape long `var',i(id) j(wave)
		drop if `var'==.
		keep `var'* marital* childre* wrkstat* friends* chorgs* provinc* categor*	educ* wave id age*
		gen taste_change1=0
		gen taste_change2=0
		qui bysort id:replace taste_change1=1 if abs(`var'[_n]-	`var'[_n-1])>1 & _n>1
		qui bysort id:replace taste_change2=1 if abs(`var'[_n]-`var'[_n-1])>1 & _n>0
		*recode taste_change 2=1 0/1=0
		sum taste_change*
		*sort id wave `var' taste_change*,stable
		*list id wave `var' taste_change1 taste_change2  in 	1/25,clean
		foreach name in marital childre wrkstat friends educ provinc categor {
				gen chng_`name'=0
				qui bysort id:replace chng_`name'=1 if 	`name'3~=`name'2 & wave==3 & (`name'2~=.&`name'3~=.)
				qui bysort id:replace chng_`name'=1 if `name'4~=`name'3 & wave==4 & (`name'3~=.&`name'4~=.)
				}
				*sort id wave marital* chng_marital*,stable
				*list id wave wrkstat2 wrkstat3 wrkstat4 chng_wrkstat 	in 1/45,clean
				gen chng_orgs=0
				replace chng_orgs=1 if chorgs3~=3 & wave==3
				replace chng_orgs=1 if chorgs4~=3 & wave==4
				gen age_wave=.
				gen counter=1
				bysort id:egen num_waves=sum(counter)
				forval i=2/4 {
					replace age_wave=age`i' if age_wave==.
					}
			recode age_wave 0=. 15/29=1 30/39=2 40/49=3 50/64=4 64/100=5,g(age_cat)
			gen chng_age=0
			replace chng_age=5 if wave==3
			replace chng_age=10 if wave==4
			gen chng_agesq=chng_age^2
			xi:xtlogit taste_change1 i.chng_marital i.chng_childre i.chng_friends i.chng_orgs i.chng_categor i.chng_wrkstat i.chng_edu if num_waves>=2,re i(id)
			est store mod`i'
			esttab mod`i',star(* 0.10)
			restore
			}		
end
