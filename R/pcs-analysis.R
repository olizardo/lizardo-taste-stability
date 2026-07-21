# Load libraries
library(dplyr)
library(tidyr)
library(lme4)
library(modelsummary)
library(here)

# 1. Load Processed Data
df <- readRDS(here("R", "pcs_processed.rds"))

# 2. Re-code dependent variables for discrete time logit (from analysis-85-90.do)
cultlist <- c("music", "movie", "sports", "paper", "books", "spevent", "videos", "hobby", "mags")
controls <- c("agegrp3", "educ3", "income3", "married3", "childre3", "working3", "bigcity3", "female", "white") # simplified agecat to agegrp3 for now
demchang <- c("chngfriends", "chorgs4", "chngeduc", "chngmarital", "chngchildre", "chngwrkstat", "chngareanam")

# Stata logic: reshape long, create chng[name]=1 if changed in wave 4
# Since this is a simple 2-wave transition (1985 to 1990) for the change analysis, 
# we can just calculate it directly in wide format.
models_change <- list()
for (cult in cultlist) {
  var3 <- paste0(cult, "3")
  var4 <- paste0(cult, "4")
  
  # Recode 4=3, 5=4 as done in the do file
  df[[var3]] <- ifelse(df[[var3]] == 4, 3, ifelse(df[[var3]] == 5, 4, df[[var3]]))
  df[[var4]] <- ifelse(df[[var4]] == 4, 3, ifelse(df[[var4]] == 5, 4, df[[var4]]))
  
  # Create dependent variable: did taste change between wave 3 and wave 4?
  chng_var <- paste0("chng_", cult)
  df[[chng_var]] <- ifelse(!is.na(df[[var3]]) & !is.na(df[[var4]]), 
                           as.numeric(df[[var3]] != df[[var4]]), NA)
  
  # Run logistic regression
  formula_str <- paste(chng_var, "~", paste(c(demchang, controls), collapse = " + "))
  
  # Note: Stata used cluster(id), in R we can use glm for standard logit, 
  # or robust standard errors via sandwich/lmtest. For simplicity in the translation:
  mod <- glm(as.formula(formula_str), data = df, family = binomial(link = "logit"))
  models_change[[cult]] <- mod
}

# 3. Effect of Cultural Taste on Network Stability
# Panel regression using plm (xtreg equivalent)
indvars <- c("educ", "married", "childre", "agegrp3", "bigcity")

# Reshape data to long format for panel estimation
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
  mutate(wave = as.numeric(wave))

# Estimate Random Effects Panel Model using lme4
mod_friends_re <- lmer(friends ~ numcult + female + educ + married + childre + bigcity + (1|id), 
                       data = df_long)

# Model B: predicting numsocmems
mod_mems_re <- lmer(numsocmems ~ numcult + female + educ + married + childre + bigcity + (1|id), 
                    data = df_long)

# (Note: Stata also used xtivreg with numcult2 as an instrument. 
# We could use plm(..., model="random", inst=...) but leaving the base models for now)

# 4. Save results
modelsummary(
  list("Friends (RE)" = mod_friends_re, "Org. Memberships (RE)" = mod_mems_re),
  output = here("tex", "pcs_network_stability.tex"),
  stars = c('*' = .05, '+' = .1)
)

modelsummary(
  models_change,
  output = here("tex", "pcs_taste_change.tex"),
  stars = c('*' = .05, '+' = .1)
)
