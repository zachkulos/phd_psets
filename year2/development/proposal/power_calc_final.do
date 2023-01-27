********************************************************************************
* 
* Practicalities of Running RCTs - Power Calc
* Zachary Kuloszewski
*
* Due Dec 8 2022
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

* general statistics
egen pop_mean = mean(got)

gen pop_var_binom = pop_mean * (1-pop_mean)

* decalre desired power level
local power = 0.8

forval i=100(50)4000 {
	gen MDE_n`i' = (1.96+0.845) * sqrt(1/(0.5*0.5)) * sqrt(pop_var_binom/`i')
}

collapse (lastnm) MDE* villnum

reshape long MDE_n, i(villnum) j(samplesize)

twoway line MDE_n samplesize, ytitle("MDE") xtitle("Sample Size") ///
	title("MDE vs. Sample Size for 80% Power") yline(0.05) 
	
graph export "$main/output/power_calc_final.png", replace
