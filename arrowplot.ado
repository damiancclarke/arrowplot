*! arrowplot: Combined macro scatter and micro regression plot
*! Version 0.0.0 julio 23, 2014 @ 19:09:56
*! Author: Damian C. Clarke
*! Department of Economics
*! The University of Oxford
*! damian.clarke@economics.ox.ac.uk

cap program drop arrowplot
program arrowplot, eclass
	vers 11.0

	#delimit ;
	syntax varlist(min=2 max=2) [if] [in] [pweight fweight aweight iweight]
	, LINEsize(real) GROUPvar(varname)
	[
	  CONTrols(varlist)
	  GRAPHopts(passthru)
	]
	;
	#delimit cr

	*=============================================================================
	*=== (1) set-up temporary variables for line plots and beta estimates
	*=============================================================================
	tempvar intercept x1 x2 y1 y2 delta line
	tempvar my mx miny maxy minx maxx rany ranx scale reX
	qui gen `intercept'=.

	tokenize `varlist'

	*=============================================================================
	*=== (2) Rescale X so size of line will be equal regardless of slope
	*=============================================================================
	bys `groupvar': egen `my'=mean(`1')
	bys `groupvar': egen `mx'=mean(`2')
	foreach var in x y {
		egen `min`var''=min(`m`var'')
		egen `max`var''=max(`m`var'')
		gen `ran`var''=`min`var''-`max`var''
	}

	gen `scale'=`rany'/`ranx'
	gen `reX'  = `2'*`scale'
	
	*=============================================================================
	*=== (3) Calculate intra-correlation (conditional upon any controls)
	*=============================================================================
	levelsof `groupvar', local(levels)
	foreach c of local levels {
		cap reg `1' `reX' `controls' if `groupvar'==`"`c'"' `in' [`weight' `exp']
		if _rc==0 replace `intercept'=_b[`reX'] if `groupvar'==`"`c'"'
	}
	preserve	
	collapse `1' `2' `reX' `scale' `intercept', by(`groupvar')

	*=============================================================================
	*=== (4) Determine start and end point of lines (depends on slope and length)
	*=============================================================================
	gen  `delta'  = sqrt((`linesize'^2)/(`intercept'^2+1))
	gen  `x1'     = `reX'-`delta'
	gen  `x2'     = `reX'+`delta'
	gen  `y1'     = `1'-`delta'*`intercept'
	gen  `y2'     = `1'+`delta'*`intercept'
	
	gen `line'  = (`y2'-`y1')^2+(`x2'-`x1')^2

	replace `x1'=`x1'/`scale'
	replace `x2'=`x2'/`scale'
	
	*=============================================================================
	*=== (5) Plot
	*=============================================================================
	twoway pcarrow `y1' `x1' `y2' `x2' || scatter `1' `2', ///
	  mlabel(`groupvar') mlabsize(vsmall) scheme(s1color) 
	
	restore
end
