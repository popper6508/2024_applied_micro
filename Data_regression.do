******************************************
************* Regression Code ************
******************************************

cd "C:\Users\A\OneDrive\바탕 화면\Data Analysis Program\2024_Causal_Inference\Trading_Income_Segregation"

**** Summary Statistics
use trade_data_1990_2012, clear

keep if importer == "OTH"
egen sum_year = sum(values), by(year)
duplicates drop sum_year, force

twoway connected sum_year year ///
 legend(label(1 Trade Volume))

use trade_data_1990_2012, clear

keep if importer == "USA"
egen sum_year = sum(values), by(year)
duplicates drop sum_year, force

twoway connected sum_year year

use total_merge_data, clear

egen mean_year = mean(segregation), by(year)
duplicates drop year, force

gen sic_main = substr(sic_mat, 1,2)
bys year sic_main : egen ind_sum = sum(values)
duplicates drop ind_sum year, force
sort ind_sum
drop values sic_mat
keep if importer=="USA"

**** Regression Data
use total_merge_data, clear

// gen log_total_shockUS = log(total_shockUSA)
// gen log_total_shockOTH = log(total_shockOTH)

// bys czone : gen num = _N
// drop if num ~= 3

// drop _merge num

twoway ///
 (scatter segregation log_total_shockUS if year==1990) ///
 (scatter segregation log_total_shockUS if year==2000) ///
 (scatter segregation log_total_shockUS if year==2012), ///
 ytitle(Log Import Penetration) xtitle(Income Segregation) ///
 title("Income Segregation and Import Penetration") ///
 legend(label(1 1990) label(2 2000) label(3 2012))
 
 twoway ///
 (scatter log_total_shockUS log_total_shockOTH if year==1990) ///
 (scatter log_total_shockUS log_total_shockOTH if year==2000) ///
 (scatter log_total_shockUS log_total_shockOTH if year==2012), ///
 ytitle(Import Penetration to US) xtitle(Import Penetration to Eight Countries) ///
 title("Import Penetration") ///
 legend(label(1 1990) label(2 2000) label(3 2012))

// ivreg2 segregation (total_shockUSA = total_shockOTH) i.year, cluster(czone)

reg log_total_shockUS log_total_shockOTH
xtset year czone
xtreg log_total_shockUS log_total_shockOTH, fe

reg segregation log_total_shockUS
xtset year czone
xtreg segregation log_total_shockUS, fe

ivreg2 segregation (log_total_shockUS = log_total_shockOTH) i.year, cluster(czone)

ivreg2 segregation (log_total_shockUS = log_total_shockOTH)

drop if year==1990

// ivreg2 segregation (total_shockUSA = total_shockOTH) i.year, cluster(czone)

reg segregation log_total_shockUS
xtset year czone
xtreg segregation log_total_shockUS, fe

ivreg2 segregation (log_total_shockUS = log_total_shockOTH) i.year, cluster(czone)

ivreg2 segregation (log_total_shockUS = log_total_shockOTH)