# Variable Discrepancies: Manuscript vs. Analysis Code

I cross-checked the "Data and variables" section of `taste-change-mar08.docx` against the actual Stata scripts (`dataproc-80-85-90.do` and `analysis-85-90.do`) and our R translation. There are a few significant discrepancies between what the manuscript *says* it analyzes and what the code *actually* does. 

### 1. Cultural Taste Change Models (Logistic Regressions)
**Manuscript Claim:**
The text states that because of wording changes across waves (e.g., for going to the movies), it only uses **four** specific activities for the taste loss analysis that do not involve leaving the home: 
1. Listening to music (`music`)
2. Reading books of fiction (`books`)
3. Reading the newspaper (`paper`)
4. Following a sports team (`sports`)

**Code Reality:**
The `analysis-85-90.do` loop runs the discrete-time logistic regressions on **nine** cultural items: `music`, `movie`, `sports`, `paper`, `books`, `spevent`, `videos`, `hobby`, `mags`. 
**Action Needed:** Should we restrict the R script to only output the models for those 4 items (as the manuscript claims), or do you want to keep all 9 and update the text in the manuscript to reflect this?

### 2. Cultural Taste Breadth Scale (`numcult`)
**Manuscript Claim:**
The text states that the `numcult` additive index (used to predict network stability) consists of **9** items: music, movies, theatric performance (`play`), sports event (`spevent`), videos, hobby, magazines (`mags`), sports team (`sports`), and books (`books`). (Note: The numbering in the manuscript has a typo, jumping from 4 to 45).

**Code Reality:**
The code generates the `numcult` variable using **10** items: `music movie play sports paper books spevent videos hobby mags`. The text accidentally left out reading the newspaper (`paper`).
**Action Needed:** This is likely just a typo/omission in the manuscript text. You should add "reading the newspaper" to the list of items comprising the breadth index in the manuscript.

### 3. Network Turnover Indicators & Demographics
**Match:**
The manuscript successfully matches the code here! It lists 7 turnover indicators: interaction with friends (`chngfriends`), voluntary memberships (`chorgs4`), education (`chngeduc`), work status (`chngwrkstat`), location (`chngareanam`), marital status (`chngmarital`), and child rearing (`chngchildre`). These align perfectly with the `demchang` variables used in the regression. It also matches the demographics (age, education, income, gender, race/ethnicity).

---

If you'd like, I can immediately restrict the R analysis script to only output the 4 "at-home" items for the taste loss models, which would perfectly align the code with the manuscript text!
