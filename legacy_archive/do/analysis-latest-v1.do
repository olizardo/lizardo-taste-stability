use "C:\Users\olizardo\Google Drive\lizardo-etal-cultural-matching\tastesnet.dta",clear
foreach x of varlist nmatch* emotionloving emotionsignificant close duration parcoll ego_woman eth_black eth_white eth_asia eth_hisp {
	quietly {
		sum `x'
		replace `x' = (`x' - r(mean)) / (2 * r(sd))
		}
	}
est drop _alln
qui xtmelogit decay nmatch_close numdk ///
numberalter nd_contact emotion*  close duration ///
c.time##c.time ///
if reltype == "Other family" | reltype == "Parent" | reltype == "Sibling", ///
|| egoid: || alterid:,lap var
est store mod1
qui xtmelogit decay nmatch_close numdk ///
numberalter nd_contact emotion* close duration ///
c.time##c.time ///
if reltype == "Friend", ///
|| egoid: || alterid:,lap var
est store mod2
qui rologit alterposition nmatch_close numdk ///
numberalter nd_contact emotion* close duration ///
c.time##c.time ///
if reltype == "Other family" | reltype == "Parent" | reltype == "Sibling", ///
group(egoid) reverse
est store mod3
qui rologit alterposition nmatch_close numdk ///
numberalter nd_contact emotion* close duration ///
c.time##c.time ///
if reltype == "Friend", ///
group(egoid) reverse
est store mod4



cd "C:\Users\olizardo\Google Drive\cultural-matching-ego-networks"
esttab mod* using regtab.rtf, ///
rtf replace drop(1b*) compress star(+ .1 * 0.05) ///
onecell cells(b(star fmt(3)) t(par fmt(2))) ///
varlabels( ///
nmatch_close "N. of Cultural Matches" /// 
numdk "N. of Cultural Unknowns" ///
numberalter "Reported Network Size" ///
nd_contact "On Campus Contact" ///
outdoor_str_match "Outdoors Match" ///
emotionloving "Loving Rel." ///
emotionsignificant "Significant Rel." ///
emotionexciting "Exciting Rel." ///
close "close" ///
duration "Duration" ///
time "Linear Time Trend" ///
c.time#c.time  "Quadratic Time Trend" ///
_cons "Constant")

/*
coefplot ///
(F) (Fc), bylabel(Friend)|| ///
(K, label(No Controls)) (Kc, label(Controls)), bylabel(Kin) || ///
(W) (Wc), bylabel(Weak Tie) ///
keep(num* *_match) scheme(s1color) ///
xline(0) ylab(,nogrid) ///
msym(diamond) msize(large) ///
byopts(xrescale row(1)) ysize(2) ///
coeflabels( ///
nmatch_open =  "N. of Matches (Open)" ///
music_str_match = "Music Match (Very Much)" ///
movies_str_match = "Movies Match (Very Much)"  ///
books_str_match = "Books Match (Very Much)"  ///
sports_str_match = "Sports Match (Very Much)" ///
games_str_match = "Games Match (Very Much)" ///
outdoor_str_match = "Outdoor Match (Very Much)" ///
) 


qui xtmelogit decay c.nmatch_open ///
*_str_*  ///
c.time##c.time numdk if reltype == "Friend",|| egoid: || alterid:,lap var
est store Fs
qui xtmelogit decay c.nmatch_open ///
music_wk_match movies_wk_match books_wk_match sports_wk_match games_wk_match outdoor_wk_match  ///
c.time##c.time numdk if reltype == "Friend",|| egoid: || alterid:,lap var
est store Fw
qui xtmelogit decay c.nmatch_open ///
books_neg_match sports_neg_match games_neg_match outdoor_neg_match  ///
c.time##c.time numdk if reltype == "Friend",|| egoid: || alterid:,lap v
est store Fn

coefplot ///
Fs Fw Fn, ///
keep(*_match) scheme(s1color) ///
xline(0) ylab(,nogrid) ///
msym(diamond) msize(large) ///
byopts(xrescale row(1)) ysize(2) */



