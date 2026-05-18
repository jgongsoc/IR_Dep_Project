
clear all
set more off

global root = "E:\Research\with Rita and Emma\replication"
global data = "$root\data"
global temp = "$root\temp"
global outfiles = "$root\outfiles"

** --------------------------------------------------------------------------------------
** Step 4. Anlaysis
** --------------------------------------------------------------------------------------
use "$data\finaldata_ir_dep" , clear 

global cov = "base_page base_female base_hk_ru base_mar base_peduy base_hp base_iadl base_depression base_numchilds base_lpinc "

** summary statistics (Table 1)
sum outcome_dep $cov
tab group_low
tab group_high
tab group_average
tab base_female
tab base_hk_ru
tab base_hp
tab base_mar

** baseline (Table 2)
reghdfe outcome_dep i.group_high $cov , vce(cluster pid) // column1 
reghdfe outcome_dep i.group_low $cov , vce(cluster pid) // column2
reghdfe outcome_dep i.group_average $cov , vce(cluster pid) // column3
reghdfe outcome_dep i.group_low i.group_high i.group_average $cov , vce(cluster pid) // column4

** Wald test for column4 (see note of Table 2)
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

** heterogeneity (Table 3)
*by parents' SES
reg outcome_dep i.group_low i.group_high i.group_average $cov if base_lowses==1, vce(cluster pid) // column1 
reg outcome_dep i.group_low i.group_high i.group_average $cov if base_lowses==0, vce(cluster pid) // column2

*by parents' education
reg outcome_dep i.group_low i.group_high i.group_average $cov if base_pedu_blwhigh==1, vce(cluster pid) // column3
reg outcome_dep i.group_low i.group_high i.group_average $cov if base_pedu_blwhigh==0, vce(cluster pid) // column4

*by hukou status
reg outcome_dep i.group_low i.group_high i.group_average $cov if base_hk_ru==1, vce(cluster pid) // column5
reg outcome_dep i.group_low i.group_high i.group_average $cov if base_hk_ru==0, vce(cluster pid) // column6






