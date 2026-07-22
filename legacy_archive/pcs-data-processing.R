# Load libraries
library(haven)
library(dplyr)
library(tidyr)
library(lme4)
library(survival)
library(modelsummary)
library(here)

# 1. Load Data
# Using the full 1980-85-90-95 dataset
df <- read_dta(here("PCS", "pc1980-85-90-95.dta"))

# Rename variables to match standard names across waves where inconsistent
df <- df %>%
  rename(play3 = atplay3, mags2 = magazin2) %>%
  # Handle play4 which exists but is named play4
  rename_with(~"play4", starts_with("play4")) # just in case

# Define function to clean culture variables (0, 8, 9 to NA)
clean_cult <- function(x) {
  ifelse(x %in% c(0, 8, 9), NA, x)
}

# Culture variables for waves 2 (1980), 3 (1985), 4 (1990), 5 (1995)
cult_vars_base <- c("music", "movie", "sports", "paper", "books", "play", "spevent", "videos", "hobby", "tv", "mags", "friends")
# Note: wave 2 is missing videos, play, and tv?
cult_vars_w2 <- c("music2", "movie2", "sports2", "paper2", "books2", "spevent2", "hobby2", "mags2", "evefrnd2")
cult_vars_w3 <- paste0(cult_vars_w34 <- cult_vars_base, "3")
cult_vars_w4 <- paste0(cult_vars_base, "4")
# Wave 5 actually has all these too
cult_vars_w5 <- paste0(cult_vars_base, "5")

df <- df %>%
  # Apply basic missing value cleaning to all culture vars
  mutate(across(any_of(c(cult_vars_w2, cult_vars_w3, cult_vars_w4, cult_vars_w5)), clean_cult)) %>%
  # Harmonize Wave 4 scales (4=Monthly -> 3 Seldom, 5=Hardly/Never -> 4 Never)
  mutate(across(any_of(cult_vars_w4), ~ case_match(., 4 ~ 3, 5 ~ 4, .default = .))) %>%
  # Harmonize Wave 5 scales (1-3 -> 1, 4-5 -> 2, 6 -> 3, 7 -> 4)
  mutate(across(any_of(cult_vars_w5), ~ case_match(., 1:3 ~ 1, 4:5 ~ 2, 6 ~ 3, 7 ~ 4, .default = .))) %>%
  # Handle friends recoding specifically since its categories often differ
  mutate(
    friends3 = ifelse(friends3 == 4, 3, friends3),
    friends4 = ifelse(friends4 == 4, 3, friends4),
    friends5 = ifelse(friends5 == 4, 3, friends5)
  )

# Clean demographics: recode 0 to NA
df <- df %>%
  mutate(across(matches("^(marital|childre|friends|chorgs)[345]$"), ~ifelse(. == 0, NA, .))) %>%
  # Work status recoding
  mutate(across(matches("^wrkstat[345]$"), ~case_match(.,
    0 ~ 6, 2 ~ 1, 3 ~ 2, 4 ~ 2, 5 ~ 3, 6 ~ 4, 7 ~ 5, 8 ~ 6, .default = .
  ))) %>%
  # Income recoding
  mutate(across(matches("^income[345]$"), ~ifelse(. == 0, 6, .))) %>%
  # Age groups
  mutate(across(matches("^age[345]$"), ~case_when(
    . >= 19 & . <= 29 ~ 1,
    . >= 30 & . <= 44 ~ 2,
    . >= 45 & . <= 59 ~ 3,
    . >= 60 & . <= 100 ~ 4,
    TRUE ~ NA_real_
  ), .names = "{.col}grp")) %>%
  rename_with(~gsub("age([345])grp", "agegrp\\1", .), matches("age[345]grp"))

# Create dummy demographics for all waves
for (w in 3:5) {
  df[[paste0("white", w)]] <- ifelse(df[[paste0("race", w)]] == 1, 1, 0)
  df[[paste0("married", w)]] <- ifelse(df[[paste0("marital", w)]] == 1, 1, 0)
  df[[paste0("working", w)]] <- ifelse(df[[paste0("wrkstat", w)]] < 3, 1, 0)
  df[[paste0("female", w)]] <- ifelse(df[[paste0("gender", w)]] == 1, 1, 0)
  df[[paste0("college", w)]] <- ifelse(df[[paste0("educ", w)]] >= 4, 1, 0)
  df[[paste0("bigcity", w)]] <- ifelse(df[[paste0("categor", w)]] == 1, 1, 0)
}
# Keep a time-invariant gender and race from wave 3
df$female <- df$female3
df$white <- df$white3

# Calculate network/demographic change variables (e.g. 3->4, 4->5)
# To do this cleanly for a panel, we don't strictly need wide change vars anymore, but we'll compute them for the transition logits.
# We'll create chng_var_4 (change from 3 to 4) and chng_var_5 (change from 4 to 5)
change_vars <- c("marital", "childre", "wrkstat", "areanam", "friends", "income", "educ", "working", "married", "categor")
for (v in change_vars) {
  df[[paste0("chng", v, "4")]] <- ifelse(!is.na(df[[paste0(v, "3")]]) & !is.na(df[[paste0(v, "4")]]), df[[paste0(v, "3")]] != df[[paste0(v, "4")]], NA)
  df[[paste0("chng", v, "5")]] <- ifelse(!is.na(df[[paste0(v, "4")]]) & !is.na(df[[paste0(v, "5")]]), df[[paste0(v, "4")]] != df[[paste0(v, "5")]], NA)
}
# Also chorgs (which already has chorgs4, let's make sure we have chorgs5)
# Actually, the original dataset has chorgs4. For wave 5, we might need to manually compute membership changes if chorgs5 doesn't exist.
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

# Create cultural breadth variables (numcult2, 3, 4, 5)
# Score < 3 means Very Often or Sometimes
# Exclude tv and friends from the breadth index
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

# 3. Save processed data for analysis
saveRDS(df, here("R", "pcs_processed.rds"))
