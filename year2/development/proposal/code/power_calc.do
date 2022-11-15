********************************************************************************
* 
* Practicalities of Running RCTs - Presentation Power Calc
* Zachary Kuloszewski
*
* Due Nov 15, 2022
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

global main "/Users/zachkuloszewski/Dropbox/My Mac (Zachs-MBP.lan)/Documents"
global main $main/GitHub/phd_psets/year2/development/proposal


* import data from Thornton 2008
use "$main/thorntondata/Thornton-HIV-Testing-Data.dta", clear

gen MainSample = 1 if test2004==1 & age!=. & villnum!=. & tinc!=. & distvct!=. & hiv2004!=-1 & followup_test!=1
keep if MainSample == 1
// replace got = 0 if missing(got)

// gen vct_2km   = (distvct <= 2)
// gen vct_2_4km = (distvct >  2) & (distvct <= 4)
// gen vct_4p_km = (distvct >  4)

// reg got i.male vct_2km vct_2_4km vct_4p_km
// predict residual

// gsort villnum male
// by villnum male: egen clust_var_resid = sd(residual)
// replace clust_var_resid = clust_var_resid ^ 2

gsort villnum male
by villnum: egen clust_mean = mean(got)
by villnum: gen  clust_size = _N

* create within cluster variance p(1-p)
by villnum: gen within_clust_var = clust_mean * (1-clust_mean)

* general statistics
egen pop_mean = mean(got)

// egen pop_var  = sd(residual)
// replace pop_var = pop_var^2 //pop_mean * (1-pop_mean)

gen pop_var_binom = pop_mean * (1-pop_mean)

egen avg_n	  = mean(clust_size)
egen pop_size = count(MainSample)

gcollapse (lastnm) clust_mean within_clust_var pop* avg_n, by(villnum) 

* create between cluster variance
egen bw_clust_var = sd(clust_mean)
replace bw_clust_var = bw_clust_var * bw_clust_var 

egen avg_within_clust_var = mean(within_clust_var)

* icc! yeet
gen icc = bw_clust_var / (avg_within_clust_var + bw_clust_var)

* decalre desired power level
local power = 0.8

forval i=100(50)4000 {
	gen MDE_n`i' = sqrt(1+icc*(avg_n-1)) * (1.96+0.845) * sqrt(1/(0.5*0.5)) * sqrt(pop_var_binom/`i')
}

collapse (lastnm) MDE* icc villnum

reshape long MDE_n, i(villnum) j(samplesize)

twoway line MDE_n samplesize, ytitle("MDE") xtitle("Sample Size") ///
	title("MDE vs. Sample Size for 80% Power")
	
graph export "$main/output/power_calc.png", replace
