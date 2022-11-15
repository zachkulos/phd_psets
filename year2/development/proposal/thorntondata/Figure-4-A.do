*************** 
*This uses a fan locally weighted nonparametric regression with a global range of 0 to 4  
*calculated with 50 gridpoints. This code is adopted from code provided by Edward Miguel.
*************** 

clear
set mem 500m
graph drop _all
*clear all
set more off

use nonparametricvct.dta, clear


*keep if tinc!=0
*keep if any==0
save test,replace

use test, clear 
gen replic = 0	
gen ESTFCT= .	
gen xgrid = .	
gen ESTDER= .
keep in 1/1	
drop got distvct	
save lw_boot, replace	

* Fan Locally-weighted nonparametric regression, quartic kernel */
* Refer to URL: www.worldbank.org/LSMS/tools/deaton, or the Deaton book */
* fan_reg performs the locally-weighted nonparametric regression:
*argument 1 is the dependent variable   (input)
*argument 2 is the explanatory variable (input)
*argument 3 is the estimated regression function (output)
*argument 4 is the derivative of the regression function (output)
*argument 5 is the bandwidth (input)
*argument 6 is the grid over the explanatory variable for evaluation */

cap program drop fan_reg	
program def fan_reg	
	* ic is the loop counter 
	local ic = 1	
	* Generate the estimated function (3) and its derivative (4) */
	gen `3' = .	
	gen `4' = .	
	* Loop until reaching the last cell of the grid */
	while `ic' <= $gsize {	
	* Display the counter 
	dis `ic'	
	quietly {	
	* Get the ic entry in the grid *
	local xx = `6'[`ic']	
	* Absolute value of x - x(i), divided by the bandwidth 
	gen z = abs((`2' - `xx')/`5')	
	* Observation i gets the following quartic kernel weight 
	gen kz = (15/16)*(1 - z^2)^2 if z<=1	
	* Perform the regression weighted by the kernel (analogous to GLS) 
	reg  `1' `2' [aw=kz] if kz~=.	,robust cluster(villnum)
	* The estimated regression is the value at x 
	replace `3' = _b[_cons]+_b[`2']*`xx' in `ic' 	
	* The estimated slope is the coefficient estimate at x 
	replace `4' = _b[`2'] in `ic'	
	drop z kz	
	}	
	local ic = `ic' + 1	
	}	
end	

* Range of dependent variable 
global xmin = 0	
global xmax =  4
* Number of points at which to calculate, 50 to 100 are typically fine 
global gsize = 50
* Size of each step 
global st = ($xmax - $xmin)/($gsize-1)	
* Bandwidth 
global h = 1.2

/*  This program bootstraps the locally weighted regression, without clustering */ 
cap program drop fan_btsT	
program def fan_btsT	
local jc = 1	
while `jc' <= 50{	
display `jc'	
drop _all	
use test,clear
bsample _N
* This takes a sample of size _N (sample size), with replacement qui gen xgrid = $xmin + (_n-1)*$st in 1/$gsize	
qui fan_reg got distvct ESTFCT ESTDER  $h xgrid
drop got distvct  
* Only keep the regression results 
keep in 1/$gsize	
gen replic = `jc'	
* "Stack" simulated regression results 
append using lw_boot	
save lw_boot, replace	
local jc = `jc' + 1	
}	
end	

* Perform the bootstrap 
fan_btsT

* Recover the standard errors 
use lw_boot,clear	
* Drop the "useless" initial values 
drop if replic == 0	
/* Compute the variation at each grid point */  
egen sdESTFCT = sd(ESTFCT), by(xgrid)
egen sdESTDER = sd(ESTDER), by(xgrid) 
/* Only keep the standard errors */  
sort xgrid 
/* Only keep the first observation at each grid point */  
quietly by xgrid: drop if _n ~= 1
keep xgrid sdESTFCT sdESTDER
sort xgrid
save lw_boot,replace
clear 

/* Perform the Fan regression */ 
use test
gen xgrid = $xmin + (_n-1)*$st in 1/$gsize 
fan_reg  got distvct  ESTFCT ESTDER $h xgrid 
keep EST* xgrid 
sort xgrid 
/* Keep only the regression output */ 
keep in 1/$gsize 

/* Merge the bootstrap standard error results */ 
merge xgrid using lw_boot
tab _me
drop _me
save lw_boot, replace 

/* Compute 95 percent confidence bands */ 
/* Regression */ 
use lw_boot, clear 
gen ESTFCT_u = ESTFCT + 2*sdESTFCT 
gen ESTFCT_l = ESTFCT - 2*sdESTFCT 
/* Derivative */ 
gen ESTDER_u = ESTDER + 2*sdESTDER 
gen ESTDER_l = ESTDER - 2*sdESTDER 
sort xgrid  

/* the function and bounds */ 
label var ESTFCT "Fan Regression" 
label var ESTFCT_l "95% lower band" 
label var ESTFCT_u "95% upper band" 

/* the derivate and bounds */ 
label var ESTDER "Fan regression derivative" 
label var ESTDER_l "95% lower band" 
label var ESTDER_u "95% upper band" 

sort xgrid



** FIGURE 4 A 
twoway (line ESTFCT xgrid, sort clcolor(navy))  (line ESTFCT_u xgrid, sort clcolor(navy) clpat(dash)) (line ESTFCT_l xgrid, sort clcolor(navy) clpat(dash)  xtitle("Distance to VCT(KM)") ytitle("   ") legend(r(1)) xlabel(0 1 2 3 4  ) ) ,saving(Figure4a)


