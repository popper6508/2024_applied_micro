******************************************
*********** Data Clearing Code ***********
******************************************

*********** Income Segregation ***********
cd "C:\Users\A\OneDrive\바탕 화면\Data Analysis Program\2024_Causal_Inference\Trading_Income_Segregation\Data_Clearing_Incomeseg"

use segr_cz_1990, clear

append using segr_cz_2000
append using segr_cz_2012

save total_segr_index, replace

******** CBP into Commuting Zone *********
cd "C:\Users\A\OneDrive\바탕 화면\Data Analysis Program\2024_Causal_Inference\Trading_Income_Segregation\Data_Clearing_Share_Making"

import delimited "efsy_panel_native.csv", clear

keep if year == 1980 | year == 1990 | year == 2000 | year == 2012

gen ctycode = fipstate*1000 + fipscty

keep year emp ctycode naics sic

tostring naics, replace

merge n:n naics using SIC_NAICS_concordance

gen sic_mat = sic
replace sic_mat = SIC_code if sic == ""

keep year ctycode sic_mat emp
drop if ctycode==.

save sharedata_1980_2012, replace

//// 1980 segregate
keep if year == 1980

rename (emp year) (emp_1980 year_1980)

save sharedata_1980, replace

//// segregate others
use sharedata_1980_2012, clear
keep if year ~= 1980

save sharedata_1990_2012, replace

//// merge two of those
merge m:m ctycode sic_mat using sharedata_1980

drop year_1980
replace emp_1980 = 0 if emp_1980==.
replace emp = 0 if emp==.

drop if year == .
drop if sic_mat==""
drop emp

save panel_data_fin_1990_2012, replace

*** county to commuting zone
rename ctycode cty_fips

merge m:m cty_fips using cw_cty_czone

drop if czone == .
drop if emp_1980 == .

egen emp_czone = total(emp), by (czone sic_mat year)
egen emp_czone_1980 = total(emp_1980), by (czone sic_mat year)

duplicates drop czone year sic_mat, force

keep year emp sic_mat czone emp_czone emp_czone_1980

save data_cbp_cz, replace

*********** Import penetration and IV ***********
cd "C:\Users\A\OneDrive\바탕 화면\Data Analysis Program\2024_Causal_Inference\Trading_Income_Segregation\Data_Clearing_Industry_Making"

*** china_us_data 2012
import delimited "China_US_Trade_Data.csv", clear

keep refyear period reporteriso flowcode partneriso cmdcode primaryvalue

keep if flowcode == "M"

rename (cmdcode period) (commodity year)

tostring commodity, replace

keep if year == 2012

merge m:m commodity year using hs_sic_imports

keep year reporteriso flowcode partneriso commodity primaryvalue sic

drop if sic == "" | sic == "."
drop if primaryvalue==.

egen import_value = total(primaryvalue), by (year sic)

rename sic sic_mat
drop commodity flowcode
rename (reporteriso partneriso) (importer exporter)

duplicates drop year sic_mat, force
drop primaryvalue

save china_us_trade_2012, replace

*** china_other_data
import delimited "China_Other_Trade_Data.csv", clear

keep if flowcode == "X"

keep refyear period reporteriso flowcode partneriso cmdcode primaryvalue

rename (cmdcode period) (commodity year)

tostring commodity, replace

keep if year == 2012

merge m:m commodity year using hs_sic_imports

keep year reporteriso flowcode partneriso commodity primaryvalue sic

drop if sic == "" | sic == "."
drop if primaryvalue==.

egen export_value = total(primaryvalue), by (year sic)

rename sic sic_mat
drop commodity flowcode
rename (reporteriso partneriso) (exporter importer)

duplicates drop year sic_mat, force
drop primaryvalue

replace importer = "OTH"

rename export_value values

save china_other_trade_2012, replace

**** trade data merge
use sic_trade_data_1990_2000, clear

tostring sic_mat, replace

append using china_other_trade_2012
append using china_us_trade_2012

save trade_data_1990_2012, replace


