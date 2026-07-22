library(dplyr)
library(ggplot2)
library(here)
library(lme4)
library(ordinal)

# Re-run or load the models to extract the coefficients
df <- readRDS(here('R', 'pcs_processed.rds'))

library(tidyr)
df_long <- df %>% mutate(across(everything(), haven::zap_labels)) %>% 
  select(id, female, white, friends3, friends4, friends5, numsocmems3, numsocmems4, numsocmems5, numcult3, numcult4, numcult5, educ3, educ4, educ5, married3, married4, married5, childre3, childre4, childre5, bigcity3, bigcity4, bigcity5) %>% 
  pivot_longer(cols = matches('3$|4$|5$'), names_to = c('.value', 'wave'), names_pattern = '(.*)(3|4|5)$') %>% 
  mutate(wave = as.numeric(wave)) %>% 
  mutate(across(c(friends, numsocmems, numcult, educ, married, childre, bigcity), ~ as.numeric(haven::zap_labels(.))))

df_mundlak <- df_long %>% drop_na() %>% group_by(id) %>% 
  mutate(across(c(numcult, educ, married, childre, bigcity), list(mean = ~ mean(., na.rm = TRUE), within = ~ . - mean(., na.rm = TRUE)))) %>% ungroup()

df_mundlak$friends_ord <- factor(df_mundlak$friends, levels = c(3, 2, 1), labels=c("Seldom/Never", "Sometimes", "Very Often"), ordered = TRUE)

m_friends <- clmm(friends_ord ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak)
m_orgs <- glmer(numsocmems ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak, family = poisson, control = glmerControl(optimizer = 'bobyqa'))

coefs_within <- data.frame(
  Connectivity = c("Informal (Friends)", "Formal (Organizations)"),
  Estimate = c(
    summary(m_friends)$coefficients["numcult_within", "Estimate"],
    summary(m_orgs)$coefficients["numcult_within", "Estimate"]
  ),
  SE = c(
    summary(m_friends)$coefficients["numcult_within", "Std. Error"],
    summary(m_orgs)$coefficients["numcult_within", "Std. Error"]
  )
)

ggplot(coefs_within, aes(x = Connectivity, y = Estimate, fill = Connectivity)) +
  geom_bar(stat = "identity", width = 0.5) +
  geom_errorbar(aes(ymin = Estimate - 1.96*SE, ymax = Estimate + 1.96*SE), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  theme_minimal() +
  labs(
    title = "Within-Person Effects of Cultural Capital Spikes",
    subtitle = "Temporary boosts in cultural breadth increase informal but not formal connectivity",
    y = "Log-Odds / Poisson Estimate (Within-Person)",
    x = "Type of Connectivity"
  ) +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5), legend.position = "none") +
  scale_fill_manual(values = c("Formal (Organizations)" = "#7f7f7f", "Informal (Friends)" = "#2ca02c"))
  
ggsave(here("Plots", "within_formal_informal.png"), width = 7, height = 5)
