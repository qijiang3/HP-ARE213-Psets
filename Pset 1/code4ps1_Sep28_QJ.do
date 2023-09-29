** Problem set 1
** Qi Jiang, Sep 24, 2023


cd "/Users/qijiang/Desktop/Coursework/05 fall 2023/3 ARE213/PSet1"
use "pset1.dta", clear



*-------------------------- Question 1 ----------------------------------------*

** Questoin 1a: fix missing values 
	
	* check the variables
	foreach var of varlist cardiac - wgain{
		tab `var', m
	}

	* cleanning the variables: replace the unknown or not stated observations as missing values

	foreach var of varlist cardiac - preterm{
		replace `var' = . if `var' > 7 
	}

	replace tobacco = . if tobacco == 9
	replace cigar = . if cigar == 99
	replace cigar6 = . if cigar6 == 6
	replace alcohol = . if alcohol == 9
	replace drink = . if drink == 99
	replace drink5 = . if drink5 == 99
	replace wgain = . if wgain == 99
	
	
** Question 1b: recode
	
	*drop stresfip birmon weekday (they could be used as fixed effect factors if not dropped)
	drop stresfip birmon weekday 
	
	*check variables before coding
	foreach var of varlist rectype - csex dplural - wgain{
		tab `var', m
	}
	
	*recode the two-value variables into dummy 
	recode rectype pldel3 dmar csex anemia cardiac lung diabetes herpes chyper phyper pre4000 preterm tobacco alcohol (2=0)
	
	*recode mrace3 as a set of indicator variables
	gen mwhite = 0
	replace mwhite = 1 if mrace3==1
	
	gen mblack = 0
	replace mblack = 1 if mrace3==3
	
	gen mothrace = 0
	replace mothrace = 1 if mrace3==2
	
	*recode ormoth and orfath as dummy, where 1=any Hispanic and 0=not Hispanic
	recode ormoth (2=0)(3=0)(4=0)(5=0)
	recode orfath (2=0)(3=0)(4=0)(5=0)

	*check variables after coding
	foreach var of varlist rectype - csex dplural - wgain{
		tab `var', m
	}

	
	
** Question 1c: drop missing value

	*check if the missings are at random
	mcartest rectype-wgain // p value = 0.0000, indicating that the data is NOT MCAR
	
	mcartest tobacco wgain $demo $healthcare $child $healthstatus // p value = 0.0000, indicating that the data used in our analysis is NOT MCAR either

	* drop all missing values
	foreach var of varlist *{
		drop if `var' == .
	}
	
	count //116,398 (not 114,610????)
	
	
** Question 1d: Table 1 for the discriptive analysis
   
   local demo dmage ormoth mwhite mblack mothrace dmeduc dmar 
   local healthcare adequacy monpre nprevist 
   local child isllb10 csex dplural 
   local healthstatus anemia cardiac lung diabetes herpes chyper phyper
   
   outreg2 using Table1.doc, replace sum(log) keep(tobacco wgain $demo $healthcare $child $healthstatus)

   
*-------------------------- Question 2 ----------------------------------------*

** Question 2a: compute the mean difference
	ttest dbrwt, by(tobacco)

** Question 2b: selection on obserbables
	//no codes necessary

	
	
	
*-------------------------- Question 3 ----------------------------------------*

** Question 3a: 

   egen wgain_std = std(wgain)
   egen dbrwt_std = std(dbrwt)
   
	eststo clear 
	regress dbrwt_std tobacco $demo $healthcare $child $healthstatus
	eststo lbw_3a
	
	outreg2 [lbw_3a] using "Table_3a.xls", tstat eform excel dec(3) noaster  ///
			 label title ("sensitive analysis on the OLS of tobacco use on birth weight") pde(4) replace

** Question 3b:

	eststo clear 
	regress dbrwt_std tobacco $demo $healthcare $child $healthstatus
	eststo lbw_3a

	regress dbrwt_std tobacco $demo $healthcare $child
	eststo lbw_3b1
	
	regress dbrwt_std tobacco $demo $healthcare 
	eststo lbw_3b2

	regress dbrwt_std tobacco $demo
	eststo lbw_3b3

	regress dbrwt_std tobacco
	eststo lbw_3b4



	outreg2 [lbw_3a lbw_3b1 lbw_3b2 lbw_3b3 lbw_3b4] using "Table_3b.xls", tstat eform excel dec(3) noaster  ///
			 label title ("sensitive analysis on the OLS of tobacco use on birth weight") pde(4) replace
    //the beta is stable yet the r_2 drops quickly


** Question 3c: use more flexible functional form (use treatment to interact each confounding variables)
	
	eststo clear 
	regress dbrwt_std tobacco $demo $healthcare $child $healthstatus tobacco#c.dmage tobacco#ormoth tobacco#mwhite tobacco#mblack tobacco#mothrace tobacco#c.dmeduc tobacco#dmar tobacco#adequacy tobacco#c.monpre tobacco#c.nprevist tobacco#isllb10 tobacco#csex tobacco#dplural tobacco#anemia tobacco#cardiac tobacco#lung tobacco#diabetes tobacco#herpes tobacco#chyper tobacco#phyper
	eststo lbw_3c
	
	outreg2 [lbw_3c] using "Table_3c.xls", tstat eform excel dec(3) noaster  ///
			 label title ("Sensitive analysis") pde(4) replace


** Question 3d: add bad controls -- mediators or colliders 
	
	eststo clear 
	regress dbrwt_std tobacco dgestat $demo $healthcare $child $healthstatus
	eststo lbw_3d
	
	outreg2 [lbw_3d] using "Table_3c.xls", tstat eform excel dec(3) noaster  ///
			 label title ("Adding a mediator to the regression") pde(4) replace



** Question 3e:

	//not super clear what I should do 

*-------------------------- Question 4 ----------------------------------------*

** Question 4a:
	
	*psmatch2 tobacco $mother_demo $mother_risk $child, ate radius caliper(0.01) out(dbrwt_std)
	
	
** Question 4b:	
	graph twoway (kdensity _pscore if _treat==0)(kdensity _pscore if _treat==1)

	
** Question 4c: 
	pstest $mother_demo $mother_risk $child, both saving(test.csv)	



** Question 4e:
	
	*ATE estimation
	eststo clear
	eststo: reg `var' depression_yes $home $baby, vce (cluster hhid_village)
	}
	esttab using parenting_and_depression_de_20181004.csv, replace b(3) se(3) star( * 0.10 ** 0.05 *** 0.01)

	*ATT estimation

	
*-------------------------- Question 5 ----------------------------------------*

** Question 5a:
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	
	