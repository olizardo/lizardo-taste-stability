# Modernized Data Analysis Workflow for PCS (1980-1995)
library(dplyr)
library(tidyr)
library(lme4)
library(modelsummary)
library(lmtest)
library(sandwich)
library(here)

# 1. Load Processed Data
df <- readRDS(here("R", "pcs_processed.rds"))

# =====================================================================
# PART A: TASTE CHANGE (Discrete-Time Survival / Clustered Logit)
# =====================================================================
# We pool transitions: 1985->1990 (Wave 3->4) and 1990->1995 (Wave 4->5)

cultlist <- c("music", "movie", "play", "sports", "paper", "books", "spevent", "videos", "hobby", "mags")
controls <- c("agegrp", "educ", "income", "married", "childre", "working", "bigcity")
demchang <- c("chngfriends", "chngorgs", "chngeduc", "chngmarital", "chngchildre", "chngwrkstat", "chngareanam")

# Create a stacked person-period dataset for the logit models
# Period 1: wave 3->4
p1 <- df %>% select(id, female, white,
                    all_of(paste0(cultlist, "3")), all_of(paste0(cultlist, "4")),
                    all_of(paste0(controls, "3")),
                    all_of(paste0(demchang, "4"))) %>%
             mutate(period = 1) %>%
             rename_with(~gsub("3$", "_start", .), ends_with("3")) %>%
             rename_with(~gsub("4$", "_end", .), ends_with("4"))

# Period 2: wave 4->5
p2 <- df %>% select(id, female, white,
                    all_of(paste0(cultlist, "4")), all_of(paste0(cultlist, "5")),
                    all_of(paste0(controls, "4")),
                    all_of(paste0(demchang, "5"))) %>%
             mutate(period = 2) %>%
             rename_with(~gsub("4$", "_start", .), ends_with("4")) %>%
             rename_with(~gsub("5$", "_end", .), ends_with("5"))

df_transitions <- bind_rows(p1, p2)

logit_models <- list()
for (c in cultlist) {
  # Taste loss event: started "very often" (1) and became "seldom" (3) or "never" (4)
  # Exclude those who didn't start at "very often" to match event history logic
  # Or just model event = (end >= 3) for subset where start == 1
  df_sub <- df_transitions %>%
    filter(.data[[paste0(c, "_start")]] == 1) %>%
    mutate(event = ifelse(.data[[paste0(c, "_end")]] >= 3, 1, 0)) %>%
    drop_na(event, all_of(paste0(controls, "_start")), all_of(paste0(demchang, "_end")))


  if (nrow(df_sub) > 0) {
    # Only include variables with variance
    vars_to_check <- c(paste0(demchang, "_end"), paste0(controls, "_start"), "female", "white", "period")
    valid_vars <- c()
    for (v in vars_to_check) {
      if (length(unique(df_sub[[v]])) > 1) {
        if (v == "period") {
           valid_vars <- c(valid_vars, "as.factor(period)")
        } else {
           valid_vars <- c(valid_vars, v)
        }
      }
    }
    
    if (length(valid_vars) > 0) {
       f_str <- paste("event ~", paste(valid_vars, collapse=" + "))
       m <- glm(as.formula(f_str), data = df_sub, family = binomial(link="logit"))
       logit_models[[c]] <- m
    }
  }

}

# Export clustered SEs using sandwich vcov = ~id
modelsummary(
  logit_models,
  vcov = lapply(logit_models, function(m) sandwich::vcovCL(m, cluster = m$data$id)),
  stars = c("+" = 0.1, "*" = 0.05),
  output = here("tex", "pcs_taste_change_modern.tex"),
  title = "Pooled Discrete-Time Logistic Regression of Taste Change (with Clustered SEs)",
  gof_map = c("nobs", "aic", "bic", "logLik", "rmse")
)

# =====================================================================
# PART B: LONGITUDINAL CONNECTIVITY (Mundlak Poisson Models)
# =====================================================================
# Pivot waves 3, 4, 5 for longitudinal analysis
df_long <- df %>%
  mutate(across(everything(), haven::zap_labels)) %>%
  select(id, female, white, 
         friends3, friends4, friends5,
         numsocmems3, numsocmems4, numsocmems5,
         numcult3, numcult4, numcult5,
         educ3, educ4, educ5,
         married3, married4, married5,
         childre3, childre4, childre5,
         bigcity3, bigcity4, bigcity5) %>%
  pivot_longer(
    cols = matches("3$|4$|5$"),
    names_to = c(".value", "wave"),
    names_pattern = "(.*)(3|4|5)$"
  ) %>%
  mutate(wave = as.numeric(wave)) %>%
  # Ensure haven_labelled types are coerced to numeric
  mutate(across(c(friends, numsocmems, numcult, educ, married, childre, bigcity), ~ as.numeric(haven::zap_labels(.))))

# Create Mundlak (Within-Between) variables
df_mundlak <- df_long %>%
  drop_na() %>%
  group_by(id) %>%
  mutate(across(
    c(numcult, educ, married, childre, bigcity),
    list(
      mean = ~ mean(., na.rm = TRUE),
      within = ~ . - mean(., na.rm = TRUE)
    )
  )) %>%
  ungroup()

m_friends <- glmer(
  friends ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + 
            numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + 
            female + white + as.factor(wave) + (1 | id), 
  data = df_mundlak, family = poisson, control = glmerControl(optimizer = "bobyqa")
)

m_orgs <- glmer(
  numsocmems ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + 
               numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + 
               female + white + as.factor(wave) + (1 | id), 
  data = df_mundlak, family = poisson, control = glmerControl(optimizer = "bobyqa")
)

modelsummary(
  list("Friends (Mundlak Poisson)" = m_friends, "Org. Memberships (Mundlak Poisson)" = m_orgs),
  stars = c("+" = 0.1, "*" = 0.05),
  output = here("tex", "pcs_network_stability_modern.tex"),
  title = "Mundlak (Within-Between) Poisson Models for Network Stability (1985-1995)",
  gof_map = c("nobs", "r.squared", "aic", "bic", "icc", "rmse")
)

