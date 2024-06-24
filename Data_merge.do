******************************************
************* Data Merge Code ************
******************************************

cd "C:\Users\A\OneDrive\바탕 화면\Data Analysis Program\2024_Causal_Inference\Trading_Income_Segregation"

**** Czone unit ****

use total_cbp_cz, clear

egen sum_all_in_ind = sum(emp_czone), by (sic_mat year)
egen sum_all_in_cz = sum(emp_czone), by (czone year)

egen sum_all_in_ind_1980 = sum(emp_czone_1980), by (sic_mat year)
egen sum_all_in_cz_1980 = sum(emp_czone_1980), by (czone year)

gen share_t = emp_czone/sum_all_in_ind
gen share_1980 = emp_czone_1980/sum_all_in_ind_1980

replace share_1980=0 if share_1980==.

save share_data_temporal, replace

**** Merge with income segregate ****
use trade_data_1990_2012, clear

replace values = values * (11.125) if year~=2012 // 2007 to 2012

replace year=1990 if year==1991

merge n:n year sic_mat using share_data_temporal

gen shock_per_ind_cz = values*share_t/sum_all_in_cz
gen shock_per_ind_cz_1980 = values*share_1980/sum_all_in_cz_1980

egen shock_per_cz = sum(shock_per_ind_cz), by(year czone)
egen shock_per_cz_1980 = sum(shock_per_ind_cz_1980), by(year czone)

duplicates drop year importer czone, force

keep year importer czone shock_per_cz shock_per_cz_1980

gen total_shock = shock_per_cz
replace total_shock = shock_per_cz_1980 if importer=="OTH"

save merge_share_trade, replace

* test regression
reg shock_per_cz shock_per_cz_1980

* clearing
use merge_share_trade, clear

keep year importer czone total_shock

drop if importer == ""

reshape wide total_shock, i(year czone) j(importer) string

drop if czone==. | total_shockOTH==. | total_shockUSA ==.

**** Merge with income segregate ****
merge m:m year czone using total_segr_index

drop if czone==. | total_shockOTH==. | total_shockUSA ==.

save total_merge_data, replace

reg segregation total_shockOTH

reg segregation total_shockUSA

// ivreg mygini (total_shockUSA = total_shockOTH)
//
// drop if year==1990

replace total_shockOTH = total_shockOTH + 1
replace total_shockUSA = total_shockUSA + 1
bys czone : gen num=_N
keep if num==3
save total_merge_data, replace

