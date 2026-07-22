
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
df_raw <- haven::read_dta(here("PCS", "pc1980-85-90-95.dta"))

df$family3 <- df_raw$family3
df$family4 <- df_raw$family4
df$family5 <- df_raw$family5

clean_cult <- function(x) {
  ifelse(x %in% c(0, 8, 9), NA, x)
}

df <- df %>%
  mutate(across(c(family3, family4, family5), clean_cult)) %>%
  # Harmonize Wave 4 scales (4=Monthly -> 3 Seldom, 5=Hardly/Never -> 4 Never)
  mutate(across(c(family4), ~ case_match(., 4 ~ 3, 5 ~ 4, .default = .))) %>%
  # Harmonize Wave 5 scales (1-3 -> 1, 4-5 -> 2, 6 -> 3, 7 -> 4)
  mutate(across(c(family5), ~ case_match(., 1:3 ~ 1, 4:5 ~ 2, 6 ~ 3, 7 ~ 4, .default = .)))

# Handle recoding 4 to 3 (so 3=Seldom/Never)
df <- df %>%
  mutate(
    family3 = ifelse(family3 == 4, 3, family3),
    family4 = ifelse(family4 == 4, 3, family4),
    family5 = ifelse(family5 == 4, 3, family5)
  )

# Mixed-Effects Models
df_long <- df %>% mutate(across(everything(), haven::zap_labels)) %>% select(id, female, white, friends3, friends4, friends5, family3, family4, family5, numsocmems3, numsocmems4, numsocmems5, numcult3, numcult4, numcult5, educ3, educ4, educ5, married3, married4, married5, childre3, childre4, childre5, bigcity3, bigcity4, bigcity5, age3, age4, age5, working3, working4, working5) %>% pivot_longer(cols = matches('3$|4$|5$'), names_to = c('.value', 'wave'), names_pattern = '(.*)(3|4|5)$') %>% mutate(wave = as.numeric(wave)) %>% mutate(across(c(friends, family, numsocmems, numcult, educ, married, childre, bigcity, age, working), ~ as.numeric(haven::zap_labels(.))))
df_mundlak <- df_long %>% drop_na() %>% group_by(id) %>% mutate(across(c(numcult, educ, married, childre, bigcity, age, working), list(mean = ~ mean(., na.rm = TRUE), within = ~ . - mean(., na.rm = TRUE)))) %>% ungroup()

df_mundlak$friends_ord <- factor(df_mundlak$friends, levels = c(3, 2, 1), labels=c("Seldom/Never", "Sometimes", "Very Often"), ordered = TRUE)
df_mundlak$family_ord <- factor(df_mundlak$family, levels = c(3, 2, 1), labels=c("Seldom/Never", "Sometimes", "Very Often"), ordered = TRUE)


m_friends <- clmm(friends_ord ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + working_within + age_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + working_mean + age_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak)
m_orgs <- glmer(numsocmems ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + working_within + age_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + working_mean + age_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak, family = poisson, control = glmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=1e5)))
m_family <- clmm(family_ord ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + working_within + age_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + working_mean + age_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak)

glance_custom.clmm <- function(x, ...) {
  # Extract the random effect variance from the clmm object manually for modelsummary
  var_id <- x$ST[[1]][1]^2
  # Calculate approximate ICC for a cumulative link model (assuming latent logistic distribution with variance pi^2 / 3)
  icc <- var_id / (var_id + (pi^2 / 3))
  data.frame(
    `Between-Person Variance` = var_id,
    `ICC (Between Prop.)` = icc,
    check.names = FALSE
  )
}
glance_custom.glmerMod <- function(x, ...) {
  # Extract variance component for the intercept
  var_id <- as.numeric(lme4::VarCorr(x)$id)
  data.frame(
    `Between-Person Variance` = var_id,
    check.names = FALSE
  )
}

m2 <- modelsummary(
  list('Friends' = m_friends, 'Org. Memberships' = m_orgs, 'Family (Kin)' = m_family),
  estimate = '{estimate}{stars}', statistic = NULL, stars = c('+' = 0.1, '*' = 0.05),
  coef_rename = c('numcult_mean' = 'Cultural Breadth (Between)', 'educ_mean' = 'Education (Between)', 'married_mean' = 'Married (Between)', 'childre_mean' = 'Children (Between)', 'bigcity_mean' = 'Big City (Between)', 'working_mean' = 'Employed (Between)', 'age_mean' = 'Age (Between)', 'numcult_within' = 'Cultural Breadth (Within)', 'educ_within' = 'Education (Within)', 'married_within' = 'Married (Within)', 'childre_within' = 'Children (Within)', 'bigcity_within' = 'Big City (Within)', 'working_within' = 'Employed (Within)', 'age_within' = 'Age (Within)', 'female' = 'Female', 'white' = 'White'),
  coef_omit = 'Intercept|wave', 
  gof_map = list(
    list("raw" = "nobs", "clean" = "Num. Observations", "fmt" = 0),
    list("raw" = "Between-Person Variance", "clean" = "Between-Person Variance", "fmt" = 2),
    list("raw" = "ICC (Between Prop.)", "clean" = "ICC (Between-Person Prop.)", "fmt" = 2)
  ),
  title = 'Mundlak Mixed-Effects Models for Network Connectivity (1985-1995)',
  notes = list('Wave fixed effects and threshold coefficients omitted for space.', 'SEs omitted for space.', '+ p < 0.1, * p < 0.05', 'Within-person variance for count/ordinal models is fixed by their theoretical link functions.'),
  output = here('Tabs', 'pcs_network_stability_modern.tex')
)

