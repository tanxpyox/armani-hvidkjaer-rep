*****  Stata do-file to replicate the analysis in:
*****  Identifying Ideologues: A Global Dataset on Political Leaders, 1945-2020.
*****  Author: Bastian Herre, Our World in Data & Oxford Martin School
*****  April 21, 2022


version 14

clear all
set more off
set varabbrev off


* Set your own working directories here to run the file:
cd "/Users/bastianherre/Dropbox/Data/Identifying Ideologues"


** Install needed packages (if needed):
* ssc install spineplot
* ssc install shp2dta
* ssc install spmap



use identifying_ideologues.dta



*** Figure 1: Create spine plot of ideologies across regime types:

generate hog_ideology_num_new=hog_ideology_num_redux
recode hog_ideology_num_new (0=2) (1=0) (2=1)
label variable hog_ideology_num_new "Ideology of head of government"
label define hog_ideology_num_new 0 "leftist" 1 "centrist" 2 "rightist" 3 "missing"
label values hog_ideology_num_new hog_ideology_num_new

tab democracy hog_ideology_num_new, row

by democracy hog_ideology_num_new, sort: gen N=_N
spineplot democracy hog_ideology_num_new, text(N, mlabcolor(white)) legend(off) xlabel("", noticks) ylabel(0.325 "dictatorship" 0.825 "democracy", noticks axis(2)) ytitle("") xtitle("") bar1(color(gs3)) bar2(color(gs7))
drop N
graph export Figure_1.png, width(600) replace

tab democracy leader_ideology_num_redux, row


** Comparing heads of government with leaders data:

use identifying_ideologues.dta, clear

tab match_hog_leader, m

tab hog_ideology leader_ideology if match_hog_leader=="no" & hog_ideology!="no information" & leader_ideology!="no information", V
dis 1-(75+926+4+855)/2315



*** Table 1: Chief executives' ideologies across datasets

use identifying_ideologues.dta, clear


** Compare own with Brambor et al. (2017) data:
tab hog_ideology_bls hog_ideology if match_hog_hog_bls=="yes" & hog_ideology_bls != "no data" & hog_ideology != "no information"
dis (379+728+992)/2201
* Note: 95% matching head-of-government years.


** Compare own with Manzano's (2017) data:
tab leader_ideology_m leader_ideology if match_leader_leader_m=="yes"
dis (9+1969+1567)/3781
* Note: about 94% matching leader years.


** Compare own with DPI's (Cruz et al. 2021) chief executive data:
generate hog_leader_ideology_dpi = hog_ideology if system==1 | system==2
replace hog_leader_ideology_dpi = leader_ideology if system==0

tab execrlc_dpi hog_leader_ideology_dpi if hog_leader_ideology_dpi != "no information" & hog_leader_ideology_dpi != "none" & hog_leader_ideology_dpi != "not applicable" & execrlc_dpi != "no data" & execrlc_dpi != "no information" & execrlc_dpi != "not applicable"
dis (165+2081+1114)/4160
* Note: about 81% matching chief executive-years.

* Compare own with DPI's (Cruz et al. 2021) largest government party data:
tab gov1rlc_dpi hog_leader_ideology_dpi if hog_leader_ideology_dpi != "no information" & hog_leader_ideology_dpi != "none" & hog_leader_ideology_dpi != "not applicable" & gov1rlc_dpi != -999 & gov1rlc_dpi != 0
dis (151+2032+1089)/4221
* Note: about 78% matching years.

* Compare own with DPI's (Cruz et al. 2021) second-largest government party data:
tab gov2rlc_dpi hog_leader_ideology_dpi if hog_leader_ideology_dpi != "no information" & hog_leader_ideology_dpi != "none" & hog_leader_ideology_dpi != "not applicable" & gov2rlc_dpi != -999 & gov2rlc_dpi != 0
dis (22+325+413)/1640
* Note: about 46.3% matching years.

* Compare own with DPI's (Cruz et al. 2021) third-largest government party data:
tab gov3rlc_dpi hog_leader_ideology_dpi if hog_leader_ideology_dpi != "no information" & hog_leader_ideology_dpi != "none" & hog_leader_ideology_dpi != "not applicable" & gov3rlc_dpi != -999 & gov3rlc_dpi != 0
dis (19+185+224)/911
* Note: about 47% matching years.


** Compare own with DPI's (Cruz et al. 2021) government-parties data, based on the coding rules of Ha (2012):

* Calculate number of covered government parties:
generate gov_party_n = .
replace gov_party_n = 0 if gov1rlc_dpi == -999
replace gov_party_n = 1 if gov1rlc_dpi != -999 & gov2rlc_dpi == -999
replace gov_party_n = 2 if gov1rlc_dpi != -999 & gov2rlc_dpi != -999 & gov3rlc_dpi == -999
replace gov_party_n = 3 if gov1rlc_dpi != -999 & gov2rlc_dpi != -999 & gov3rlc_dpi != -999
tab gov_party_n

* Calculate number of covered government parties with no ideology information:
generate gov_party_n_noinfo = .
replace gov_party_n_noinfo = 0 if gov1rlc_dpi != 0 & gov2rlc_dpi != 0 & gov3rlc_dpi != 0
replace gov_party_n_noinfo = gov_party_n_noinfo + 1 if gov1rlc_dpi == 0
replace gov_party_n_noinfo = gov_party_n_noinfo + 1 if gov2rlc_dpi == 0
replace gov_party_n_noinfo = gov_party_n_noinfo + 1 if gov3rlc_dpi == 0
tab gov_party_n_noinfo

* Calculate number of covered government parties with ideology information:
generate gov_party_n_info = gov_party_n - gov_party_n_noinfo

* Generate variable identifying government's overall ideology:
generate govrlc_dpi = .

* If there are no government parties, use chief executive's ideology as government ideology:
replace govrlc_dpi = -1 if gov_party_n == 0 & execrlc_dpi == "rightist"
replace govrlc_dpi = 0 if gov_party_n == 0 & execrlc_dpi == "centrist"
replace govrlc_dpi = 1 if gov_party_n == 0 & execrlc_dpi == "leftist"

* If there is a largest government party, start with their ideology as government ideology:
replace govrlc_dpi = -1 if gov1rlc_dpi == 1
replace govrlc_dpi = 0 if gov1rlc_dpi == 2
replace govrlc_dpi = 1 if gov1rlc_dpi == 3

* If there is a second-largest government party, add (or subtract) its information:
replace govrlc_dpi = -1 if gov1rlc_dpi == 0 & gov2rlc_dpi == 1
replace govrlc_dpi = 0 if gov1rlc_dpi == 0 & gov2rlc_dpi == 2
replace govrlc_dpi = 1 if gov1rlc_dpi == 0 & gov2rlc_dpi == 3
replace govrlc_dpi = govrlc_dpi-1 if gov2rlc_dpi == 1
replace govrlc_dpi = govrlc_dpi if gov2rlc_dpi == 2
replace govrlc_dpi = govrlc_dpi+1 if gov2rlc_dpi == 3

* If there is a third-largest government party, add (or subtract) its information:
replace govrlc_dpi = -1 if gov1rlc_dpi == 0 & gov2rlc_dpi == 0 & gov3rlc_dpi == 1
replace govrlc_dpi = 0 if gov1rlc_dpi == 0 & gov2rlc_dpi == 0 & gov3rlc_dpi == 2
replace govrlc_dpi = 1 if gov1rlc_dpi == 0 & gov2rlc_dpi == 0 & gov3rlc_dpi == 3
replace govrlc_dpi = govrlc_dpi-1 if gov3rlc_dpi == 1
replace govrlc_dpi = govrlc_dpi if gov3rlc_dpi == 2
replace govrlc_dpi = govrlc_dpi+1 if gov3rlc_dpi == 3

* Standardize by the number of government parties with an ideology:
replace govrlc_dpi = govrlc_dpi / gov_party_n_info

* Collapse intermediate categories:
replace govrlc_dpi = 1 if govrlc_dpi >= 0.5 & govrlc_dpi <= 1
replace govrlc_dpi = 0 if govrlc_dpi >= 0 & govrlc_dpi < 0.5
replace govrlc_dpi = 0 if govrlc_dpi > -0.5 & govrlc_dpi <= 0
replace govrlc_dpi = -1 if govrlc_dpi >= -1 & govrlc_dpi <= -0.5
label define govrlc_dpi -1 "rightist" 0 "centrist" 1 "leftist"
label values govrlc_dpi govrlc_dpi
tab govrlc_dpi

tab govrlc_dpi hog_leader_ideology_dpi if hog_leader_ideology_dpi != "no information" & hog_leader_ideology_dpi != "none" & hog_leader_ideology_dpi != "not applicable"
dis (795+145+1616)/3526
* Note: about 72% matching years.


** Compare own with V-Party (Lührmann et al. 2020) data:
generate hog_party_lr_trich_vdem = "leftist" if hog_party_lr_ord_vdem=="Left" | hog_party_lr_ord_vdem=="Center-left" | hog_party_lr_ord_vdem=="Far-left"
replace hog_party_lr_trich_vdem = "centrist" if hog_party_lr_ord_vdem==" Center" | hog_party_lr_ord_vdem=="Center"
replace hog_party_lr_trich_vdem = "rightist" if hog_party_lr_ord_vdem=="Right" | hog_party_lr_ord_vdem=="Center-right" | hog_party_lr_ord_vdem=="Far-right"

tab hog_party_lr_trich_vdem hog_ideology if hog_ideology!="no information" & hog_ideology!="none" & hog_ideology!=" "
dis(423+3034+2339)/7557
* Note: about 77% matching head-of-government years; especially V-Party's centrist parties do not match.



*** Figure 2: Heads of government's ideologies per country, 1945-2020

use identifying_ideologues.dta, clear

* Summarize ideology per country:
collapse (sum) hog_left hog_center hog_right hog_noideo hog_noinfo, by(country_name)
generate total=hog_left+hog_center+hog_right+hog_noideo+hog_noinfo
generate hog_left_share=hog_left/total*100
generate hog_right_share=hog_right/total*100
save hog_ideo_country.dta, replace

* Load and format world map data:
shp2dta using worldmap.shp, database(worldmap19.dta) coordinates(worldcoord19.dta) genid(id) replace
use worldmap19.dta, clear
rename ADMIN country_name
replace country_name="Burma/Myanmar" if country_name=="Myanmar"
replace country_name="Czech Republic" if country_name=="Czechia"
replace country_name="Serbia" if country_name=="Republic of Serbia"
replace country_name="Eswatini" if country_name=="eSwatini"
replace country_name="North Macedonia" if country_name=="Macedonia"
replace country_name="Tanzania" if country_name=="United Republic of Tanzania"
replace country_name="Timor-Leste" if country_name=="East Timor"

* Merge summarized ideology per country with world map data:
merge 1:1 country_name using hog_ideo_country.dta

* Graph summarized left heads of governments per country:
spmap hog_left_share using worldcoord19.dta if _merge==3 & hog_left_share!=., id(id) fcolor(Greys) ocolor(black ..) osize(thin ..) clmethod(custom) clbreaks(0 25 50 75 100) legend(symy(*2) symx(*2) size(*2)) legorder(lohi) title("% years of leftist heads of government, 1945-2020" "")
graph save Figure_2_1.gph, replace

* Graph summarized right heads of governments per country:
spmap hog_right_share using worldcoord19.dta if _merge==3 & hog_right_share!=., id(id) fcolor(Greys) ocolor(black ..) osize(thin ..) clmethod(custom) clbreaks(0 25 50 75 100) legend(symy(*2) symx(*2) size(*2)) legorder(lohi) title("% years of rightist heads of government, 1945-2020" "")
graph save Figure_2_2.gph, replace

* Combine graphs:
graph combine Figure_2_1.gph Figure_2_2.gph, cols(1) imargin(2 5 0) iscale(*0.75)
graph export Figure_2.png, width(600) replace


* Figure 2 in color:

* Graph summarized left heads of governments per country:
spmap hog_left_share using worldcoord19.dta if _merge==3 & hog_left_share!=., id(id) fcolor(Oranges) ocolor(white ..) osize(thin ..) clmethod(custom) clbreaks(0 25 50 75 100) legend(symy(*2) symx(*2) size(*2)) legorder(lohi) title("% of years with leftist heads of government, 1945-2020" "")
graph save Figure_2_1_color.gph

* Graph summarized right heads of governments per country:
spmap hog_right_share using worldcoord19.dta if _merge==3 & hog_right_share!=., id(id) fcolor(Blues) ocolor(white ..) osize(thin ..) clmethod(custom) clbreaks(0 25 50 75 100) legend(symy(*2) symx(*2) size(*2)) legorder(lohi) title("% of years with rightist heads of government, 1945-2020" "")
graph save Figure_2_2_color.gph

* Combine graphs:
graph combine Figure_2_1_color.gph Figure_2_2_color.gph, cols(1) imargin(2 5 0) iscale(*0.75)
graph export Figure_2_color.png, width(600) replace


erase hog_ideo_country.dta
erase worldmap19.dta
erase worldcoord19.dta
erase Figure_2_1.gph
erase Figure_2_2.gph
erase Figure_2_1_color.gph
erase Figure_2_2_color.gph



** Figure 3: Heads of government's economic ideology per year, 1945-2020:

use identifying_ideologues.dta, clear

* Summarize ideology per year across regimes:
preserve
collapse (sum) hog_left hog_center hog_right hog_noideo hog_noinfo, by(year)
generate total=hog_left+hog_center+hog_right+hog_noideo+hog_noinfo
generate hog_left_share=hog_left/total*100
generate hog_center_share=hog_center/total*100
generate hog_right_share=hog_right/total*100
generate hog_no_share=(hog_noideo+hog_noinfo)/total*100
line hog_left_share hog_center_share hog_right_share hog_no_share year, legend(label(1 "leftist") label(2 "centrist") label(3 "rightist") label(4 "no ideology or no information") rows(1) pos(12) bmargin(zero)) xtitle("") xlabel(1950(10)2020) title("% of all regimes", size(medium)) lpattern(solid dot dash_dot dash) lcolor(black black black black) fysize(37) bgcolor(none)
graph save Figure_3_1.gph, replace

* In color:
line hog_left_share hog_center_share hog_right_share hog_no_share year, legend(label(1 "leftist") label(2 "centrist") label(3 "rightist") label(4 "no ideology or no information") rows(1) pos(12) bmargin(zero)) xtitle("") xlabel(1950(10)2020) title("% of all regimes", size(medium)) lcolor(orange green midblue black) fysize(37) bgcolor(none)
graph save Figure_3_1_color.gph, replace

restore

* Summarize ideology per year across democracies:
preserve
keep if democracy==1
collapse (sum) hog_left hog_center hog_right hog_noideo hog_noinfo, by(year)
generate total=hog_left+hog_center+hog_right+hog_noideo+hog_noinfo
generate hog_left_share=hog_left/total*100
generate hog_center_share=hog_center/total*100
generate hog_right_share=hog_right/total*100
generate hog_no_share=(hog_noideo+hog_noinfo)/total*100
line hog_left_share hog_center_share hog_right_share hog_no_share year, legend(off) xtitle("") xlabel(1950(10)2020) ylabel(0(20)60) title("% of democracies", size(medium)) lpattern(solid dot dash_dot dash) lcolor(black black black black) fysize(31.5) bgcolor(none)
graph save Figure_3_2.gph, replace

* In color:
line hog_left_share hog_center_share hog_right_share hog_no_share year, legend(off) xtitle("") xlabel(1950(10)2020) ylabel(0(20)60) title("% of democracies", size(medium)) lcolor(orange green midblue black) fysize(31.5) bgcolor(none)
graph save Figure_3_2_color.gph, replace

restore

* Summarize ideology per year across dictatorships:
preserve
keep if democracy==0
collapse (sum) hog_left hog_center hog_right hog_noideo hog_noinfo, by(year)
generate total=hog_left+hog_center+hog_right+hog_noideo+hog_noinfo
generate hog_left_share=hog_left/total*100
generate hog_center_share=hog_center/total*100
generate hog_right_share=hog_right/total*100
generate hog_no_share=(hog_noideo+hog_noinfo)/total*100
line hog_left_share hog_center_share hog_right_share hog_no_share year, legend(off) xtitle("") xlabel(1950(10)2020) title("% of dictatorships", size(medium)) lpattern(solid dot dash_dot dash) lcolor(black black black black) fysize(31.5) bgcolor(none)
graph save Figure_3_3.gph, replace

* In color:
line hog_left_share hog_center_share hog_right_share hog_no_share year, legend(off) xtitle("") xlabel(1950(10)2020) title("% of dictatorships", size(medium)) lcolor(orange green midblue black) fysize(31.5) bgcolor(none)
graph save Figure_3_3_color.gph, replace

restore

* Combine graphs of ideology over time and regimes:
graph combine Figure_3_1.gph Figure_3_2.gph Figure_3_3.gph, cols(1) imargin(2 2 2 0)
graph export Figure_3.png, width(600) replace
graph combine Figure_3_1_color.gph Figure_3_2_color.gph Figure_3_3_color.gph, cols(1) imargin(2 2 2 0)
graph export Figure_3_color.png, width(600) replace

erase Figure_3_1.gph
erase Figure_3_2.gph
erase Figure_3_3.gph
erase Figure_3_1_color.gph
erase Figure_3_2_color.gph
erase Figure_3_3_color.gph



** Table 2: Ideology and regime changes, 1945-2020:

use identifying_ideologues.dta, clear

drop if leader==""

* Create ideology change variable:
generate ideology_change=0 if leader_ideology==leader_ideology[_n-1] & leader_ideology!="no information" & country_name==country_name[_n-1]
replace ideology_change=1 if leader_ideology!=leader_ideology[_n-1] & leader_ideology!="no information" & leader_ideology[_n-1]!="no information" & country_name==country_name[_n-1]
tab ideology_change leader_ideology,m

* Create regime change variable:
generate regime_change=0 if democracy==0 & democracy[_n-1]==0 & country_name==country_name[_n-1]
replace regime_change=0 if democracy==1 & democracy[_n-1]==1 & country_name==country_name[_n-1]
replace regime_change=1 if democracy==1 & democracy[_n-1]==0 & country_name==country_name[_n-1]
replace regime_change=1 if democracy==0 & democracy[_n-1]==1 & country_name==country_name[_n-1]
tab regime_change democracy, m

* Compare ideology with regime changes:
tab ideology_change regime_change
tab democracy if ideology_change==1 & regime_change==0



*** Supplementary Materials Table A1: Countries and years covered for heads of government

* Identify which countries and years are not covered by Regimes of the World: 

use identifying_ideologues.dta, clear
preserve

* Calculate number of countries covered in total:
by country_name, sort: generate number_countries = _n == 1

* Keep observations of interest:
keep if hog_ideology != ""

encode country_name, generate(country_number)
tsset country_number year

keep country_number year

generate group = _n if l.year > year - 1
replace group = l.group if group == .

bysort group: generate spell = _N - 1
bysort group: egen year_end = max(year)
keep if year_end == year

generate year_start = year_end - spell
egen time = concat(year_start year_end), punct(-)

drop group year spell year_start year_end

list country_number time

restore



*** Supplementary Materials Table A2: Countries and years covered for leaders

use identifying_ideologues.dta, clear
preserve

* Keep observations of interest:
keep if leader_ideology != ""

encode country_name, generate(country_number)
tsset country_number year

keep country_number year

generate group = _n if l.year > year - 1
replace group = l.group if group == .

bysort group: generate spell = _N - 1
bysort group: egen year_end = max(year)
keep if year_end == year

generate year_start = year_end - spell
egen time = concat(year_start year_end), punct(-)

drop group year spell year_start year_end

list country_number time

restore



exit
