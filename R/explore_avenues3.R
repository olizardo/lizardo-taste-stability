library(dplyr)
library(tidyr)
library(lme4)
library(lavaan)
library(here)

df <- readRDS(here('R', 'pcs_processed.rds'))

cat("\n--- 3. DOMAIN SPECIFIC CONVERSION ---\n")
df_domain <- df %>% select(id, sports3, books3, play3, hobby3, memspor4, mempriv4, memhobb4, memserv4) %>% drop_na()
df_domain <- df_domain %>% mutate(across(everything(), haven::zap_labels)) # Fix vctrs issue
df_domain <- df_domain %>% mutate(
    sports = 5 - sports3,
    books = 5 - books3,
    hobby = 5 - hobby3,
    play = 5 - play3,
    memspor = ifelse(memspor4>0,1,0),
    mempriv = ifelse(mempriv4>0,1,0),
    memhobb = ifelse(memhobb4>0,1,0)
)
m_spor <- glm(memspor ~ sports + books + hobby, data = df_domain, family=binomial)
m_hobb <- glm(memhobb ~ hobby + sports + books, data = df_domain, family=binomial)

cat("Predicting Sports Club (Wave 4) using Tastes (Wave 3):\n")
print(summary(m_spor)$coefficients[c("sports", "books", "hobby"), ])
cat("\nPredicting Hobby Club (Wave 4) using Tastes (Wave 3):\n")
print(summary(m_hobb)$coefficients[c("hobby", "sports", "books"), ])

cat("\n--- 4. MOBILITY VS REPRODUCTION ---\n")
source(here('R', 'pcs-analysis-modern.R'))
m_mob <- glmer(friends ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + 
                 numcult_mean * educ_mean + married_mean + childre_mean + bigcity_mean + female + white + 
                 as.factor(wave) + (1 | id), data = df_mundlak, family = poisson, control = glmerControl(optimizer = 'bobyqa'))
print(summary(m_mob)$coefficients[grepl("numcult_mean|educ_mean", rownames(summary(m_mob)$coefficients)), ])
