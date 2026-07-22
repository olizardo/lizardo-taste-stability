library(dplyr)
library(tidyr)
library(lme4)
library(ordinal)
library(modelsummary)
library(here)

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

df_long <- df %>% mutate(across(everything(), haven::zap_labels)) %>% 
  select(id, female, white, friends3, friends4, friends5, family3, family4, family5, numsocmems3, numsocmems4, numsocmems5, numcult3, numcult4, numcult5, educ3, educ4, educ5, married3, married4, married5, childre3, childre4, childre5, bigcity3, bigcity4, bigcity5) %>% 
  pivot_longer(cols = matches('3$|4$|5$'), names_to = c('.value', 'wave'), names_pattern = '(.*)(3|4|5)$') %>% 
  mutate(wave = as.numeric(wave)) %>% 
  mutate(across(c(friends, family, numsocmems, numcult, educ, married, childre, bigcity), ~ as.numeric(haven::zap_labels(.))))

df_mundlak <- df_long %>% drop_na() %>% group_by(id) %>% 
  mutate(across(c(numcult, educ, married, childre, bigcity), list(mean = ~ mean(., na.rm = TRUE), within = ~ . - mean(., na.rm = TRUE)))) %>% ungroup()

df_mundlak$friends_ord <- factor(df_mundlak$friends, levels = c(3, 2, 1), labels=c("Seldom/Never", "Sometimes", "Very Often"), ordered = TRUE)
df_mundlak$family_ord <- factor(df_mundlak$family, levels = c(3, 2, 1), labels=c("Seldom/Never", "Sometimes", "Very Often"), ordered = TRUE)

m_friends <- clmm(friends_ord ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak)
m_family <- clmm(family_ord ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak)

m2 <- modelsummary(
  list('Friends (Non-Kin)' = m_friends, 'Family (Kin)' = m_family),
  estimate = '{estimate}{stars}', statistic = NULL, stars = c('+' = 0.1, '*' = 0.05),
  coef_rename = c('numcult_mean' = 'Cultural Breadth (Between)', 'educ_mean' = 'Education (Between)', 'married_mean' = 'Married (Between)', 'childre_mean' = 'Children (Between)', 'bigcity_mean' = 'Big City (Between)', 'numcult_within' = 'Cultural Breadth (Within)', 'educ_within' = 'Education (Within)', 'married_within' = 'Married (Within)', 'childre_within' = 'Children (Within)', 'bigcity_within' = 'Big City (Within)', 'female' = 'Female', 'white' = 'White'),
  coef_omit = 'Intercept|wave', gof_map = c('nobs'),
  title = 'Mundlak Mixed-Effects Models for Kin and Non-Kin Interaction',
  notes = list('Wave fixed effects and threshold coefficients omitted for space.', 'SEs omitted for space.', '+ p < 0.1, * p < 0.05'),
  output = 'kableExtra'
)
m2 |> kableExtra::kable_styling(latex_options = c('hold_position')) |> kableExtra::save_kable(here('tex', 'pcs_kin_comparison.tex'))

# Build simple coefficient plot
library(ggplot2)
coefs <- data.frame(
  Model = c("Friends", "Family"),
  Estimate = c(summary(m_friends)$coefficients["numcult_mean", "Estimate"], summary(m_family)$coefficients["numcult_mean", "Estimate"]),
  SE = c(summary(m_friends)$coefficients["numcult_mean", "Std. Error"], summary(m_family)$coefficients["numcult_mean", "Std. Error"])
)

ggplot(coefs, aes(x = Model, y = Estimate, fill=Model)) +
  geom_bar(stat = "identity", width = 0.5) +
  geom_errorbar(aes(ymin = Estimate - 1.96*SE, ymax = Estimate + 1.96*SE), width = 0.2) +
  theme_minimal() +
  labs(title = "Effect of Cultural Capital on Interaction Frequency", y = "Log-Odds Estimate (Between-Person)", x = "Tie Type") +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5))
ggsave(here("tex", "kin_vs_nonkin.png"), width = 6, height = 4)

