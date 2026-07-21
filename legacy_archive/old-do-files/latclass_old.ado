program define latclass
		version 9.1
			syntax varlist,numclass(integer)
			preserve
				gen dev=.
				gen pval=.
				gen bic=.
				gen df=.
				local i=1
				local l : list sizeof varlist
				keep `varlist'
				foreach y of varlist `varlist' {
					drop if `y'==.
					rename `y' y`i'
					local i=`i'+1
					}
				
				gen id=_n
				reshape long y,i(id) j(item)
				tab item,gen(d)
				forval i=1/`l' {
					eq d`i': d`i'
					local eqlist `eqlist' d`i'
					}
				gllamm y, ///
					i(id) nrf(`l') ///
					eqs(`eqlist') ///
					link(logit) fam(bin) ///
					ip(f) ///
					nip(`numclass') ///
					nocons
			restore
		end
		
			
