library(lme4)
library(ordinal)
library(here)

cat("Running 02_model_fitting.R...\n")

df_mundlak <- readRDS(here("data", "pcs_cleaned_mundlak.rds"))

# 1. Friends Model
cat("Fitting m_friends...\n")
m_friends <- clmm(friends_ord ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + working_within + age_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + working_mean + age_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak)

# 2. Family Model
cat("Fitting m_family...\n")
m_family <- clmm(family_ord ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + working_within + age_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + working_mean + age_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak)

# 3. Organizations Model
cat("Fitting m_orgs...\n")
m_orgs <- glmer(numsocmems ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + working_within + age_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + working_mean + age_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak, family = poisson, control = glmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=1e5)))

saveRDS(m_friends, here("models", "m_friends.rds"))
saveRDS(m_family, here("models", "m_family.rds"))
saveRDS(m_orgs, here("models", "m_orgs.rds"))

cat("Models saved to models/ directory.\n")
