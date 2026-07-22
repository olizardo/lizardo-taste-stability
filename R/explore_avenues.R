library(dplyr)
library(tidyr)
library(lme4)
library(lavaan)
library(here)

df <- readRDS(here('R', 'pcs_processed.rds'))
source(here('R', 'pcs-analysis-modern.R'))

# 1. The Buffering Hypothesis
# We will use "chngmarital_4" (marriage shock) and "chngareanam_4" (moving shock)
# Since the mundlak data is long, we need a time-varying shock variable. 
# Let's simplify and just look at the cross-sectional buffering at wave 4
cat("\n--- 1. BUFFERING HYPOTHESIS ---\n")
df_buff <- df_transitions %>% drop_na(friends_end, numcult_start, chngareanam_end, chngmarital_end)
m_buff1 <- glm(friends_end ~ numcult_start * chngareanam_end + numcult_start * chngmarital_end + female + white + educ_start, data = df_buff, family=poisson)
print(summary(m_buff1)$coefficients[grepl("numcult", rownames(summary(m_buff1)$coefficients)), ])

# 2. RI-CLPM (Cross Lagged Panel Model) for Causality
cat("\n--- 2. CROSS-LAGGED PANEL MODEL ---\n")
# We use wave 3, 4, 5 for numcult and friends
df_clpm <- df %>% select(id, numcult3, numcult4, numcult5, friends3, friends4, friends5) %>% drop_na()

riclpm_model <- '
  # Random Intercepts (Traits)
  RI_cult =~ 1*numcult3 + 1*numcult4 + 1*numcult5
  RI_frnd =~ 1*friends3 + 1*friends4 + 1*friends5
  
  # Within-person centered variables (States)
  wc3 =~ 1*numcult3; wf3 =~ 1*friends3
  wc4 =~ 1*numcult4; wf4 =~ 1*friends4
  wc5 =~ 1*numcult5; wf5 =~ 1*friends5
  
  # Fix error variances of observed to 0 (all variance moved to latents)
  numcult3 ~~ 0*numcult3; friends3 ~~ 0*friends3
  numcult4 ~~ 0*numcult4; friends4 ~~ 0*friends4
  numcult5 ~~ 0*numcult5; friends5 ~~ 0*friends5
  
  # Autoregressive paths
  wc4 ~ a1*wc3
  wc5 ~ a1*wc4
  wf4 ~ b1*wf3
  wf5 ~ b1*wf4
  
  # Cross-lagged paths
  wc4 ~ c1*wf3 # Network -> Culture
  wc5 ~ c1*wf4
  wf4 ~ d1*wc3 # Culture -> Network
  wf5 ~ d1*wc4
  
  # Covariances
  wc3 ~~ wf3
  wc4 ~~ wf4
  wc5 ~~ wf5
  RI_cult ~~ RI_frnd
'
tryCatch({
  fit_clpm <- sem(riclpm_model, data = df_clpm, missing = "ml")
  print(parameterEstimates(fit_clpm) %>% filter(op == "~") %>% select(lhs, op, rhs, est, se, pvalue))
}, error = function(e) { cat("Lavaan failed: ", e$message, "\n") })


# 3. Domain Specific Conversion
cat("\n--- 3. DOMAIN SPECIFIC CONVERSION ---\n")
# Does following sports predict memspor? Does reading predict mempriv/memserv?
df_domain <- df %>% select(id, sports3, books3, play3, hobby3, memspor4, mempriv4, memhobb4, memserv4) %>% drop_na()
# Note: lower sports/books score = higher frequency (1=Very often, 3=Seldom, 4=Never)
# For ease of interpretation, we'll invert them so higher = more
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
m_priv <- glm(mempriv ~ play + sports, data = df_domain, family=binomial)

cat("Predicting Sports Club:\n")
print(summary(m_spor)$coefficients[c("sports", "books", "hobby"), ])
cat("Predicting Hobby Club:\n")
print(summary(m_hobb)$coefficients[c("hobby", "sports", "books"), ])


# 4. Cultural Mobility vs Reproduction
cat("\n--- 4. MOBILITY VS REPRODUCTION ---\n")
# Interaction between numcult_mean and educ_mean
m_mob <- glmer(friends ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + 
                 numcult_mean * educ_mean + married_mean + childre_mean + bigcity_mean + female + white + 
                 as.factor(wave) + (1 | id), data = df_mundlak, family = poisson, control = glmerControl(optimizer = 'bobyqa'))
print(summary(m_mob)$coefficients[grepl("numcult_mean|educ_mean", rownames(summary(m_mob)$coefficients)), ])

