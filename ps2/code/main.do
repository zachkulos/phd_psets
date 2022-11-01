********************************************************************************
* 
* Practicalities of Running RCTs - Assignment 2
* Zachary Kuloszewski and Jun Wong
*
* Due Nov 3, 2022
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

set graphics off
set scheme plotplainblind

global main "/Users/zachkuloszewski/Desktop/Classes/Second Year/Development/Q1/psets/ps2"

* import data from Bangladesh Paper
use "$main/data/main.dta", clear

*********************** Problem 1.2 - Randomization ****************************

set seed 10312022

* generate random uniform variable
gen rand = runiform()

gsort rand
gen rand_id = _n

* calculate number of misfits
local n_mf = mod(_N, 4)

* gen treatment variable (need to treat misfits)
gen treatment = .
forval i=1/4 {
	replace treatment = `i' if rand_id > (`i'-1)*0.25*_N & rand_id <= `i'*0.25*_N
}

* select misfit treatment
replace treatment = floor(runiform()*4) if _n > _N - `n_mf'


* randtreat package
// randtreat, gen(treatment2) multiple(4) misfits(global)

*********************** Problem 1.3 - Balance Table ****************************

* create ever married variable
gen ever_married = (inlist(marital_status, "Currently Married", "Divorced", ///
						   "Engaged to be married", "Separated", "Widowed"))
						   
* create still in school variable
gen in_school = (still_in_school == "Yes")		

* highest class passed variable
gen years_passed = 0			   
						  
eststo clear

local vars bl_age_reported in_school years_passed

gsort treatment
eststo: estpost tabstat `vars', by(treatment) s(mean sd n) listwise ///
	columns(statistics)

esttab est1 using $main/output/table1_means.tex, main(mean) aux(sd) unstack ///
	nomti nonum l replace
stop
* construct balance table
eststo clear 
eststo: estpost ttest `covars', by(T)
esttab using $main/output/table1_balance.tex, ///
	cells("mu_1(fmt(3)) mu_2(fmt(3)) b(fmt(3)) sd(fmt(3)) p(fmt(3)) ") ///
	nonum collab("No Project" "Eskom Project" "Difference" "p-Value") ///
	eqlabels(none) replace
