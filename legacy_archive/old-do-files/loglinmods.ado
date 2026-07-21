program define loglinmods
		version 9.1
			syntax varlist (max=4),
			preserve
			gettoken c1 varlist:varlist
			gettoken c2 varlist:varlist
			gettoken n1 varlist:varlist
			gettoken n2 varlist:varlist
			quietly {
				contract `c1' `c2' `n1' `n2',zero nomiss
				egen total=sum(_freq)
				sum total,meanonly
				local N=r(mean)
				gen dev=.
				gen pval=.
				gen bic=.
				gen df=.
				}
			
			*/specifying log-linear models*/
			local mod1 i.`c1' i.`c2' i.`n1' i.`n2' 
			local mod2 i.`c1' i.`c2' i.`n1' i.`n2' i.`c1'*i.`n1' i.`c2'*`n2' i.`n1'*i.`n2' i.`n1'*i.`c2'
			local mod3 i.`c1' i.`c2' i.`n1' i.`n2' i.`c1'*i.`n1' i.`c2'*`n2' i.`c1'*i.`c2'			
			*/estimating log-linear models*/
			forval i=1/3 {
				quietly {
					xi:glm _freq `mod`i'',f(p)
					replace dev=e(deviance) in `i'
					replace pval=chi2tail(e(k),e(deviance)) in `i'
					replace bic=e(deviance)-(e(df)*log(`N')) in `i'
					replace df=e(df) in `i'
					}
				}
			format pval bic dev %9.4f
			list dev pval bic df in 1/3,clean 
			restore
		end
		
					
				
			
			
			
