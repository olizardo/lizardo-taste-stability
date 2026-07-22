# Load libraries
library(haven)
library(dplyr)
library(tidyr)
library(here)

cat("Running 01_data_processing.R...\n")

# 1. Load Data
df <- read_dta(here("PCS", "pc1980-85-90-95.dta"))

# 2. Rename variables
df <- df %>%
  rename(play3 = atplay3, mags2 = magazin2) %>%
  rename_with(~"play4", starts_with("play4"))

clean_cult <- function(x) {
  ifelse(x %in% c(0, 8, 9), NA, x)
}

cult_vars_base <- c("music", "movie", "sports", "paper", "books", "play", "spevent", "videos", "hobby", "tv", "mags", "friends")
cult_vars_w2 <- c("music2", "movie2", "sports2", "paper2", "books2", "spevent2", "hobby2", "mags2", "evefrnd2")
cult_vars_w3 <- paste0(cult_vars_base, "3")
cult_vars_w4 <- paste0(cult_vars_base, "4")
cult_vars_w5 <- paste0(cult_vars_base, "5")

df <- df %>%
  mutate(across(any_of(c(cult_vars_w2, cult_vars_w3, cult_vars_w4, cult_vars_w5)), clean_cult)) %>%
  mutate(across(any_of(cult_vars_w4), ~ case_match(., 4 ~ 2, 5 ~ 4, .default = .))) %>%
  mutate(across(any_of(cult_vars_w5), ~ case_match(., 1:3 ~ 1, 4:5 ~ 2, 6 ~ 3, 7 ~ 4, .default = .))) %>%
  mutate(
    friends3 = ifelse(friends3 == 4, 3, friends3),
    friends4 = ifelse(friends4 == 4, 3, friends4),
    friends5 = ifelse(friends5 == 4, 3, friends5)
  )

# Extract and Clean Family Variables (moved from analysis scripts)
df$family3 <- df$family3
df$family4 <- df$family4
df$family5 <- df$family5

df <- df %>%
  mutate(across(c(family3, family4, family5), clean_cult)) %>%
  mutate(across(c(family4), ~ case_match(., 4 ~ 3, 5 ~ 4, .default = .))) %>%
  mutate(across(c(family5), ~ case_match(., 1:3 ~ 1, 4:5 ~ 2, 6 ~ 3, 7 ~ 4, .default = .))) %>%
  mutate(
    family3 = ifelse(family3 == 4, 3, family3),
    family4 = ifelse(family4 == 4, 3, family4),
    family5 = ifelse(family5 == 4, 3, family5)
  )

# Clean demographics
df <- df %>%
  mutate(across(matches("^(marital|childre|friends|chorgs)[345]$"), ~ifelse(. == 0, NA, .))) %>%
  mutate(across(matches("^wrkstat[345]$"), ~case_match(.,
    0 ~ 6, 2 ~ 1, 3 ~ 2, 4 ~ 2, 5 ~ 3, 6 ~ 4, 7 ~ 5, 8 ~ 6, .default = .
  ))) %>%
  mutate(across(matches("^income[345]$"), ~ifelse(. == 0, 6, .))) %>%
  mutate(across(matches("^age[345]$"), ~case_when(
    . >= 19 & . <= 29 ~ 1,
    . >= 30 & . <= 44 ~ 2,
    . >= 45 & . <= 59 ~ 3,
    . >= 60 & . <= 100 ~ 4,
    TRUE ~ NA_real_
  ), .names = "{.col}grp")) %>%
  rename_with(~gsub("age([345])grp", "agegrp\\1", .), matches("age[345]grp"))

for (w in 3:5) {
  df[[paste0("white", w)]] <- ifelse(df[[paste0("race", w)]] == 1, 1, 0)
  df[[paste0("married", w)]] <- ifelse(df[[paste0("marital", w)]] == 1, 1, 0)
  df[[paste0("working", w)]] <- ifelse(df[[paste0("wrkstat", w)]] < 3, 1, 0)
  df[[paste0("female", w)]] <- ifelse(df[[paste0("gender", w)]] == 1, 1, 0)
  df[[paste0("college", w)]] <- ifelse(df[[paste0("educ", w)]] >= 4, 1, 0)
  df[[paste0("bigcity", w)]] <- ifelse(df[[paste0("categor", w)]] == 1, 1, 0)
}

df$female <- df$female3
df$white <- df$white3

# Calculate network/demographic change variables
change_vars <- c("marital", "childre", "wrkstat", "areanam", "friends", "income", "educ", "working", "married", "categor")
for (v in change_vars) {
  df[[paste0("chng", v, "4")]] <- ifelse(!is.na(df[[paste0(v, "3")]]) & !is.na(df[[paste0(v, "4")]]), df[[paste0(v, "3")]] != df[[paste0(v, "4")]], NA)
  df[[paste0("chng", v, "5")]] <- ifelse(!is.na(df[[paste0(v, "4")]]) & !is.na(df[[paste0(v, "5")]]), df[[paste0(v, "4")]] != df[[paste0(v, "5")]], NA)
}

socmem_vars <- c("mempriv", "memserv", "memspor", "memhobb")
df <- df %>%
  mutate(
    numsocmems3 = rowSums(select(., all_of(paste0(socmem_vars, "3"))) > 0, na.rm = TRUE),
    numsocmems4 = rowSums(select(., all_of(paste0(socmem_vars, "4"))) > 0, na.rm = TRUE),
    numsocmems5 = rowSums(select(., all_of(paste0(socmem_vars, "5"))) > 0, na.rm = TRUE)
  )
df$numsocmems3[is.na(df$mempriv3)] <- NA
df$numsocmems4[is.na(df$mempriv4)] <- NA
df$numsocmems5[is.na(df$mempriv5)] <- NA

df$chngorgs4 <- df$numsocmems4 != df$numsocmems3
df$chngorgs5 <- df$numsocmems5 != df$numsocmems4

# Create cultural breadth variables
df <- df %>%
  mutate(
    numcult2 = rowSums(select(., all_of(cult_vars_w2)) < 3, na.rm = TRUE),
    numcult3 = rowSums(select(., all_of(setdiff(cult_vars_w3, c("tv3", "friends3")))) < 3, na.rm = TRUE),
    numcult4 = rowSums(select(., all_of(setdiff(cult_vars_w4, c("tv4", "friends4")))) < 3, na.rm = TRUE),
    numcult5 = rowSums(select(., all_of(setdiff(cult_vars_w5, c("tv5", "friends5")))) < 3, na.rm = TRUE)
  )
df$numcult2[is.na(df$music2)] <- NA
df$numcult3[is.na(df$music3)] <- NA
df$numcult4[is.na(df$music4)] <- NA
df$numcult5[is.na(df$music5)] <- NA

# Reshape to long format and create Mundlak vars (moved from analysis scripts)
df_long <- df %>% 
  mutate(across(everything(), haven::zap_labels)) %>% 
  select(id, female, white, friends3, friends4, friends5, family3, family4, family5, numsocmems3, numsocmems4, numsocmems5, numcult3, numcult4, numcult5, educ3, educ4, educ5, married3, married4, married5, childre3, childre4, childre5, bigcity3, bigcity4, bigcity5, age3, age4, age5, working3, working4, working5) %>% 
  pivot_longer(cols = matches('3$|4$|5$'), names_to = c('.value', 'wave'), names_pattern = '(.*)(3|4|5)$') %>% 
  mutate(wave = as.numeric(wave)) %>% 
  mutate(across(c(friends, family, numsocmems, numcult, educ, married, childre, bigcity, age, working), ~ as.numeric(haven::zap_labels(.))))

df_mundlak <- df_long %>% 
  drop_na() %>% 
  group_by(id) %>% 
  mutate(across(c(numcult, educ, married, childre, bigcity, age, working), list(mean = ~ mean(., na.rm = TRUE), within = ~ . - mean(., na.rm = TRUE)))) %>% 
  ungroup()

df_mundlak$friends_ord <- factor(df_mundlak$friends, levels = c(3, 2, 1), labels=c("Seldom/Never", "Sometimes", "Very Often"), ordered = TRUE)
df_mundlak$family_ord <- factor(df_mundlak$family, levels = c(3, 2, 1), labels=c("Seldom/Never", "Sometimes", "Very Often"), ordered = TRUE)

saveRDS(df_mundlak, here("data", "pcs_cleaned_mundlak.rds"))
cat("Saved to data/pcs_cleaned_mundlak.rds\n")
