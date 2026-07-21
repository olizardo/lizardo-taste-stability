# Data Analysis Workflow: Review & Recommendations

I have reviewed the main data analysis workflow porting the Stata code for the **Project Canada Survey** (`dataproc-80-85-90.do` and `analysis-85-90.do`) into R. 

The data processing logic successfully translates the data cleaning, re-coding, and index building (like `numcult` and `numsocmems`). However, there are a few important statistical adjustments and improvements required to fully align the R pipeline with the manuscript's described methodology.

### 1. Implement the Instrumental Variables (IV) Random Effects Model
- **Current State:** The R script (`R/pcs-analysis.R`) estimates a standard Random Effects panel model using `lme4::lmer()`. 
- **Recommendation:** The manuscript specifically details an "instrumental variables random effects model" using 1980 cultural tastes to instrument for 1985 and 1990 cultural taste breadth (to address simultaneity bias). We need to replace `lmer` with the `plm` package, which supports panel IV regression (the equivalent of Stata's `xtivreg`).
  - *Example:* `plm(friends ~ numcult + female + educ | music2 + movie2 + female + educ, data = pdata, model = "random")`

### 2. Cluster-Robust Standard Errors for the Logit Models
- **Current State:** The R script uses standard `glm()` for the taste change logistic regressions.
- **Recommendation:** In the Stata script, the logit models were estimated with `cluster(id)` to account for within-person correlation. We can easily replicate this in R using the `modelsummary` package by passing the `vcov = ~id` argument, which will compute the clustered sandwich estimators seamlessly.

### 3. True Person-Period Data Structure for Discrete-Time Survival
- **Current State:** The taste change indicator (`chng_music`, etc.) is calculated in wide format, reducing the data to a cross-sectional logit.
- **Recommendation:** The manuscript characterizes these as "discrete time event history models" over multiple periods. To fully replicate Stata's `reshape long` approach for the logistic regressions, we should explicitly pivot the data into person-periods (waves 3 and 4) where the event indicator is 0 in the first period and 1 (if a change occurred) in the second period, running a pooled logit. 

### 4. Code Efficiency & Tidyverse Modernization
- **Current State:** The port uses standard loops (`for (cult in cultlist)`) to fit the models.
- **Recommendation:** We can embrace a more "tidy" functional programming approach using `purrr::map()` and `broom` to estimate all 9 cultural models simultaneously and extract their coefficients into a single, clean summary dataframe, which is much easier to manipulate for plotting than a list of raw model objects.

---

**Next Steps:** I can update `R/pcs-analysis.R` to incorporate the IV Random Effects model via `plm`, apply the clustered standard errors, and refactor the discrete-time survival setup. Let me know if you would like me to implement these statistical corrections!

### 5. Methodological Modernizations (Moving Beyond 2008 Practices)
Since the original manuscript was drafted, several methodological standards in panel data analysis have evolved. Here are areas where the original approach relies on methods that are now considered slightly obsolete or suboptimal, along with modern alternatives:

* **Random Effects vs. Fixed Effects (Within-Between Models):**
  * **Obsolete Approach:** The manuscript relies heavily on Random Effects (RE) models (and IV-RE). In modern sociology (and econometrics), standard RE models are often critiqued because they assume that time-invariant unobserved heterogeneity is strictly uncorrelated with the predictors (the "random effects assumption"), which is rarely true in observational network data.
  * **Modern Alternative:** We should estimate **Fixed Effects (FE)** models (`model = "within"` in `plm`) to strictly control for all time-invariant individual traits. If you need to estimate the effects of time-invariant variables (like gender/race), you can use a **Mundlak/Hybrid model** (also known as a Within-Between model using `lme4`). This involves centering the time-varying predictors by their person-means and including both the centered variables and the person-means in a mixed model. This provides the causal rigor of Fixed Effects while retaining the flexibility of Random Effects.

* **Treating Ordinal Dependent Variables as Continuous:**
  * **Obsolete Approach:** Predicting network size (`friends`) or number of organizational memberships (`numsocmems`) using OLS-based panel models (like `xtreg` or `plm` with a continuous outcome assumption) can yield predictions outside logical bounds (e.g., negative friends) and ignores the count/ordinal nature of the data.
  * **Modern Alternative:** We should use **Panel Poisson or Negative Binomial regression** for count data (e.g., `pglm` or `glmer` with `family = poisson`). For ordinal categorical variables, **Mixed-effects Ordered Logit** (via the `ordinal` package's `clmm` function) is the standard.

* **Dichotomizing Continuous or Ordinal Taste Variables:**
  * **Obsolete Approach:** The original script collapses 4- or 5-point Likert scales of cultural consumption into binary indicators of "taste change" (changed vs. did not change). This throws away valuable variance (e.g., distinguishing a massive drop from "Very Often" to "Never" versus a minor drop from "Very Often" to "Sometimes").
  * **Modern Alternative:** A **Cross-Lagged Panel Model (CLPM)** or **Dynamic Panel Model (Arellano-Bond)** would allow you to model the *levels* of cultural taste continuously over time, predicting Taste at $T_{2}$ as a function of Taste at $T_{1}$ and Network Changes between $T_{1}$ and $T_{2}$. 

* **Additive Indices vs. Latent Variables:**
  * **Obsolete Approach:** Creating `numcult` by simply counting the number of activities where participation is < 3 assumes all cultural activities weight equally on the underlying construct of "cultural breadth." (I see commented-out Stata code for polychoric PCA, suggesting you explored this!).
  * **Modern Alternative:** Use **Item Response Theory (IRT)** or **Confirmatory Factor Analysis (CFA)** via the `lavaan` package to construct a properly weighted latent variable for cultural breadth. `lavaan` also easily handles longitudinal measurement invariance, ensuring that "cultural breadth" means the same thing in 1980 as it does in 1990.
