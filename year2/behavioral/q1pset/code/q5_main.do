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
graph export "$main/output/BDM_bid_hist.png", replace

* create density of prices offered in TIOLI
gsort tioli_filt_price
by tioli_filt_price: egen tioli_price_dens = count(tioli_filt_price)

qui count if TIOLI == 1
replace tioli_price_dens = tioli_price_dens/r(N) if TIOLI == 1

* distribution of TIOLI price histogram
preserve
gcollapse (lastnm) tioli_price_dens, by(tioli_filt_price)

twoway bar tioli_price_dens tioli_filt_price, ytitle("Fraction Offered")
graph export "$main/output/TIOLI_price_hist.png", replace

restore

*************************** question 5 part 4 **********************************

** TIOLI demand 
preserve

* restrict to TIOLI observations
keep if TIOLI == 1

gcollapse (mean) tioli_filt_buy, by(tioli_filt_price)

label var tioli_filt_buy "Fraction Bought"

twoway line tioli_filt_buy tioli_filt_price, ///
	ylabel(, format(%5.1f)) title("TIOLI Inverse Demand Curve")
	
graph export "$main/output/TIOLI_invD.png", replace
	
restore

** BDM demand 
preserve

* restrict to BDM observations
keep if BDM == 1

forval i=1(1)10 {
	gen BDM_wtp_geq_`i' = (bdm_filt_bid >= `i')
}

gen id = 1

collapse (mean) BDM_wtp_geq* id

reshape long BDM_wtp_geq_, i(id) j(price)
label var BDM_wtp_geq_ "Fraction w/ WTP > p"
label var price "Price"

twoway line BDM_wtp_geq_ price
graph export "$main/output/BDM_invD.png", replace

restore 
