
library(dplyr)
library(tidyr)
library(lme4)
library(modelsummary)
library(lmtest)
library(sandwich)
library(here)
library(kableExtra)
library(ordinal)

options(modelsummary_factory_latex = 'kableExtra')

df <- readRDS(here('R', 'pcs_processed.rds'))

# Mixed-Effects Models
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
  output = here('Tabs', 'pcs_network_stability_modern.tex')
)

