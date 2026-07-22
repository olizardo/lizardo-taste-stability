library(dplyr)

lines <- readLines("R/pcs-analysis-modern.R")

new_lines <- character(0)
for(line in lines) {
    if (grepl("cultlist <- c\\(", line)) {
        new_lines <- c(new_lines, "cultlist <- c('music', 'sports', 'paper', 'books')")
    } else if (grepl("names\\(logit_models\\)", line)) {
        new_lines <- c(new_lines, "names(logit_models) <- c('Music', 'Sports', 'Newspaper', 'Books')")
    } else if (grepl("half <- ceiling\\(length\\(logit_models\\) / 2\\)", line)) {
        # Skip the split table logic entirely, we'll revert to a single table
        break
    } else {
        new_lines <- c(new_lines, line)
    }
}

# Add back the single table generation for Table 1
new_lines <- c(new_lines, "
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
  coef_rename = coef_map_rename, coef_omit = 'Intercept|.*_start|female|white|as\\\\.factor', gof_map = c('nobs'),
  title = 'Predictors of Taste Loss (Pooled Discrete-Time Logistic Regression)',
  notes = list('Controls and SEs omitted for space.', '+ p < 0.1, * p < 0.05'),
  output = 'kableExtra'
)
m1 |> kable_styling(latex_options = c('hold_position')) |> save_kable(here('tex', 'pcs_taste_change_modern.tex'))

# Poisson Models
df_long <- df %>% mutate(across(everything(), haven::zap_labels)) %>% select(id, female, white, friends3, friends4, friends5, numsocmems3, numsocmems4, numsocmems5, numcult3, numcult4, numcult5, educ3, educ4, educ5, married3, married4, married5, childre3, childre4, childre5, bigcity3, bigcity4, bigcity5) %>% pivot_longer(cols = matches('3$|4$|5$'), names_to = c('.value', 'wave'), names_pattern = '(.*)(3|4|5)$') %>% mutate(wave = as.numeric(wave)) %>% mutate(across(c(friends, numsocmems, numcult, educ, married, childre, bigcity), ~ as.numeric(haven::zap_labels(.))))
df_mundlak <- df_long %>% drop_na() %>% group_by(id) %>% mutate(across(c(numcult, educ, married, childre, bigcity), list(mean = ~ mean(., na.rm = TRUE), within = ~ . - mean(., na.rm = TRUE)))) %>% ungroup()

m_friends <- glmer(friends ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak, family = poisson, control = glmerControl(optimizer = 'bobyqa'))
m_orgs <- glmer(numsocmems ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak, family = poisson, control = glmerControl(optimizer = 'bobyqa'))

m2 <- modelsummary(
  list('Friends' = m_friends, 'Org. Memberships' = m_orgs),
  estimate = '{estimate}{stars}', statistic = NULL, stars = c('+' = 0.1, '*' = 0.05),
  coef_rename = c('numcult_mean' = 'Cultural Breadth (Between)', 'educ_mean' = 'Education (Between)', 'married_mean' = 'Married (Between)', 'childre_mean' = 'Children (Between)', 'bigcity_mean' = 'Big City (Between)', 'numcult_within' = 'Cultural Breadth (Within)', 'educ_within' = 'Education (Within)', 'married_within' = 'Married (Within)', 'childre_within' = 'Children (Within)', 'bigcity_within' = 'Big City (Within)', 'female' = 'Female', 'white' = 'White'),
  coef_omit = 'Intercept|wave', gof_map = c('nobs'),
  title = 'Mundlak Poisson Models for Network Connectivity (1985-1995)',
  notes = list('Wave fixed effects and intercept omitted for space.', 'SEs omitted for space.', '+ p < 0.1, * p < 0.05'),
  output = 'kableExtra'
)
m2 |> kable_styling(latex_options = c('hold_position')) |> save_kable(here('tex', 'pcs_network_stability_modern.tex'))
")

writeLines(new_lines, "R/pcs-analysis-modern.R")
