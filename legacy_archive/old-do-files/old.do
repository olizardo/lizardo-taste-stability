cap drop taste
foreach varname in music books paper  sports {
	gen strtasteloss`varname'52=`varname'3==1&`varname'4==5
	gen wktasteloss`varname'52=`varname'3==1&(`varname'4==5|`varname'4==3)
	gen strtasteloss`varname'51=`varname'2==1&`varname'3==4
	gen wktasteloss`varname'51=`varname'2==1&(`varname'4==3|`varname'4==4)
	gen strtasteloss`varname'10=`varname'2==1&`varname'4==5
	gen wktasteloss`varname'10=`varname'2==1&(`varname'4==5|`varname'4==3)
	}

preserve 
	contract friends3 friends4,zero nomiss
	flist _freq,clean table
	tabstat _freq,by(_freq)
restore


ren friends3 evefrnd3
gen friends3=.
local i=1
foreach num of numlist -1.1046  -0.0832   1.1878 {
	replace friends3=`num' if evefrnd3==`i'
	local i=`i'+1
	}
ren friends4 evefrnd4
gen friends4=.
local i=1
foreach num of numlist  -0.5484  -0.4217  -0.0140   0.3560   0.6281 {
	replace friends4=`num' if evefrnd4==`i'
	local i=`i'+1
	}
for var friends3 friends4:replace X=X-1