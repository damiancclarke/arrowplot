*! arrowplot: Combined macro scatter and micro regression plot
*! Version 0.0.0 julio 23, 2014 @ 00:36:42
*! Author: Damian C. Clarke
*! Department of Economics
*! The University of Oxford
*! damian.clarke@economics.ox.ac.uk

cap program drop arrowplot
program arrowplot, eclass
	vers 11.0

	#delimit ;
	syntax varlist(min=2 max=2) [if] [in] [pweight fweight aweight iweight]
	  ,
	  LINEsize(real)
	  GROUPvar(varname)
	  [
	  CONTrols(varlist)
	  GRAPHopts(passthru)
	  ]
	  ;
	#delimit cr

	tempvar intercept x1 x2 y1 y2 delta line
	gen `intercept'=.
	tokenize `varlist'
	
	levelsof `groupvar', local(levels)
	foreach c of local levels {
		cap reg `1' `2' `controls' if `groupvar'==`"`c'"' `in' [`weight' `exp']
		if _rc==0 replace `intercept'=_b[`2'] if `groupvar'==`"`c'"'
	}
	preserve
	collapse `1' `2' `intercept', by(`groupvar')

	gen  `delta'  = sqrt((`linesize'^2)/(`intercept'^2+1))
	gen  `x1'     = `2'-`delta'
	gen  `x2'     = `2'+`delta'
	gen  `y1'     = `1'-`delta'*`intercept'
	gen  `y2'     = `1'+`delta'*`intercept'
	
	gen `line'  = (`y2'-`y1')^2+(`x2'-`x1')^2

	
	list
	twoway pcarrow `y1' `x1' `y2' `x2' || scatter `1' `2', ///
	  mlabel(`groupvar') mlabsize(vsmall) scheme(s1color) 
	
	restore
end


