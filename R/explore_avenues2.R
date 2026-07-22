library(dplyr)
library(tidyr)
library(lme4)
library(lavaan)
library(here)

df <- readRDS(here('R', 'pcs_processed.rds'))

cat("\n--- 2. CROSS-LAGGED PANEL MODEL ---\n")
df_clpm <- df %>% select(id, numcult3, numcult4, numcult5, friends3, friends4, friends5) %>% drop_na()

riclpm_model <- '
  RI_cult =~ 1*numcult3 + 1*numcult4 + 1*numcult5
  RI_frnd =~ 1*friends3 + 1*friends4 + 1*friends5
  
  wc3 =~ 1*numcult3; wf3 =~ 1*friends3
  wc4 =~ 1*numcult4; wf4 =~ 1*friends4
  wc5 =~ 1*numcult5; wf5 =~ 1*friends5
  
  numcult3 ~~ 0*numcult3; friends3 ~~ 0*friends3
  numcult4 ~~ 0*numcult4; friends4 ~~ 0*friends4
  numcult5 ~~ 0*numcult5; friends5 ~~ 0*friends5
  
  wc4 ~ a1*wc3
  wc5 ~ a1*wc4
  wf4 ~ b1*wf3
  wf5 ~ b1*wf4
  
  wc4 ~ c1*wf3 
  wc5 ~ c1*wf4
  wf4 ~ d1*wc3 
  wf5 ~ d1*wc4
  
  wc3 ~~ wf3
  wc4 ~~ wf4
  wc5 ~~ wf5
  RI_cult ~~ RI_frnd
'
tryCatch({
  fit_clpm <- sem(riclpm_model, data = df_clpm, missing = "ml")
  print(parameterEstimates(fit_clpm) %>% filter(op == "~") %>% select(lhs, op, rhs, est, se, pvalue))
}, error = function(e) { cat("Lavaan failed: ", e$message, "\n") })

cat("\n--- 3. DOMAIN SPECIFIC CONVERSION ---\n")
df_domain <- df %>% select(id, sports3, books3, play3, hobby3, memspor4, mempriv4, memhobb4, memserv4) %>% drop_na()
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

