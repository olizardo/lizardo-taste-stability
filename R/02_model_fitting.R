library(lme4)
library(ordinal)
library(here)

cat("Running 02_model_fitting.R...\n")

df_mundlak <- readRDS(here("data", "pcs_cleaned_mundlak.rds"))

controls_within <- c("educ_within", "married_within", "childre_within", "bigcity_within", "working_within", "age_within")
controls_mean <- c("educ_mean", "married_mean", "childre_mean", "bigcity_mean", "working_mean", "age_mean")
controls_static <- c("female", "white", "as.factor(wave)")

formula_base <- paste(
  "pca_read_within + pca_sports_within + pca_arts_within +",
  "pca_read_mean + pca_sports_mean + pca_arts_mean +",
  paste(controls_within, collapse=" + "), "+",
  paste(controls_mean, collapse=" + "), "+",
  paste(controls_static, collapse=" + "), "+ (1 | id)"
)

# 1. Friends Model
cat("Fitting m_friends...\n")
m_friends <- clmm(as.formula(paste("friends_ord ~", formula_base)), data = df_mundlak)

# 2. Family Model
cat("Fitting m_family...\n")
m_family <- clmm(as.formula(paste("family_ord ~", formula_base)), data = df_mundlak)

# 3. Organizations Model
cat("Fitting m_orgs...\n")
m_orgs <- glmer(as.formula(paste("numsocmems ~", formula_base)), data = df_mundlak, family = poisson, control = glmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=1e5)))

saveRDS(m_friends, here("models", "m_friends.rds"))
saveRDS(m_family, here("models", "m_family.rds"))
saveRDS(m_orgs, here("models", "m_orgs.rds"))

cat("Models saved to models/ directory.\n")
