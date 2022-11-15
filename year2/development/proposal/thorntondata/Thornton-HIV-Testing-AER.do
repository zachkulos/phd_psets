*******************************************************************
*	This file creates the tables for:					*	
*	   The Demand for and Impact of Learning HIV Results:		*
*		Evidence from a Field Experiment				*
*		Rebecca L. Thornton						*
*											*
*	Version: March 13, 2008							*
*											*
*******************************************************************

clear
set mem 500m
use "Thornton HIV Testing Data.dta", clear

* GENERATE INTERACTION TERMS AND VARIABLES
* exchange rate as of jan1 2005
replace tinc = tinc *0.009456

gen consentany2004= T_consenthiv
replace consentany2004=1 if T_consentsti==1 & consentany!=1


gen inter98 = 1 if m1out==2
gen inter01 =1 if m2out==2


foreach var of varlist hadsex12 havesex_fo {
gen got_`var' = got*`var'
gen got_hiv_`var' = got*`var'*hiv2004
gen any_hiv_`var' = any*`var'*hiv2004
gen tinc_hiv_`var' = tinc*`var'*hiv2004
gen under_hiv_`var' = under*`var'*hiv2004
gen any_male_`var' = any*`var'*male
}

foreach var of varlist any tinc under{
gen `var'_male = `var'* male
}

gen male_under = male*under

drop any_male tinc_male under_male 

foreach var of varlist got hiv2004 male havesex hadsex   {
gen any_`var' = any*`var' 
gen tinc_`var'  = tinc*`var' 
gen under_`var'  = under * `var' 
gen over_`var'  = over* `var' 
}

foreach var of varlist distvct  got hadsex male havesex {
gen male_`var' = male*`var'
gen any_`var'_hiv = any*`var' * hiv2004
gen tinc_`var'_hiv = tinc*`var' * hiv2004
gen under_`var'_hiv = under*`var' * hiv2004
gen over_`var'_hiv = over*`var' * hiv2004
gen hiv_`var' = hiv2004*`var'
gen `var'_hiv = hiv2004*`var'
gen any_`var'_male= any*`var' * male
gen tinc_`var'_male= tinc*`var' * male
gen under_`var'_male = under*`var' * male
}
gen tinc_male_hadsex12 =tinc_male*hadsex12 
gen under_male_hadsex12 =under_male*hadsex12

* Generate the main sample for the paper
gen MainSample = 1 if test2004==1 & age!=. & villnum!=. & tinc!=. & distvct!=. & hiv2004!=-1 & followup_test!=1


** TABLE 1: SAMPLE SIZE AND ATTRITION
** Panel A: Sample Size and Attrition
tab inter01 if inter98==1 ,mi
tab survey2004 if inter98==1 ,mi
tab survey2004 if inter01==1 ,mi

tab Main
tab followupsu if Main==1  & site!=1

tab test2004 

tab followupsu if Main==1  & site!=1

** Panel B: Determinants of accepting an HIV test
reg test2004 male age age2 mar tb rumphi balaka , robust cluster(villnum)
outreg using Table1.xls, se replace 10pct bra sigsymb(***, **, *) coefastr bdec(3) 
reg test2004 male age age2 mar tb rumphi balaka thinktreat likenow, robust cluster(villnum)
outreg using Table1.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) 

** Panel C: Determinants of Participation in the Follow-up Survey
reg followupsur any tinc distvct male age age2 simave got  hiv2004 rumphi if Main==1 & site!=1, robust cluster(villnum)
outreg using Table1.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) 


* * Sample of tested individuals and summary stats
keep if Main==1
save nonparametricvct.dta, replace


*** TABLE 2: SUMMARY STATISTICS
count
count if followupsu==1
* Panel A: Respondent Characteristics
sum male age mar educ2004 tinc distvct land2004 
sum male age mar educ2004 tinc distvct land2004 if followups==1

* Panel B: Health
sum hiv2004
sum hiv2004 if followups==1

sum T_final_result_gc  if  T_final_result_gc <8 
sum T_final_result_gc  if  T_final_result_gc <8  & followups==1

sum T_final_result_ct  if  T_final_result_ct <8
sum T_final_result_ct  if  T_final_result_ct <8 & followups==1

sum T_final_trich 
sum T_final_trich  if followups==1

sum tb thinktreat hadsex12 usecondom04 
sum tb thinktreat hadsex12 usecondom04 if followupsur==1

sum timeshadsex_s if timeshadsex_s!=88 & timeshadsex_s!=0
sum timeshadsex_s if timeshadsex_s!=88 & timeshadsex_s!=0 & followupsur==1

* Panel C: Incentives, Distance, and Attendance
sum tinc distvct got 
sum tinc distvct got if followupsur==1
sum got if tinc==0
sum got if tinc==0 & followups==1

* Panel D: Follow-up Condom sales
sum anycond numcond bought havesex_fo
sum numcond  if anycond!=0
gen more1_fo = 1 if numsex_fo>1 & numsex_fo!=.
replace more1_fo = 0 if numsex_fo==1|numsex_fo==0
sum more1_fo

* In text: (section 2.1)	
bys male:sum hiv2004
bys male: sum usecondom04

* In text: (section 2.2)	
tab any
tab distvct


** TABLE 3: Baseline Characteristics by Incentives and Distance
reg male any tinc under rumphi balaka , robust cluster(villnum)
outreg using Table3.xls, se replace 3aster bra coefastr bdec(3)

foreach var of varlist age hiv2004 educ2004 land2004 hadsex12 usecondom04 {
reg `var' any tinc under rumphi balaka , robust cluster(villnum)
outreg using Table3.xls, se append 3aster bra coefastr bdec(3)
}


** TABLE 4: Impact of Monetary Incentives and Distance on Learning results
gen distvcts = distvct*distvct

*Columns 1-4: OLS
reg got any male hiv2004 age age2 rumphi balaka , robust cluster(villnum) 
outreg using Table4a.xls, se replace 10pct bra sigsymb(***, **, *) coefastr bdec(3) 
reg got any tinc male hiv2004 age age2 rumphi balaka, robust cluster(villnum) 
outreg using Table4a.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) 

reg got any tinc distvct distvcts simave male hiv2004 age age2 rumphi balaka, robust cluster(villnum) 
outreg using Table4a.xls, se append 10pct bra sigsymb(***,**, *) coefastr bdec(3) 
reg got any tinc over simave male hiv2004 age age2 rumphi balaka, robust cluster(villnum) 
outreg using Table4a.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3)

*Columns 5-8: Probit
dprobit got any male hiv2004 age age2 rumphi balaka , robust cluster(villnum) 
outreg using Table4b.xls, se replace 10pct bra sigsymb(***, **, *) coefastr bdec(3) 
dprobit got any tinc male hiv2004 age age2 rumphi balaka, robust cluster(villnum) 
outreg using Table4b.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) 

dprobit got any tinc distvct distvcts simave male hiv2004 age age2 rumphi balaka, robust cluster(villnum) 
outreg using Table4b.xls, se append 10pct bra sigsymb(***,**, *) coefastr bdec(3) 
dprobit got any tinc over simave male hiv2004 age age2 rumphi balaka, robust cluster(villnum) 
outreg using Table4b.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3)



** TABLE 5: Covariates and Interactions
gen male_any = male*any
gen never = 1 if eversex==0 
replace never=0 if eversex==1 
gen any_never=any*never 
gen over_any=over*any 
gen hiv_any=hiv2004*any

reg got any tinc male hiv2004 over tb thinktreat mar simave rumphi balaka , robust cluster(villnum)
outreg using Table5.xls, se replace 10pct bra sigsymb(***, **, *) coefastr bdec(3) 
reg got any tinc male hiv2004 over simave never any_never rumphi balaka if mar==0, robust cluster(villnum)
outreg using Table5.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3)

reg got any tinc male_any male hiv2004 over simave rumphi balaka if balaka== 1, robust cluster(villnum)
outreg using Table5.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3)

reg got over over_any hiv2004 age male any tinc age2 simav rumphi balaka, robust cluster(villnum) 
outreg using Table5.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) 
reg got over over_hiv hiv2004 age male any tinc age2 simav rumphi balaka, robust cluster(villnum) 
outreg using Table5.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3)

reg got over hiv_any hiv2004 age male any tinc age2 simav rumphi balaka, robust cluster(villnum) 
outreg using Table5.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3)

sum got if balaka== 1
sum got if mar==0
sum got



* TABLE 6: FIRST STAGE
preserve
keep if followupsu==1

reg got any_male tinc_male under_male any tinc under  any_male_hiv tinc_male_hiv under_male_hiv any_hiv2004 tinc_hiv2004 under_hiv2004 hiv2004 male  age age2 simave rumphi if hadsex12==1, robust cluster(villnum)
outreg using Table6.xls, se replace 3aster coefastr bdec(3) bra
reg hiv_got any_male tinc_male under_male any tinc under  any_male_hiv tinc_male_hiv under_male_hiv any_hiv2004 tinc_hiv2004 under_hiv2004 hiv2004 male  age age2 simave rumphi if hadsex12==1, robust cluster(villnum)
outreg using Table6.xls, se append 3aster coefastr bdec(3) bra
restore



** TABLE 7: Effects of Learning HIV Results among sexually active
ivreg anycond  hiv_got got hiv2004 male  age age2 simave rumphi if hadsex12==1, robust cluster(villnum) 
outreg using Table7.xls, se replace 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(anycond )
ivreg anycond  ( hiv_got  got= any_male tinc_male under_male any tinc under  any_male_hiv tinc_male_hiv under_male_hiv any_hiv2004 tinc_hiv2004 under_hiv2004) hiv2004 male  age age2 simave rumphi if hadsex12==1, robust cluster(villnum) 
outreg using Table7.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(anycond )
ivreg numcond hiv_got got hiv2004 male  age age2 simave rumphi if hadsex12==1, robust cluster(villnum) 
outreg using Table7.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(num)
ivreg numcond ( hiv_got  got= any_male tinc_male under_male any tinc under  any_male_hiv tinc_male_hiv under_male_hiv any_hiv2004 tinc_hiv2004 under_hiv2004) hiv2004 male  age age2 simave rumphi if hadsex12==1, robust cluster(villnum) 
outreg using Table7.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(num)
ivreg bought hiv_got  got hiv2004 male  age age2 simave rumphi if hadsex12==1, robust cluster(villnum) 
outreg using Table7.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(bought)
ivreg bought ( hiv_got got= any_male tinc_male under_male any tinc under  any_male_hiv tinc_male_hiv under_male_hiv any_hiv2004 tinc_hiv2004 under_hiv2004) hiv2004 male  age age2 simave rumphi if hadsex12==1, robust cluster(villnum) 
outreg using Table7.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(bought)
ivreg havesex_fo hiv_got got hiv2004 male  age age2 simave rumphi if hadsex12==1, robust cluster(villnum) 
outreg using Table7.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(havesex)
ivreg havesex_fo ( hiv_got got= any_male tinc_male under_male any tinc under  any_male_hiv tinc_male_hiv under_male_hiv any_hiv2004 tinc_hiv2004 under_hiv2004) hiv2004 male  age age2 simave rumphi if hadsex12==1, robust cluster(villnum) 
outreg using Table7.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(havesex)

sum anycond  numcond bought havesex_fo if hadsex12==1




** TABLE 8: Probit Estimates
** OLS
ivreg anycond  got male  age age2 simave rumphi if hadsex12==1 & hiv2004==1 , robust cluster(villnum) 
outreg using Table8a.xls, se replace 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(anycond )
** IV
ivreg anycond  ( got= any_male tinc_male under_male any tinc under  ) male  age age2 simave rumphi if hadsex12==1 & hiv2004==1 , robust cluster(villnum) 
outreg using Table8a.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(anycond )

** OLS
ivreg anycond  got male  age age2 simave rumphi if hadsex12==1 & hiv2004==0 , robust cluster(villnum) 
outreg using Table8a.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(anycond )
** IV
ivreg anycond  ( got= any_male tinc_male under_male any tinc under  ) male  age age2 simave rumphi if hadsex12==1 & hiv2004==0 , robust cluster(villnum) 
outreg using Table8a.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(anycond )


** dprobit
dprobit anycond  got male  age age2 simave rumphi if hadsex12==1 & hiv2004==1 , robust cluster(villnum) 
outreg using Table8b.xls, se replace 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(anycond )
dprobit anycond  got male  age age2 simave rumphi if hadsex12==1 & hiv2004==0 , robust cluster(villnum) 
outreg using Table8b.xls, se append 10pct bra sigsymb(***, **, *) coefastr bdec(3) ctitle(anycond )


** 2 stage probit
probit got any_male tinc_male under_male any tinc under  male  age age2 simave rumphi if hadsex12==1 & followupsurve==1 & hiv2004==1, robust cluster(villnum)
predict betagot 
probit anycond betagot male  age age2 simave rumphi if hadsex12==1 & hiv2004==1, robust cluster(villnum)
bootstrap _b, reps(500) seed(1234) :probit anycond betagot male  age age2 simave rumphi if hadsex12==1 & hiv2004==1, robust cluster(villnum)
mfx
drop beta*

probit got any_male tinc_male under_male any tinc under  male  age age2 simave rumphi if hadsex12==1 & followupsurve==1 & hiv2004==0, robust cluster(villnum)
predict betagot 
probit anycond betagot male  age age2 simave rumphi if hadsex12==1 & hiv2004==0, robust cluster(villnum)
bootstrap _b, reps(500) seed(1234) :probit anycond betagot male  age age2 simave rumphi if hadsex12==1 & hiv2004==0, robust cluster(villnum)
mfx
drop beta*

bys hiv2004: sum anycond if hadsex12==1 & followupsurve==1 

** TABLE 9: Interaction with Sexual Behavior: Only HIV Negatives
ivreg anycond  got got_hadsex12 hadsex12 male age age2 simave rumphi if hiv2004==0 , robust cluster(villnum) 
outreg using Table9.xls, se replace 3aster coefastr bdec(3) bra
ivreg anycond  (got got_hadsex12 = any_male tinc_male under_male  under any tinc under_hadsex12 tinc_hadsex12 any_hadsex12 any_male_hadsex12 tinc_male_hadsex12 under_male_hadsex12  ) hadsex12 male age age2 simave rumphi if hiv2004==0 , robust cluster(villnum) 
outreg using Table9.xls, se append 3aster coefastr bdec(3) bra

ivreg numcond got got_hadsex12 hadsex12 male age age2 simave rumphi if hiv2004==0 , robust cluster(villnum) 
outreg using Table9.xls, se append 3aster coefastr bdec(3) bra
ivreg numcond (got got_hadsex12 = any_male tinc_male under_male  under any tinc under_hadsex12 tinc_hadsex12 any_hadsex12 any_male_hadsex12 tinc_male_hadsex12 under_male_hadsex12  ) hadsex12 male age age2 simave rumphi if hiv2004==0 , robust cluster(villnum) 
outreg using Table9.xls, se append 3aster coefastr bdec(3) bra

ivreg bought got got_hadsex12 hadsex12 male age age2 simave rumphi if hiv2004==0 , robust cluster(villnum) 
outreg using Table9.xls, se append 3aster coefastr bdec(3) bra
ivreg bought (got got_hadsex12 = any_male tinc_male under_male  under any tinc under_hadsex12 tinc_hadsex12 any_hadsex12 any_male_hadsex12 tinc_male_hadsex12 under_male_hadsex12  ) hadsex12 male age age2 simave rumphi if hiv2004==0 , robust cluster(villnum) 
outreg using Table9.xls, se append 3aster coefastr bdec(3) bra

ivreg havesex_fo got got_hadsex12 hadsex12 male age age2 simave rumphi if hiv2004==0 , robust cluster(villnum) 
outreg using Table9.xls, se append 3aster coefastr bdec(3) bra 
ivreg havesex_fo (got got_hadsex12 = any_male tinc_male under_male  under any tinc under_hadsex12 tinc_hadsex12 any_hadsex12 any_male_hadsex12 tinc_male_hadsex12 under_male_hadsex12  ) hadsex12 male age age2 simave rumphi if hiv2004==0 , robust cluster(villnum) 
outreg using Table9.xls, se append 3aster coefastr bdec(3) bra
 
sum anycond numcond bought havesex_fo  if hiv2004==0 & hadsex12!=.



** TABLE 10: Likelihood of Infection
** Appendix ************* likelihood of infection
gen ll = 0 if a8==0
replace ll = 1 if a8!=0 & a8!=.
gen ll_fo = 0 if likelihoodhiv_fo==1
replace ll_fo = 1 if likelihoodhiv_fo!=1 & likelihoodhiv_fo!=.

bys hiv2004: sum ll
bys hiv2004 got: sum ll_fo

reg ll_fo got male age age2 r  if hiv2004==0, robust cluster(villnum)
reg ll_fo got male age age2 r  if hiv2004==1, robust cluster(villnum)



** TABLE 11: Interaction with Prior Beliefs of Infection
gen got_ll = got*ll
gen got_ll_fo = got*ll_fo

gen any_ll=any*ll
gen tinc_ll=tinc*ll
gen under_ll=under*ll
gen any_male_ll = any*male*ll
gen tinc_male_ll = male*tinc*ll
gen under_male_ll = male*under*ll

ivreg anycond   got got_ll ll male  age age2 simave rumphi if hiv2004==1 & hadsex12==1, robust cluster(villnum) 
outreg using Table11.xls, se replace bra 3aster coefastr bdec(3)
ivreg anycond  ( got got_ll= any_male tinc_male under_male any tinc under any_ll tinc_ll under_ll any_male_ll tinc_male_ll under_male_ll) ll male  age age2 simave rumphi if hiv2004==1 & hadsex12==1, robust cluster(villnum) 
outreg using Table11.xls, se append 3aster coefastr bdec(3)

ivreg anycond   got got_ll ll male  age age2 simave rumphi if hiv2004==0 & hadsex12==1, robust cluster(villnum) 
outreg using Table11.xls, se append bra 3aster coefastr bdec(3)
ivreg anycond  ( got got_ll= any_male tinc_male under_male any tinc under any_ll tinc_ll under_ll any_male_ll tinc_male_ll under_male_ll) ll male  age age2 simave rumphi if hiv2004==0 & hadsex12==1, robust cluster(villnum) 
outreg using Table11.xls, se append 3aster bra coefastr bdec(3)

** TABLE 12: Cost effectivenes
* See text of paper

**** Graphs
** FIGURE 1: Map

** FIGURE 2: Theoretical and Actual Distribution
append using "Theoretical Dist. of Incentives.dta" 
replace theory = 0 if theory==. 
ksmirnov tinc, by(theory) 
cumul tinc if theory ==1 , gen(Theoretical) 
cumul tinc if theory ==0 , gen(Actual) 
reg tinc theory
twoway (kdensity tinc if theory==0) (kdensity tinc if theory ==1, clpat(dash)), ytitle(Kernal Density ) xtitle(Total Amount of Incentive (Dollars)) legend(order(1 "Actual Distribution" 2 "Theoretical Distribution") ) saving(appendixA)
graph2tex, epsfile(Figure2)

drop if theory==1

* FIGURE 3 A
tab any, sum(got)

* FIGURE 3 B
gen Ti2 =.2 if tinc<.2 & tinc>0 
replace Ti2 =.5 if tinc<.5 & tinc>=.2 
replace Ti2 =1 if tinc<1 & tinc>=.5 
replace Ti2 =1.5 if tinc<1.5 & tinc>=1
replace Ti2 =2 if tinc<2 & tinc>=1.5 
replace Ti2 =2.5 if tinc<2.8 & tinc>=2 
replace Ti2 =3 if tinc>=2.8

tab Ti2, sum(got)

** FIGURE 4 
do "Figure 4 A.do"

* FIGURE 4 B
do "Figure 4 B.do"

* FIGURE 5
bys got : sum anycond if hiv2004==0
bys got : sum anycond if hiv2004==1
