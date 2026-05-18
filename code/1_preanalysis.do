
clear all
set more off

global root " " //Change to your path
global data "$root\data"
global temp "$root\temp"
global outfiles "$root\outfiles"

* import data
use "$data\workdata14161820" , clear

** --------------------------------------------------------------------------------------
** Step 0. Clean worddatapooled (Only focus on parents with multiple children)
** --------------------------------------------------------------------------------------
***USE 2014-2020pooleddata
	*** generate child id ***
    g double cid = pid*100+rank_c
    label var cid "child id"
    label var pid "parent id"
    order cid, before(pid)
    drop if missing(cid) 
	sort cid year
    duplicates drop cid year, force
	
	*** define measures of intergenerational relationship ***	
    *(1)livetogether
    bysort pid: egen livetogether2 = sum(livetogether_c)
    drop livetogether

    g livetogether = 1 if livetogether2!=0&livetogether2!=.
    replace livetogether = 0 if livetogether2==0
    drop livetogether2
	
	*(2)Economic support (c: from each child to parents; p: Housework support from parents to each child)
    recode esup_c esup_p (9=1) (8=2) (7=3) (6=4) (5=5) (4=6) (3=7) (2=8) (1=9)
    lab def esup_c 1"0" 2"1-199RMB" 3"200-499RMB" 4"500-999RMB" 5"1000-1999RMB" 6"2000-3999RMB" 7"4000-6999RMB" 8"7000-11999RMB" 9"12000RMB+", replace
    lab def esup_p 1"0" 2"1-199RMB" 3"200-499RMB" 4"500-999RMB" 5"1000-1999RMB" 6"2000-3999RMB" 7"4000-6999RMB" 8"7000-11999RMB" 9"12000RMB+", replace
	
	label val esup_c esup_c
	label val esup_p esup_p
	
	*(3)Housework support (c: from each child to parents; p: Housework support from parents to each child)
    recode dsup_c dsup_p (5=1) (4=2) (3=3) (2=4) (1=5)
    lab def dsup_c 1"Almost never" 2"Several times a year" 3"At least once per month" 4"At least once per week" 5"Everyday", replace
    lab def dsup_p 1"Almost never" 2"Several times a year" 3"At least once per month" 4"At least once per week" 5"Everyday", replace
	
	label val dsup_c dsup_c
	label val dsup_p dsup_p

    *(4)Frequency of meetings with each child
    recode mfreq (5=1) (4=2) (3=3) (2=4) (1=5)
	lab def mfreq 1"Almost never" 2"Several times a year" 3"At least once per month" 4"At least once per week" 5"Everyday", replace

	label val mfreq mfreq
	
    *(5)Frequency of online contact with each child
    recode cfreq (6 9 0=0) (5=1) (4=2) (3=3) (2=4) (1=5)
    lab def cfreq 0"No need" 1"Almost never" 2"Several times a year" 3"At least once per month" 4"At least once per week" 5"Everyday", replace

	label val cfreq cfreq
	
    *(6)Parents' self-rated closeness toward each child
    recode relationship (3=1) (2=2) (1=3)
    lab def relationship 1"Not close" 2"Fair" 3"Close", replace

	label val relationship relationship
	
    *(7)Parents' self-rated excessive help each child required
    recode attitude_h (4=1) (3=2) (2=3) (1=4)
    lab def attitude_h 1"Often" 2"Sometimes" 3"Occasionally" 4"Never", replace
	
	label val attitude_h attitude_h

    *(8)Parents' self-rated emotional indifference from each child
    recode attitude_c (4=1) (3=2) (2=3) (1=4)
	lab def attitude_c 1"Usually" 2"Sometimes" 3"Few times" 4"Never", replace

	label val attitude_c attitude_c

* drop minor children
drop if age_c < 15 

* drop single child families and families with 5+ children
drop if numchilds<=1 | numchilds>5 

* keep at least 2 working aged children
g obs=1
bys pid year: egen childnum_wkage = sum(obs)
keep if childnum_wkage > 1
drop obs 
	
** --------------------------------------------------------------------------------------
** Step 1. Generate relationship score and keep individuals with at least three observations
** --------------------------------------------------------------------------------------
***USE Four waves of data to identify relation trajectories
***CLASS14-20
*** Generate relationship score
egen score = rowtotal (relationship attitude_h attitude_c esup_c esup_p dsup_c dsup_p mfreq cfreq) if !missing(relationship, attitude_h, attitude_c, esup_c, esup_p, dsup_c, dsup_p, mfreq, cfreq)

bys pid year: egen score_low = min(score)
bys pid year: egen score_high = max(score)
bys pid year: egen score_average = mean(score)

bys pid year: egen age_c_average = mean(age_c)
drop age_c

duplicates drop pid year, force

***Keep people with at least three observations
by pid: gen total_num=_N
drop if total_num==1 | total_num==2 

order pid year total_num

*** adjut gender
    lab def gender 1"Male" 2"Female", replace
	label val gender gender

g female = (gender == 2)
replace female = . if missing(gender)
drop gender

*** adjust hukou
    lab def hukou 1"Rural" 2"Urban" 3"Resident/Urban", replace
	label val hukou hukou

g hk_ru = (hukou == 1)
replace hk_ru = . if missing(hukou)
drop hukou

*** adjust edu
g num = 1 if year==2014
replace num = 2 if year==2016
replace num = 3 if year==2018
replace num = 4 if year==2020
xtset pid num

g lag1_peduy = l.peduy
g lag2_peduy = ll.peduy
g lag3_peduy = lll.peduy
order lag1_peduy lag2_peduy lag3_peduy, after(peduy)
* education in the later obs should not be lower than previous observations
bys pid: replace peduy = . if peduy < lag1_peduy & !missing(peduy) & !missing(lag1_peduy) 
bys pid: replace peduy = . if peduy < lag2_peduy & !missing(peduy) & !missing(lag2_peduy)
bys pid: replace peduy = . if peduy < lag3_peduy & !missing(peduy) & !missing(lag3_peduy)

gsort pid year
carryforward peduy , replace

drop num 

** --------------------------------------------------------------------------------------
** Step 2. keep sample with non-missing outcome variable in the last wave of survey and non-missing covariates in the base wave of survey
** --------------------------------------------------------------------------------------
bys pid: g num = _n
bys pid: egen max_num = max(num) // last obs
bys pid: egen min_num = min(num) // base obs

* outcome variable
g dep_miss = 1 if missing(depression) & num==max_num
replace dep_miss = 0 if !missing(depression) & num==max_num

bys pid: egen sum_dep_miss = sum(dep_miss)
keep if sum_dep_miss == 0

drop dep_miss sum_dep_miss

foreach cov in page female hk_ru mar peduy hp pinc iadl depression numchilds {
	
	g miss_`cov' = 1 if missing(`cov') & num==min_num // base obs
	bys pid: egen sum_miss_`cov' = sum(miss_`cov')
	keep if sum_miss_`cov' == 0
	drop miss_`cov' sum_miss_`cov'

}

save "$data\data_afterdrop" , replace

** --------------------------------------------------------------------------------------
** Step 3. USE Growth-based trajectory modeling to identify 4 groups (relationship score)
** --------------------------------------------------------------------------------------
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

*** Four trajectories & Model fit of GBTM
* best relationship
traj, var( score_high* ) indep( year* ) model(cnorm) min(0) max(50) order(1 2 2 1)
trajplot, xtitle(Year) ytitle(Score)  ci legendLabels(label(1 "Persistently strained (10.1%)") label(2 "Steadily strengthening (53.5%)") label(3 "Rapidly strengthening (28.6%)") label(4 "Gradual decline w/ sust. positivity (7.8%)") size(small) rows(2) colgap(*2)) 

ren _traj_Group group_high
drop _traj_ProbG1 _traj_ProbG2 _traj_ProbG3 _traj_ProbG4

label def group_high 1 "Persistently strained relationship" 2 "Steadily strengthening relationship" 3 "Rapidly strengthening relationship" 4 "Gradual decline with sustained positivity" , replace
label val group_high group_high

graph export "$outfiles\besttype.png" , replace width(3000)

* worst relationship
traj, var( score_low* ) indep( year* ) model(cnorm) min(0) max(50) order(1 2 2 1)
trajplot, xtitle(Year) ytitle(Score)  ci legendLabels(label(1 "Persistently strained (13.3%)") label(2 "Steadily strengthening (57.9%)") label(3 "Rapidly strengthening (17.5%)") label(4 "Gradual decline w/ sust. positivity (11.2%)") size(small) rows(2) colgap(*2)) 

ren _traj_Group group_low
drop _traj_ProbG1 _traj_ProbG2 _traj_ProbG3 _traj_ProbG4

label def group_low 1 "Persistently strained relationship" 2 "Steadily strengthening relationship" 3 "Rapidly strengthening relationship" 4 "Gradual decline with sustained positivity" , replace
label val group_low group_low

graph export "$outfiles\worsttype.png" , replace width(3000)

* average relationship
traj, var( score_average* ) indep( year* ) model(cnorm) min(0) max(50) order(1 2 2 1)
trajplot, xtitle(Year) ytitle(Score)  ci legendLabels(label(1 "Persistently strained (9.4%)") label(2 "Steadily strengthening (56.4%)") label(3 "Rapidly strengthening (24.9%)") label(4 "Gradual decline w/ sust. positivity (9.3%)") size(small) rows(2) colgap(*2)) 

ren _traj_Group group_average
drop _traj_ProbG1 _traj_ProbG2 _traj_ProbG3 _traj_ProbG4

label def group_average 1 "Persistently strained relationship" 2 "Steadily strengthening relationship" 3 "Rapidly strengthening relationship" 4 "Gradual decline with sustained positivity" , replace
label val group_average group_average

graph export "$outfiles\averagetype.png" , replace width(3000)


keep pid group_high group_low group_average 
save "$data\group_traj_3wave" , replace


** --------------------------------------------------------------------------------------
** Step 3. Generate final data
** --------------------------------------------------------------------------------------

use "$data\data_afterdrop" , clear
merge m:1 pid using "$data\group_traj_3wave" , nogen keep(1 3)  

g outcome_dep = depression if num==max_num
gsort pid outcome_dep
carryforward outcome_dep , replace

foreach cov in page female hk_ru mar peduy hp pinc iadl depression numchilds year lowses1 lowses2 {

   g base_`cov' = `cov' if num==min_num
		g base_`cov'_miss = 1 if num==min_num & missing(`cov')
		bys pid: egen sum_base_`cov'_miss = sum(base_`cov'_miss)
   gsort pid num
   carryforward base_`cov' , replace
   
   replace base_`cov' = . if sum_base_`cov'_miss>0
   drop base_`cov'_miss sum_base_`cov'_miss

}

keep pid group_high group_low group_average outcome_dep base_* age_c_average

duplicates drop pid , force

g base_lpinc = log(1 + base_pinc)

g base_pedu_blwhigh = (base_peduy <= 6)

sum base_lpinc ,d
g base_lpinc_med = r(mean)
g base_lpinc_blwmed = (base_lpinc <= base_lpinc_med)

* Recode IR measure
foreach i in low high average {
	recode group_`i' (1=0) (4=1) (2=2) (3=3)
	label def group_`i' 0 "Persistently strained relationship" 1 "Gradual decline with sustained positivity" 2 "Steadily strengthening relationship" 3 "Rapidly strengthening relationship" , replace
	label val group_`i' group_`i'
}

save "$data\finaldata_ir_dep", replace



