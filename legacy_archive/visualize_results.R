# R/visualize_results.R
# Visualizations to summarize the main pattern of results for the Research Note

library(ggplot2)
library(dplyr)
library(tidyr)
library(lme4)
library(ordinal)
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
  mutate(across(c(family4), ~ case_match(., 4 ~ 3, 5 ~ 4, .default = .))) %>%
  mutate(across(c(family5), ~ case_match(., 1:3 ~ 1, 4:5 ~ 2, 6 ~ 3, 7 ~ 4, .default = .)))

df <- df %>%
  mutate(
    family3 = ifelse(family3 == 4, 3, family3),
    family4 = ifelse(family4 == 4, 3, family4),
    family5 = ifelse(family5 == 4, 3, family5)
  )

df_long <- df %>% mutate(across(everything(), haven::zap_labels)) %>% select(id, female, white, friends3, friends4, friends5, family3, family4, family5, numsocmems3, numsocmems4, numsocmems5, numcult3, numcult4, numcult5, educ3, educ4, educ5, married3, married4, married5, childre3, childre4, childre5, bigcity3, bigcity4, bigcity5, age3, age4, age5, working3, working4, working5) %>% pivot_longer(cols = matches('3$|4$|5$'), names_to = c('.value', 'wave'), names_pattern = '(.*)(3|4|5)$') %>% mutate(wave = as.numeric(wave)) %>% mutate(across(c(friends, family, numsocmems, numcult, educ, married, childre, bigcity, age, working), ~ as.numeric(haven::zap_labels(.))))
df_mundlak <- df_long %>% drop_na() %>% group_by(id) %>% mutate(across(c(numcult, educ, married, childre, bigcity, age, working), list(mean = ~ mean(., na.rm = TRUE), within = ~ . - mean(., na.rm = TRUE)))) %>% ungroup()

df_mundlak$friends_ord <- factor(df_mundlak$friends, levels = c(3, 2, 1), labels=c("Seldom/Never", "Sometimes", "Very Often"), ordered = TRUE)
df_mundlak$family_ord <- factor(df_mundlak$family, levels = c(3, 2, 1), labels=c("Seldom/Never", "Sometimes", "Very Often"), ordered = TRUE)

m_friends <- clmm(friends_ord ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + working_within + age_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + working_mean + age_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak)
m_orgs <- glmer(numsocmems ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + working_within + age_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + working_mean + age_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak, family = poisson, control = glmerControl(optimizer = 'bobyqa'))
m_family <- clmm(family_ord ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + working_within + age_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + working_mean + age_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak)

coefs <- data.frame(
  Outcome = rep(c("Friends\n(Ordinal)", "Org. Memberships\n(Count)", "Family\n(Ordinal)"), each = 2),
  EffectType = rep(c("Between-Person (Average)", "Within-Person (Spike)"), 3),
  Estimate = c(
    summary(m_friends)$coefficients["numcult_mean", "Estimate"],
    summary(m_friends)$coefficients["numcult_within", "Estimate"],
    summary(m_orgs)$coefficients["numcult_mean", "Estimate"],
    summary(m_orgs)$coefficients["numcult_within", "Estimate"],
    summary(m_family)$coefficients["numcult_mean", "Estimate"],
    summary(m_family)$coefficients["numcult_within", "Estimate"]
  ),
  SE = c(
    summary(m_friends)$coefficients["numcult_mean", "Std. Error"],
    summary(m_friends)$coefficients["numcult_within", "Std. Error"],
    summary(m_orgs)$coefficients["numcult_mean", "Std. Error"],
    summary(m_orgs)$coefficients["numcult_within", "Std. Error"],
    summary(m_family)$coefficients["numcult_mean", "Std. Error"],
    summary(m_family)$coefficients["numcult_within", "Std. Error"]
  )
)

# Keep the order logical
coefs$Outcome <- factor(coefs$Outcome, levels = c("Friends\n(Ordinal)", "Family\n(Ordinal)", "Org. Memberships\n(Count)"))

p_unified <- ggplot(coefs, aes(x = Outcome, y = Estimate, fill = EffectType)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.6), width = 0.5) +
  geom_errorbar(aes(ymin = Estimate - 1.96*SE, ymax = Estimate + 1.96*SE), position = position_dodge(width = 0.6), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  theme_minimal() +
  labs(
    title = "Effects of Cultural Breadth on Network Connectivity", 
    subtitle = "Estimates (Log Link Scale) and 95% Confidence Intervals",
    y = "Coefficient Estimate", 
    x = "Outcome Variable", 
    fill = "Mundlak Effect"
  ) +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5), legend.position = "bottom") +
  scale_fill_manual(values = c("Between-Person (Average)" = "#2c7bb6", "Within-Person (Spike)" = "#d7191c"))

ggsave(here("Plots", "unified_cultural_effects.png"), p_unified, width = 8, height = 5)

print("Visualizations script R/visualize_results.R created successfully.")
