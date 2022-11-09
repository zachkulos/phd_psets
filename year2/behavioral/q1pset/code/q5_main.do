********************************************************************************
* 
* Behavioral Economics - Development and Observational Data - Q5
* Zachary Kuloszewski and Joe Battles
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
// set more off

// set graphics off
set scheme plotplainblind

local name zach

if "`name'"=="zach" {
	global main "/Users/zachkuloszewski/Dropbox/My Mac (Zachs-MBP.lan)/Documents"
	global main $main/GitHub/phd_psets/year2/behavioral/q1pset
}

* import data from Ghana WTP paper
use "$main/data/WTP_waterfilter_data.dta", clear

*************************** question 5 part 3 **********************************

* distribution of BDM bids histogram
twoway hist bdm_filt_bid if BDM == 1
graph export "$main/output/BDM_bid_hist.pdf", replace

* distribution of BDM bids histogram
twoway hist tioli_filt_price if TIOLI== 1
graph export "$main/output/TIOLI_price_hist.pdf", replace

*************************** question 5 part 4 **********************************

** TIOLI demand 
preserve

* restrict to TIOLI observations
keep if TIOLI == 1

gcollapse (mean) tioli_filt_buy, by(tioli_filt_price)

label var tioli_filt_buy "Fraction Bought"

twoway line tioli_filt_buy tioli_filt_price, ///
	ylabel(, format(%5.1f)) title("TIOLI Inverse Demand Curve")
	
restore

** BDM demand 
// preserve

* restrict to BDM observations
keep if BDM == 1

gen BDM_bin = floor(bdm_filt_bid)
keep if BDM_bin <= 10

gcollapse (count) bdm_filt_bid, by(BDM_bin)

label var bdm_filt_bid "Quantity Bought"

twoway line bdm_filt_bid BDM_bin, ///
	ylabel(, format(%5.1f)) title("BDM Inverse Demand Curve")
	
// restore
