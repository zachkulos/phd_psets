********************************************************************************
* 
* Practicalities of Running RCTs - Assignment 2
* Zachary Kuloszewski and Jun Wong
*
* Due Nov 17, 2022
*
********************************************************************************

** set options **
version 16
set type double 
capture restore
capture log close
macro drop all

clear all
cls
set more off

// set graphics off
set scheme plotplainblind

local name jun
if "`name'"=="zach" {
	global main "/Users/zachkuloszewski/Dropbox/My Mac (Zachs-MBP.lan)/Documents"
	global main $main/GitHub/phd_psets/year2/development/ps3
}
if "`name'"=="jun" {
	global main "/Users/junwong/Dropbox/Second Year/Glennerster - RCT/Assignments"
}

*********************** Problem 1.1 - Data Simulation **************************

local N = 200

set seed     20221115
set sortseed 20221115

program reg_sim, eclass 
	args n_obs clust_flag 
	drop _all 
	local n_obs 100
	set obs `n_obs'
	gen id = _n 
	gen alpha = 70
	gen beta  = 2.5
	gen eps   = rnormal(0,10)
	
	*randomization
	gen rand = runiform()
	gsort rand
	gen rand_id = _n
	
	if `clust_flag' == 0 {
		gen treat = (rand_id > 0.5*_N)
	} 
	else if `clust_flag' == 1 {
		egen cohort = cut(rand), group(4) 
		drop rand 
		gen rand = . 
		bys cohort: replace rand = cond(_n==1, runiform(), rand[1])
		gsort rand 
		gen treat = (_n <= _N / 2)
	}
	
	gen yi = alpha + beta*treat + eps
	
	label var treat "Treatment"
	label var yi "Test Score"
	
	eststo clear
	
	if `clust_flag' == 0 {
		eststo: reg yi treat
	}
	else if `clust_flag' == 1 {
		eststo: reg yi treat, vce(cluster cohort)
	}
end



*********************** Problem 1.2 - Data Simulation **************************

eststo clear

simulate _b _se, reps(1): reg_sim `N' 0

esttab using "$main/output/q1_2.tex", replace nonum se lab ///
	star(* 0.10 ** 0.05 *** 0.01)
	
*********************** Problem 1.3 - More Simulation **************************

clear 
simulate _b _se, reps(100): reg_sim `N' 0

gen tstat  = _b_treat / _se_treat
gen reject = ((tstat >= 1.96) | (tstat <= -1.96))

*********************** Problem 1.4 - Varying Sample Size **********************

tempname memhold
tempfile results

postfile `memhold' sample_size reject_rate using `results', replace

forval i=50(50)600 {
	
	clear 
	simulate _b _se, reps(100): reg_sim `i' 0

	gen tstat  = _b_treat / _se_treat
	gen reject = ((tstat >= 1.96) | (tstat <= -1.96))
	
	qui sum reject 
	post `memhold' (`i') (`r(mean)')
	
}
postclose `memhold'
use `results', clear

twoway line reject_rate sample_size, ytitle("Power (Rejection Rate)") ///
	xtitle("Sample Size") yline(0.8)
	
graph export "$main/output/q1_4.png", replace

*********************** Problem 1.5 - Clustering *******************************

clear 
simulate _b _se, reps(100): reg_sim 200 1

gen tstat  = _b_treat / _se_treat
gen reject = ((tstat >= 1.96) | (tstat <= -1.96))

