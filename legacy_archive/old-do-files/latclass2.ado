program define latclass2
		version 9.1
			syntax varlist,numclass(integer)
			*preserve
				gen dev=.
				gen pval=.
				gen bic=.
				gen df=.				
				local l : list sizeof varlist
				keep `varlist'
				local i=1
				foreach y of varlist `varlist' {
					drop if `y'==.
					rename `y' y`i'
					local i=`i'+1
					}
				contract y*,nomiss 
				gen patt=_n
				gen wt2=_freq
				reshape long y,i(patt) j(item)
				tab item,gen(d)
				forval i=1/`l' {
					eq d`i': d`i'
					local eqlist `eqlist' d`i'
					}
				gllamm y, i(patt) nrf(`l') eqs(`eqlist') weight(wt) fam(binom)link(logit) ip(fn) nip(`numclass') nocons
			*restore
		end
		
			
