

clear all
set more off

global root = "E:\Research\with Rita and Emma\replication"
global data = "$root\data"
global temp = "$root\temp"
global outfiles = "$root\outfiles"

** --------------------------------------------------------------------------------------
** Depression Dist. (Figure S2)
** --------------------------------------------------------------------------------------
use "$data\finaldata_ir_dep" , clear 

sum outcome_dep, d
	global mean_dep = r(mean)

twoway ///
( histogram outcome_dep, fcolor(gs5%70)  bin(18) lcolor(white) lwidth(vthin) ) ///
, ///
    xline($mean_dep , lcolor(gs3*0.8) lwidth(medthick) lpattern(shortdash)) ///
	xlabel(, nogrid) ///
	ylabel(, nogrid) ///
	legend(off)  ///
	xtitle("Depressive symptoms (final wave)", size(*0.95)) ///
	ytitle("Density", size(*0.95)) ///
            fxsize(120) fysize(100) ///
			xsize(10) ysize(8) ///
	text(0.14 3.6 "Mean 6.71  SD 3.20" "(Min 0, Max 18)", place(c) size(3) color(black) linegap(0.8)) ///
    scheme(plotplain) graphregion(color(white)) bgcolor(white) 

	graph export "$outfiles\dist_dep.png", replace width(1000)


*******************************************************************************************
** BTM, model fit: AvePP, BCI (Tables S2-S4)
*******************************************************************************************

**********************
*** Two trajectories
**********************
use "$data\data_afterdrop" , clear 

**Keep people with answers for relation score

keep pid year score_average score_low score_high

tab year
replace year=0 if year==2014
replace year=2 if year==2016
replace year=4 if year==2018
replace year=6 if year==2020

reshape wide score_average score_low score_high , i(pid) j(year)

forvalues i = 0(2)6{
	g year`i' = `i'
}

* worst relationship
traj, var( score_low* ) indep( year* ) model(cnorm) min(0) max(50) order(2 2)
trajplot, xtitle(Year) ytitle(Score)  ci

gen assigned_group = .
gen max_prob = .

forvalues i = 1/2 { // Replace 2 with the number of groups
    replace assigned_group = `i' if _traj_ProbG`i' == max(_traj_ProbG1, _traj_ProbG2)
    replace max_prob = max(_traj_ProbG1, _traj_ProbG2)
}

forvalues i = 1/2 { // Replace 2 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    di "Average Posterior Probability (AvePP) for Group `i': " r(mean)
}

gen avepp_G1 = .
gen avepp_G2 = .

forvalues i = 1/2 { // Replace 2 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    replace avepp_G`i' = r(mean) if _n == 1
}

drop  assigned_group max_prob avepp_G1 avepp_G2 

* best relationship
traj, var( score_high* ) indep( year* ) model(cnorm) min(0) max(50) order(2 2)
trajplot, xtitle(Year) ytitle(Score)  ci

gen assigned_group = .
gen max_prob = .

forvalues i = 1/2 { // Replace 2 with the number of groups
    replace assigned_group = `i' if _traj_ProbG`i' == max(_traj_ProbG1, _traj_ProbG2)
    replace max_prob = max(_traj_ProbG1, _traj_ProbG2)
}

forvalues i = 1/2 { // Replace 2 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    di "Average Posterior Probability (AvePP) for Group `i': " r(mean)
}

gen avepp_G1 = .
gen avepp_G2 = .

forvalues i = 1/2 { // Replace 2 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    replace avepp_G`i' = r(mean) if _n == 1
}

drop  assigned_group max_prob avepp_G1 avepp_G2 

* average relationship
traj, var( score_average* ) indep( year* ) model(cnorm) min(0) max(50) order(2 2)
trajplot, xtitle(Year) ytitle(Score)  ci

gen assigned_group = .
gen max_prob = .

forvalues i = 1/2 { // Replace 2 with the number of groups
    replace assigned_group = `i' if _traj_ProbG`i' == max(_traj_ProbG1, _traj_ProbG2)
    replace max_prob = max(_traj_ProbG1, _traj_ProbG2)
}

forvalues i = 1/2 { // Replace 2 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    di "Average Posterior Probability (AvePP) for Group `i': " r(mean)
}

gen avepp_G1 = .
gen avepp_G2 = .

forvalues i = 1/2 { // Replace 2 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    replace avepp_G`i' = r(mean) if _n == 1
}

drop  assigned_group max_prob avepp_G1 avepp_G2 

**********************
*** Three trajectories
**********************
* worst relationship
traj, var( score_low* ) indep( year* ) model(cnorm) min(0) max(50) order(1 2 2)
trajplot, xtitle(Year) ytitle(Score)  ci

gen assigned_group = .
gen max_prob = .

forvalues i = 1/3 { // Replace 3 with the number of groups
    replace assigned_group = `i' if _traj_ProbG`i' == max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3)
    replace max_prob = max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3)
}

forvalues i = 1/3 { // Replace 3 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    di "Average Posterior Probability (AvePP) for Group `i': " r(mean)
}

gen avepp_G1 = .
gen avepp_G2 = .
gen avepp_G3 = .

forvalues i = 1/3 { // Replace 3 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    replace avepp_G`i' = r(mean) if _n == 1
}

drop assigned_group max_prob avepp_G1 avepp_G2 avepp_G3

* best relationship
traj, var( score_high* ) indep( year* ) model(cnorm) min(0) max(50) order(1 2 2)
trajplot, xtitle(Year) ytitle(Score)  ci

gen assigned_group = .
gen max_prob = .

forvalues i = 1/3 { // Replace 3 with the number of groups
    replace assigned_group = `i' if _traj_ProbG`i' == max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3)
    replace max_prob = max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3)
}

forvalues i = 1/3 { // Replace 3 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    di "Average Posterior Probability (AvePP) for Group `i': " r(mean)
}

gen avepp_G1 = .
gen avepp_G2 = .
gen avepp_G3 = .

forvalues i = 1/3 { // Replace 3 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    replace avepp_G`i' = r(mean) if _n == 1
}

drop assigned_group max_prob avepp_G1 avepp_G2 avepp_G3

* average relationship
traj, var( score_average* ) indep( year* ) model(cnorm) min(0) max(50) order(1 2 2)
trajplot, xtitle(Year) ytitle(Score)  ci

gen assigned_group = .
gen max_prob = .

forvalues i = 1/3 { // Replace 3 with the number of groups
    replace assigned_group = `i' if _traj_ProbG`i' == max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3)
    replace max_prob = max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3)
}

forvalues i = 1/3 { // Replace 3 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    di "Average Posterior Probability (AvePP) for Group `i': " r(mean)
}

gen avepp_G1 = .
gen avepp_G2 = .
gen avepp_G3 = .

forvalues i = 1/3 { // Replace 3 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    replace avepp_G`i' = r(mean) if _n == 1
}

drop assigned_group max_prob avepp_G1 avepp_G2 avepp_G3

**********************
*** Four trajectories
**********************

* worst relationship
traj, var( score_low* ) indep( year* ) model(cnorm) min(0) max(50) order(1 2 2 1)
trajplot, xtitle(Year) ytitle(Score)  ci

gen assigned_group = .
gen max_prob = .

forvalues i = 1/4 { // Replace 4 with the number of groups
    replace assigned_group = `i' if _traj_ProbG`i' == max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3, _traj_ProbG4)
    replace max_prob = max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3, _traj_ProbG4)
}

forvalues i = 1/4 { // Replace 4 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    di "Average Posterior Probability (AvePP) for Group `i': " r(mean)
}

gen avepp_G1 = .
gen avepp_G2 = .
gen avepp_G3 = .
gen avepp_G4 = .

forvalues i = 1/4 { // Replace 4 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    replace avepp_G`i' = r(mean) if _n == 1
}

drop assigned_group max_prob avepp_G1 avepp_G2 avepp_G3 avepp_G4

* best relationship
traj, var( score_high* ) indep( year* ) model(cnorm) min(0) max(50) order(1 2 2 1)
trajplot, xtitle(Year) ytitle(Score)  ci

gen assigned_group = .
gen max_prob = .

forvalues i = 1/4 { // Replace 4 with the number of groups
    replace assigned_group = `i' if _traj_ProbG`i' == max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3, _traj_ProbG4)
    replace max_prob = max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3, _traj_ProbG4)
}

forvalues i = 1/4 { // Replace 4 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    di "Average Posterior Probability (AvePP) for Group `i': " r(mean)
}

gen avepp_G1 = .
gen avepp_G2 = .
gen avepp_G3 = .
gen avepp_G4 = .

forvalues i = 1/4 { // Replace 4 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    replace avepp_G`i' = r(mean) if _n == 1
}

drop assigned_group max_prob avepp_G1 avepp_G2 avepp_G3 avepp_G4

* average relationship
traj, var( score_average* ) indep( year* ) model(cnorm) min(0) max(50) order(1 2 2 1)
trajplot, xtitle(Year) ytitle(Score)  ci

gen assigned_group = .
gen max_prob = .

forvalues i = 1/4 { // Replace 4 with the number of groups
    replace assigned_group = `i' if _traj_ProbG`i' == max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3, _traj_ProbG4)
    replace max_prob = max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3, _traj_ProbG4)
}

forvalues i = 1/4 { // Replace 4 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    di "Average Posterior Probability (AvePP) for Group `i': " r(mean)
}

gen avepp_G1 = .
gen avepp_G2 = .
gen avepp_G3 = .
gen avepp_G4 = .

forvalues i = 1/4 { // Replace 4 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    replace avepp_G`i' = r(mean) if _n == 1
}

drop assigned_group max_prob avepp_G1 avepp_G2 avepp_G3 avepp_G4

**********************
**** Five trajectories
**********************

* worst relationship
traj, var( score_low* ) indep( year* ) model(cnorm) min(0) max(50) order(0 1 1 1 2)
trajplot, xtitle(Year) ytitle(Score)  ci

gen assigned_group = .
gen max_prob = .

forvalues i = 1/5 { // Replace 5 with the number of groups
    replace assigned_group = `i' if _traj_ProbG`i' == max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3, _traj_ProbG4, _traj_ProbG5)
    replace max_prob = max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3, _traj_ProbG4, _traj_ProbG5)
}

forvalues i = 1/5 { // Replace 5 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    di "Average Posterior Probability (AvePP) for Group `i': " r(mean)
}

gen avepp_G1 = .
gen avepp_G2 = .
gen avepp_G3 = .
gen avepp_G4 = .
gen avepp_G5 = .

forvalues i = 1/5 { // Replace 5 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    replace avepp_G`i' = r(mean) if _n == 1
}

drop assigned_group max_prob avepp_G1 avepp_G2 avepp_G3 avepp_G4 avepp_G5

* best relationship
traj, var( score_high* ) indep( year* ) model(cnorm) min(0) max(50) order(0 1 1 1 2)
trajplot, xtitle(Year) ytitle(Score)  ci

gen assigned_group = .
gen max_prob = .

forvalues i = 1/5 { // Replace 5 with the number of groups
    replace assigned_group = `i' if _traj_ProbG`i' == max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3, _traj_ProbG4, _traj_ProbG5)
    replace max_prob = max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3, _traj_ProbG4, _traj_ProbG5)
}

forvalues i = 1/5 { // Replace 5 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    di "Average Posterior Probability (AvePP) for Group `i': " r(mean)
}

gen avepp_G1 = .
gen avepp_G2 = .
gen avepp_G3 = .
gen avepp_G4 = .
gen avepp_G5 = .

forvalues i = 1/5 { // Replace 5 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    replace avepp_G`i' = r(mean) if _n == 1
}

drop assigned_group max_prob avepp_G1 avepp_G2 avepp_G3 avepp_G4 avepp_G5

* average relationship
traj, var( score_average* ) indep( year* ) model(cnorm) min(0) max(50) order(0 0 1 1 2)
trajplot, xtitle(Year) ytitle(Score)  ci

gen assigned_group = .
gen max_prob = .

forvalues i = 1/5 { // Replace 5 with the number of groups
    replace assigned_group = `i' if _traj_ProbG`i' == max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3, _traj_ProbG4, _traj_ProbG5)
    replace max_prob = max(_traj_ProbG1, _traj_ProbG2, _traj_ProbG3, _traj_ProbG4, _traj_ProbG5)
}

forvalues i = 1/5 { // Replace 5 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    di "Average Posterior Probability (AvePP) for Group `i': " r(mean)
}

gen avepp_G1 = .
gen avepp_G2 = .
gen avepp_G3 = .
gen avepp_G4 = .
gen avepp_G5 = .

forvalues i = 1/5 { // Replace 5 with the number of groups
    summarize _traj_ProbG`i' if assigned_group == `i', meanonly
    replace avepp_G`i' = r(mean) if _n == 1
}

drop assigned_group max_prob avepp_G1 avepp_G2 avepp_G3 avepp_G4 avepp_G5

** --------------------------------------------------------------------------------------
** Regression Robust -- dummy and Probit (Table S5)
** --------------------------------------------------------------------------------------

use "$data\finaldata_ir_dep" , clear 

global cov = "base_page base_female base_hk_ru base_mar base_peduy base_hp base_iadl base_depression base_numchilds base_lpinc "

g dum_outcome_dep = (outcome_dep>6) 
replace dum_outcome_dep = . if missing(outcome_dep)

probit dum_outcome_dep i.group_high $cov , vce(cluster pid) nolog
probit dum_outcome_dep i.group_low $cov , vce(cluster pid) nolog
probit dum_outcome_dep i.group_average $cov , vce(cluster pid) nolog
probit dum_outcome_dep i.group_low i.group_high i.group_average $cov , vce(cluster pid) nolog

* Gradual decline with sustained positivity
test 1.group_low = 1.group_high
test 1.group_low = 1.group_average
test 1.group_high = 1.group_average

* Steadily strengthening 
test 2.group_low = 2.group_high
test 2.group_low = 2.group_average
test 2.group_high = 2.group_average

* Rapidly strengthening
test 3.group_low = 3.group_high
test 3.group_low = 3.group_average
test 3.group_high = 3.group_average

** --------------------------------------------------------------------------------------
** Attrition description (Table S7)
** --------------------------------------------------------------------------------------
*keep main sample
use "$data\finaldata_ir_dep" , clear
keep pid 
g nonmiss = 1
save "$data\mainsample" , replace

*identify missing sample
use "$data\finaldata_ir_dep_forimput" , clear

merge 1:1 pid using "$data\mainsample", nogen keep(1 3)

g miss = (nonmiss==.)

* comparative description
ttest outcome_dep , by(miss)
tab group_low miss, chi2
tab group_high miss, chi2
tab group_average miss, chi2
ttest base_page , by(miss)
ttest base_female , by(miss)
ttest base_peduy , by(miss)
ttest base_lpinc , by(miss)
ttest base_hk_ru , by(miss)
ttest base_hp , by(miss)
ttest base_mar , by(miss)
ttest base_numchilds , by(miss)
ttest base_iadl , by(miss)
ttest base_depression , by(miss)


** --------------------------------------------------------------------------------------
** Attrition analysis (Table S8)
** --------------------------------------------------------------------------------------
*keep main sample
use "$data\finaldata_ir_dep" , clear
keep pid 
g nonmiss = 1
save "$data\mainsample" , replace

*identify missing sample
use "$data\finaldata_ir_dep_forimput" , clear

merge 1:1 pid using "$data\mainsample", nogen keep(1 3)

g miss = (nonmiss==.)

global cov = "base_page base_female base_hk_ru base_mar base_peduy base_hp base_iadl base_depression base_numchilds base_lpinc "

* attrition analysis
probit miss outcome_dep i.group_low i.group_high i.group_average $cov , vce(cluster pid)


** --------------------------------------------------------------------------------------
** Multiple imputation of covariates + descriptive statistics (Table S6)
** --------------------------------------------------------------------------------------
use "$data\finaldata_ir_dep_forimput", clear 

mi set wide 
mi xtset, clear 

* select variables to be imputed 
mi register imputed base_hk_ru base_mar base_hp base_peduy base_iadl base_depression base_lpinc

* variables to right of equal sign have complete obs and used as predictors for missing data
* initial  do 10 imputations 
mi impute chained ///
(logit) base_hk_ru base_mar base_hp ///
(regress) base_peduy base_iadl base_depression base_lpinc ///
= outcome_dep i.group_low i.group_high i.group_average base_page base_female base_numchilds, ///
add(5) rseed(5543) 


foreach var in base_hk_ru base_mar base_hp base_peduy base_iadl base_depression base_lpinc {
	ren _1_`var' `var'1 
	ren _2_`var' `var'2
	ren _3_`var' `var'3
	ren _4_`var' `var'4
	ren _5_`var' `var'5
}

drop base_hk_ru base_mar base_hp base_peduy base_iadl base_depression base_lpinc

mi reshape long base_hk_ru base_mar base_hp base_peduy base_iadl base_depression base_lpinc, i(pid outcome_dep group_low group_high group_average base_page base_female base_numchilds) j(imputed)

* Descriptive stats (Table S6)
global cov = "base_page base_female base_hk_ru base_mar base_peduy base_hp base_iadl base_depression base_numchilds base_lpinc "

sum outcome_dep $cov
tab group_low
tab group_high
tab group_average
tab base_female
tab base_hk_ru
tab base_hp
tab base_mar

** --------------------------------------------------------------------------------------
** Multiple imputation of covariates + regression (Table S9)
** --------------------------------------------------------------------------------------
use "$data\finaldata_ir_dep_forimput", clear 

mi set wide 
mi xtset, clear 

* select variables to be imputed 
mi register imputed base_page base_female base_hk_ru base_mar base_peduy base_hp base_iadl base_depression base_numchilds base_lpinc

* variables to right of equal sign have complete obs and used as predictors for missing data
* initial  do 10 imputations 
mi impute chained ///
(logit) base_hk_ru base_mar base_hp ///
(regress) base_peduy base_iadl base_depression base_lpinc ///
= outcome_dep i.group_low i.group_high i.group_average base_page base_female base_numchilds, ///
add(5) rseed(5543) 


* Main results (Table S9)
* note: if needed, use esampvaryok to get around subsample being different for each iteration 
global cov = "base_page base_female base_hk_ru base_mar base_peduy base_hp base_iadl base_depression base_numchilds base_lpinc "

mi estimate, esampvaryok post: regress outcome_dep i.group_high $cov , vce(cluster pid)
mi estimate, esampvaryok post: regress outcome_dep i.group_low $cov , vce(cluster pid)
mi estimate, esampvaryok post: regress outcome_dep i.group_average $cov , vce(cluster pid)
mi estimate, esampvaryok post: regress outcome_dep i.group_low i.group_high i.group_average $cov , vce(cluster pid)

** Wald test for column4 (see note of Table S9)
* Gradual decline with sustained positivity
test 1.group_low = 1.group_high
test 1.group_low = 1.group_average
test 1.group_high = 1.group_average

* Steadily strengthening 
test 2.group_low = 2.group_high
test 2.group_low = 2.group_average
test 2.group_high = 2.group_average

* Rapidly strengthening
test 3.group_low = 3.group_high
test 3.group_low = 3.group_average
test 3.group_high = 3.group_average












