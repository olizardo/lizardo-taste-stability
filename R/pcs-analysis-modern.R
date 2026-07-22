
library(dplyr)
library(tidyr)
library(lme4)
library(modelsummary)
library(lmtest)
library(sandwich)
library(here)
library(kableExtra)

options(modelsummary_factory_latex = 'kableExtra')

df <- readRDS(here('R', 'pcs_processed.rds'))

cultlist <- c('music', 'sports', 'paper', 'books')
controls <- c('agegrp', 'educ', 'income', 'married', 'childre', 'working', 'bigcity')
demchang <- c('chngfriends', 'chngorgs', 'chngeduc', 'chngmarital', 'chngchildre', 'chngwrkstat', 'chngareanam')

p1 <- df %>% select(id, female, white, all_of(paste0(cultlist, '3')), all_of(paste0(cultlist, '4')), all_of(paste0(controls, '3')), all_of(paste0(demchang, '4'))) %>% mutate(period = 1) %>% rename_with(~gsub('3$', '_start', .), ends_with('3')) %>% rename_with(~gsub('4$', '_end', .), ends_with('4'))
p2 <- df %>% select(id, female, white, all_of(paste0(cultlist, '4')), all_of(paste0(cultlist, '5')), all_of(paste0(controls, '4')), all_of(paste0(demchang, '5'))) %>% mutate(period = 2) %>% rename_with(~gsub('4$', '_start', .), ends_with('4')) %>% rename_with(~gsub('5$', '_end', .), ends_with('5'))
df_transitions <- bind_rows(p1, p2)

logit_models <- list()
for (c in cultlist) {
  df_sub <- df_transitions %>% filter(.data[[paste0(c, '_start')]] == 1) %>% mutate(event = ifelse(.data[[paste0(c, '_end')]] >= 3, 1, 0)) %>% drop_na(event, all_of(paste0(controls, '_start')), all_of(paste0(demchang, '_end')))
  if (nrow(df_sub) > 0) {
    vars_to_check <- c(paste0(demchang, '_end'), paste0(controls, '_start'), 'female', 'white', 'period')
    valid_vars <- c()
    for (v in vars_to_check) {
      if (length(unique(df_sub[[v]])) > 1) {
        if (v == 'period') { valid_vars <- c(valid_vars, 'as.factor(period)') } else { valid_vars <- c(valid_vars, v) }
      }
    }
    if (length(valid_vars) > 0) {
       f_str <- paste('event ~', paste(valid_vars, collapse=' + '))
       m <- glm(as.formula(f_str), data = df_sub, family = binomial(link='logit'))
       logit_models[[c]] <- m
    }
  }
}

names(logit_models) <- c('Music', 'Sports', 'Newspaper', 'Books')

# Split logit_models in two

coef_map_rename <- c(
    'chngfriends_endTRUE' = 'Change in Friends',
    'chngorgs_endTRUE' = 'Change in Org. Memberships',
    'chngeduc_endTRUE' = 'Change in Educ. Standing',
    'chngmarital_endTRUE' = 'Change in Marital Status',
    'chngchildre_endTRUE' = 'Change in Children',
    'chngwrkstat_endTRUE' = 'Change in Work Status',
    'chngareanam_endTRUE' = 'Geographic Mobility'
)

m1 <- modelsummary(
  logit_models,
  vcov = lapply(logit_models, function(m) sandwich::vcovCL(m, cluster = m$data$id)),
  estimate = '{estimate}{stars}', statistic = NULL, stars = c('+' = 0.1, '*' = 0.05),
  coef_rename = coef_map_rename, coef_omit = 'Intercept|.*_start|female|white|as\\.factor', gof_map = c('nobs'),
  title = 'Predictors of Taste Loss (Pooled Discrete-Time Logistic Regression)',
  notes = list('Controls and SEs omitted for space.', '+ p < 0.1, * p < 0.05'),
  output = 'kableExtra'
)
m1 |> kable_styling(latex_options = c('hold_position')) |> save_kable(here('tex', 'pcs_taste_change_modern.tex'))

# Taste Acquisition Models
logit_models_acq <- list()
for (c in cultlist) {
  # For acquisition, we look at people who seldom/never do it (>= 3) and see if they start doing it very often/sometimes (<= 2)
  df_sub <- df_transitions %>% filter(.data[[paste0(c, '_start')]] >= 3) %>% mutate(event = ifelse(.data[[paste0(c, '_end')]] <= 2, 1, 0)) %>% drop_na(event, all_of(paste0(controls, '_start')), all_of(paste0(demchang, '_end')))
  if (nrow(df_sub) > 0) {
    vars_to_check <- c(paste0(demchang, '_end'), paste0(controls, '_start'), 'female', 'white', 'period')
    valid_vars <- c()
    for (v in vars_to_check) {
      if (length(unique(df_sub[[v]])) > 1) {
        if (v == 'period') { valid_vars <- c(valid_vars, 'as.factor(period)') } else { valid_vars <- c(valid_vars, v) }
      }
    }
    if (length(valid_vars) > 0) {
       f_str <- paste('event ~', paste(valid_vars, collapse=' + '))
       m <- glm(as.formula(f_str), data = df_sub, family = binomial(link='logit'))
       logit_models_acq[[c]] <- m
    }
  }
}

names(logit_models_acq) <- c('Music', 'Sports', 'Newspaper', 'Books')

m_acq <- modelsummary(
  logit_models_acq,
  vcov = lapply(logit_models_acq, function(m) sandwich::vcovCL(m, cluster = m$data$id)),
  estimate = '{estimate}{stars}', statistic = NULL, stars = c('+' = 0.1, '*' = 0.05),
  coef_rename = coef_map_rename, coef_omit = 'Intercept|.*_start|female|white|as\\.factor', gof_map = c('nobs'),
  title = 'Predictors of Taste Acquisition (Pooled Discrete-Time Logistic Regression)',
  notes = list('Controls and SEs omitted for space.', '+ p < 0.1, * p < 0.05'),
  output = 'kableExtra'
)
m_acq |> kable_styling(latex_options = c('hold_position')) |> save_kable(here('tex', 'pcs_taste_acquisition.tex'))

# Mixed-Effects Models
library(ordinal)
df_long <- df %>% mutate(across(everything(), haven::zap_labels)) %>% select(id, female, white, friends3, friends4, friends5, numsocmems3, numsocmems4, numsocmems5, numcult3, numcult4, numcult5, educ3, educ4, educ5, married3, married4, married5, childre3, childre4, childre5, bigcity3, bigcity4, bigcity5) %>% pivot_longer(cols = matches('3$|4$|5$'), names_to = c('.value', 'wave'), names_pattern = '(.*)(3|4|5)$') %>% mutate(wave = as.numeric(wave)) %>% mutate(across(c(friends, numsocmems, numcult, educ, married, childre, bigcity), ~ as.numeric(haven::zap_labels(.))))
df_mundlak <- df_long %>% drop_na() %>% group_by(id) %>% mutate(across(c(numcult, educ, married, childre, bigcity), list(mean = ~ mean(., na.rm = TRUE), within = ~ . - mean(., na.rm = TRUE)))) %>% ungroup()

df_mundlak$friends_ord <- factor(df_mundlak$friends, levels = c(3, 2, 1), labels=c("Seldom/Never", "Sometimes", "Very Often"), ordered = TRUE)

m_friends <- clmm(friends_ord ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak)
m_orgs <- glmer(numsocmems ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak, family = poisson, control = glmerControl(optimizer = 'bobyqa'))


m2 <- modelsummary(
  list('Friends' = m_friends, 'Org. Memberships' = m_orgs),
  estimate = '{estimate}{stars}', statistic = NULL, stars = c('+' = 0.1, '*' = 0.05),
  coef_rename = c('numcult_mean' = 'Cultural Breadth (Between)', 'educ_mean' = 'Education (Between)', 'married_mean' = 'Married (Between)', 'childre_mean' = 'Children (Between)', 'bigcity_mean' = 'Big City (Between)', 'numcult_within' = 'Cultural Breadth (Within)', 'educ_within' = 'Education (Within)', 'married_within' = 'Married (Within)', 'childre_within' = 'Children (Within)', 'bigcity_within' = 'Big City (Within)', 'female' = 'Female', 'white' = 'White'),
  coef_omit = 'Intercept|wave', gof_map = c('nobs'),
  title = 'Mundlak Mixed-Effects Models for Network Connectivity (1985-1995)',
  notes = list('Wave fixed effects and intercept omitted for space.', 'SEs omitted for space.', '+ p < 0.1, * p < 0.05'),
  output = 'kableExtra'
)
m2 |> kable_styling(latex_options = c('hold_position')) |> save_kable(here('tex', 'pcs_network_stability_modern.tex'))

