# Modernized Data Analysis Workflow for PCS (1980-1985-1990)
library(dplyr)
library(tidyr)
library(lme4)
library(modelsummary)
library(lmtest)
library(sandwich)
library(lavaan)
library(here)

# 1. Load Processed Data
df <- readRDS(here("R", "pcs_processed.rds"))

# =====================================================================
# PART A: TASTE CHANGE (Discrete-Time Survival / Clustered Logit)
# =====================================================================
cultlist <- c("music", "movie", "play", "sports", "paper", "books", "spevent", "videos", "hobby", "mags")
controls <- c("agegrp3", "educ3", "income3", "married3", "childre3", "working3", "bigcity3", "female", "white")
demchang <- c("chngfriends", "chorgs4", "chngeduc", "chngmarital", "chngchildre", "chngwrkstat", "chngareanam")

models_change <- list()

# Calculate binary change and run clustered standard errors
for (cult in cultlist) {
  var3 <- paste0(cult, "3")
  var4 <- paste0(cult, "4")
  
  # Recode 4=3, 5=4 to match original Stata logic
  df[[var3]] <- ifelse(df[[var3]] == 4, 3, ifelse(df[[var3]] == 5, 4, df[[var3]]))
  df[[var4]] <- ifelse(df[[var4]] == 4, 3, ifelse(df[[var4]] == 5, 4, df[[var4]]))
  
  chng_var <- paste0("chng_", cult)
  df[[chng_var]] <- ifelse(!is.na(df[[var3]]) & !is.na(df[[var4]]), 
                           as.numeric(df[[var3]] != df[[var4]]), NA)
  
  # Standard Logit Model
  formula_str <- paste(chng_var, "~", paste(c(demchang, controls), collapse = " + "))
  mod <- glm(as.formula(formula_str), data = df, family = binomial(link = "logit"))
  
  # Store the model; modelsummary will handle clustering via vcov = ~id
  models_change[[cult]] <- mod
}

# =====================================================================
# PART B: NETWORK STABILITY (Mundlak Within-Between Poisson Models)
# =====================================================================
# Reshape to long format for panel estimation
df_long <- df %>%
  select(id, female, white, all_of(demchang), 
         friends3, friends4, numsocmems3, numsocmems4, 
         numcult3, numcult4, numcult2, 
         educ3, educ4, married3, married4, childre3, childre4, bigcity3, bigcity4) %>%
  pivot_longer(
    cols = matches("3$|4$"),
    names_to = c(".value", "wave"),
    names_pattern = "(.*)(3|4)$"
  ) %>%
  mutate(wave = as.numeric(wave)) %>%
  # Ensure haven_labelled types are coerced to numeric properly via unclass
  mutate(across(c(friends, numsocmems, numcult, educ, married, childre, bigcity), ~ as.numeric(haven::zap_labels(.))))

# Calculate Person-Means and Within-Person Centered Variables (Mundlak approach)
df_mundlak <- df_long %>%
  group_by(id) %>%
  mutate(
    # Person Means
    numcult_mean = mean(numcult, na.rm = TRUE),
    educ_mean = mean(educ, na.rm = TRUE),
    married_mean = mean(married, na.rm = TRUE),
    childre_mean = mean(childre, na.rm = TRUE),
    bigcity_mean = mean(bigcity, na.rm = TRUE),
    
    # Within-Person Centered (Deviations from the mean)
    numcult_within = numcult - numcult_mean,
    educ_within = educ - educ_mean,
    married_within = married - married_mean,
    childre_within = childre - childre_mean,
    bigcity_within = bigcity - bigcity_mean
  ) %>%
  ungroup()

# Model 1: Friends (Assuming friends is a count/ordinal metric, using Poisson)
# The "within" effects give us the causal Fixed Effect estimates.
# The "mean" effects test for between-person contextual differences.
mod_friends_mundlak <- glmer(
  friends ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + 
            numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + 
            female + white + as.factor(wave) + (1 | id), 
  data = df_mundlak, family = poisson, control = glmerControl(optimizer = "bobyqa")
)

# Model 2: Organizational Memberships (Poisson count model)
mod_mems_mundlak <- glmer(
  numsocmems ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + 
               numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + 
               female + white + as.factor(wave) + (1 | id), 
  data = df_mundlak, family = poisson, control = glmerControl(optimizer = "bobyqa")
)


# =====================================================================
# PART C: LATENT CULTURAL BREADTH (Confirmatory Factor Analysis)
# =====================================================================
# Instead of additive indices, we can construct a measurement model for 1985
cfa_model <- '
  # Latent Cultural Breadth 1985
  cult_breadth_85 =~ music3 + movie3 + sports3 + paper3 + books3 + spevent3 + videos3 + hobby3 + mags3
'
# Note: we use ordered = TRUE because these are Likert scales
fit_cfa <- cfa(cfa_model, data = df, ordered = c("music3", "movie3", "sports3", "paper3", "books3", "spevent3", "videos3", "hobby3", "mags3"))


# =====================================================================
# OUTPUT RESULTS
# =====================================================================
# 1. Taste Change Models (Clustered SEs)
modelsummary(
  models_change,
  vcov = ~id, # Computes cluster-robust SEs automatically
  output = here("tex", "pcs_taste_change_modern.tex"),
  stars = c('*' = .05, '+' = .1),
  title = "Logistic Regression of Taste Change (with Clustered SEs)"
)

# 2. Network Stability (Mundlak Poisson Models)
modelsummary(
  list("Friends (Mundlak Poisson)" = mod_friends_mundlak, 
       "Org. Memberships (Mundlak Poisson)" = mod_mems_mundlak),
  output = here("tex", "pcs_network_stability_modern.tex"),
  stars = c('*' = .05, '+' = .1),
  title = "Mundlak (Within-Between) Poisson Models for Network Stability"
)

# Summarize CFA
sink(here("tex", "cfa_summary.txt"))
summary(fit_cfa, fit.measures = TRUE, standardized = TRUE)
sink()

print("Modernized analysis complete! Outputs saved to the tex/ folder.")
