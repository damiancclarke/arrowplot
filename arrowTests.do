vers 11
clear all
set more off

set obs 10000
local gnm group1 group2 group3 group4 group5 group6 group7 group8 group9 group10
local return 2 2.5 3 3.5 3 0 -1 3 3 2.5

gen group=runiform()
gen groupName=""
tokenize `gnm'

foreach num of numlist 10(-1)1 {
	replace group=`num' if group<(1-((10-`num')/10))&group>=(1-((10-`num')/10)-0.1)
	replace groupName="`1'" if group==`num'
	macro shift
}

tokenize `return'
gen income=.
gen educ=group+rnormal()

foreach num of numlist 1(1)10 {
	replace income=``num'' * educ + rnormal() if group==`num'
}

arrowplot income educ, line(3) groupvar(groupName)
