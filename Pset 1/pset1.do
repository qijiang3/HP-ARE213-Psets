*Title: pset1.do
*Purpose: clean data and perform analysis for ARE 213 Problem Set 1
* Created by: Jaclyn Schess, jaclyn.schess@berkeley.edu
* Project team: Jaclyn Schess, Alexander Adia, Qi Jiang
* Created on: September 20th, 2023
* Last edited: September 20th, 2023


/*************************
0. Set Up
**************************/

clear all
set more off

cd "/Users/jaclynschess/Documents/All/Berkeley/Coursework/ARE213"
*log close
*log using pset1, replace
/*************************
1. Clean Data and Create Analytic Data File
**************************/

use pset1.dta, clear

*Part a:
*Investigate missing value coding
foreach v in cardiac lung diabetes herpes chyper phyper pre4000 preterm tobacco cigar6 alcohol drink5 wgain{
tabulate `v'
}

/* Codes for missing values
cardiac: 9
lung: 9
diabetes: 9
herpes: 8/9
chyper: 9
phyper: 9
pre4000: 9
preterm: 9
tobacco: 9
cigar6: 6
alcohol: 9
drink5: 5
wgain: 99 
*/

*Recode as missing
foreach v in cardiac lung diabetes chyper phyper pre4000 preterm tobacco alcohol{
recode `v' (9=.)
}

recode herpes (8/9=.)
recode cigar6 (6=.)
recode drink5 (5=.)
recode wgain (99=.)

*Part b: More recoding

*Recode indicators
foreach v in anemia cardiac lung diabetes herpes chyper phyper pre4000 preterm tobacco alcohol{
recode `v' (2=0)
}

recode csex (2=0)
recode dmar (2=0)
recode ormoth (1/5=1)
recode orfath (1/5=1)

gen mwhite=1 if mrace3==1 
replace mwhite=0 if mwhite==.
gen mblack=1 if mrace3==3
replace mblack=0 if mblack==.
gen mothrace=1 if mrace3==2
replace mothrace=0 if mothrace==.
drop mrace3

*Drop variables not using
drop stresfip birmon weekday

*Part c: Handling missing values

ssc install ietoolkit

gen missing = 0
foreach var of varlist _all {
	replace missing = 1 if `var' == .
}	

iebaltab dbrwt tobacco cntocpop dmage ormoth mwhite mblack mothrace dmeduc dmar totord9  ///
monpre nprevist isllb10 dfage dgestat omaps fmaps clingest anemia cardiac ///
lung diabetes herpes chyper pre4000 wgain, grpvar(missing) replace ///
	savetex(MCAR.tex)


*Drop observations with any missing data -> 114,610 observations left
local vars rectype pldel3 birattnd cntocpop dmage ormoth dmeduc dmar adequacy nlbnl dlivord totord9 monpre nprevist isllb10 dfage orfath dfeduc dgestat csex dbrwt dplural omaps fmaps clingest anemia cardiac lung diabetes herpes chyper phyper pre4000 preterm tobacco cigar6 alcohol drink5 wgain mwhite mblack mothrace
foreach var of local vars {
drop if `var'==.
}

*Part d: Create Table 1

iebaltab dbrwt cntocpop dmage ormoth mwhite mblack mothrace dmeduc dmar totord9  ///
monpre nprevist isllb10 dfage dgestat omaps fmaps clingest anemia cardiac ///
lung diabetes herpes chyper pre4000 wgain, grpvar(tobacco) replace ///
	savetex(Descriptives.tex)


/*************************
Part 2
**************************/
*2a:
summ dbrwt if tobacco==1
summ dbrwt if tobacco==0

*2b done on Overleaf
/*************************
Part 3
**************************/
local covars dmage ormoth mwhite mblack mothrace dmeduc dmar adequacy monpre nprevist isllb10 ///
	dgestat csex dplural anemia cardiac lung diabetes herpes chyper phyper


*A:

reg dbrwt tobacco `covars'


*B: 
/*
reg dbrwt dmage ormoth mwhite mblack dmeduc dmar nprevist anemia cardiac lung diabetes herpes chyper phyper csex dplural
reg dbrwt dmage ormoth mwhite mblack dmeduc dmar nprevist anemia cardiac lung diabetes herpes chyper phyper csex 
reg dbrwt dmage ormoth mwhite mblack dmeduc dmar nprevist anemia cardiac lung diabetes herpes chyper phyper 
reg dbrwt dmage ormoth mwhite mblack dmeduc dmar nprevist anemia cardiac lung diabetes herpes chyper 
reg dbrwt dmage ormoth mwhite mblack dmeduc dmar nprevist anemia cardiac lung diabetes herpes 
*/

*C: 

reg dbrwt tobacco (`covars')##tobacco


*D: 
reg dbrwt tobacco $covars omaps fmaps


*E: 
ssc install oaxaca
oaxaca dbrwt $covars, by(tobacco) pooled
*reg in just smoker

/*************************
Part 4
**************************/

* a. propensity score
global pscore cntocpop dmage ormoth dmeduc dmar adequacy nlbnl dlivord totord9 monpre ///
nprevist isllb10 dfage orfath dfeduc dgestat csex dbrwt dplural omaps fmaps clingest ///
anemia cardiac lung diabetes herpes chyper phyper pre4000 preterm alcohol drink5 wgain mwhite mblack mothrace 

teffects psmatch (dbrwt) (tobacco $pscore), gen(match)  //is this what he's looking for for part a or part d

* b. propensity score for treated and untreated 
*predict ps0 ps1, ps //store propensity scores
*predict y0 y1, po  //store potential outcomes

//what are we looking for here?
	
	teffects overlap
	//graph saved, shows overlap pattern
	
* c. balance 
tebalance summarize //what is "sufficient" balance
	
* d. Estimation using propensity score matching 

teffects psmatch (dbrwt) (tobacco $pscore), gen(attmatch) atet

* e: Estimation using propensity score reweighting

teffects ipw (dbrwt) (tobacco $pscore)
teffects ipw (dbrwt) (tobacco $pscore), atet

/*************************
Part 5
**************************/

*a: Mixed methods ATE and ATT estimtion
teffects aipw (dbrwt) (tobacco $pscore)
teffects aipw (dbrwt) (tobacco $pscore), atet

*b: Double selection LASSO (linear)
dsregress dbrwt tobacco, controls($covars)


log off
