# Load libraries
library(haven)
library(dplyr)
library(tidyr)
library(lme4)
library(survival)
library(modelsummary)
library(here)

# 1. Load Data
# Using the 1980-85-90 dataset as specified in the manuscript
df <- read_dta(here("PCS", "pc1980-85-90.dta"))

# 2. Data Processing (porting dataproc-80-85-90.do)
df <- df %>%
  rename(play3 = atplay3, mags2 = magazin2)

# Define function to clean culture variables
# In Stata: recode 0=. 8/9=.
clean_cult <- function(x) {
  ifelse(x %in% c(0, 8, 9), NA, x)
}

# Culture variables for waves 2, 3, 4 (1980, 1985, 1990)
cult_vars_w2 <- c("music2", "movie2", "sports2", "paper2", "books2", "spevent2", "hobby2", "mags2", "evefrnd2")
cult_vars_w34 <- c("music", "movie", "sports", "paper", "books", "play", "spevent", "videos", "hobby", "tv", "mags", "friends")
cult_vars_w3 <- paste0(cult_vars_w34, "3")
cult_vars_w4 <- paste0(cult_vars_w34, "4")

df <- df %>%
  mutate(across(all_of(c(cult_vars_w2, cult_vars_w3, cult_vars_w4)), clean_cult)) %>%
  # Clean demographics: recode 0 to NA for marital, childre, friends, chorgs
  mutate(across(starts_with("marital") | starts_with("childre") | starts_with("friends") | starts_with("chorgs"), 
                ~ifelse(. == 0, NA, .))) %>%
  # Work status recoding
  mutate(across(starts_with("wrkstat"), ~case_match(.,
    0 ~ 6, 2 ~ 1, 3 ~ 2, 4 ~ 2, 5 ~ 3, 6 ~ 4, 7 ~ 5, 8 ~ 6, .default = .
  ))) %>%
  # friends3 recode
  mutate(friends3 = ifelse(friends3 == 4, 3, friends3)) %>%
  # Demographics indicators
  mutate(
    white = ifelse(race3 == 1, 1, 0),
    married4 = ifelse(marital4 == 1, 1, 0),
    married3 = ifelse(marital3 == 1, 1, 0),
    working4 = ifelse(wrkstat4 < 3, 1, 0),
    working3 = ifelse(wrkstat3 < 3, 1, 0),
    female = ifelse(gender3 == 1, 1, 0),
    college3 = ifelse(educ3 >= 4, 1, 0),
    college4 = ifelse(educ4 >= 4, 1, 0),
    bigcity3 = ifelse(categor3 == 1, 1, 0),
    bigcity4 = ifelse(categor4 == 1, 1, 0)
  ) %>%
  # Income recode
  mutate(across(starts_with("income"), ~ifelse(. == 0, 6, .)))

# Calculate change variables
change_vars <- c("marital", "childre", "wrkstat", "areanam", "friends", "income", "educ", "college", "working", "married", "categor")
for (v in change_vars) {
  var3 <- paste0(v, "3")
  var4 <- paste0(v, "4")
  df[[paste0("chng", v)]] <- ifelse(!is.na(df[[var3]]) & !is.na(df[[var4]]), df[[var3]] != df[[var4]], NA)
}
# Drop if any change var is NA
df <- df %>% filter(complete.cases(select(., starts_with("chng"))))

# Age groups
df <- df %>%
  mutate(agegrp3 = case_when(
    age3 >= 19 & age3 <= 29 ~ 1,
    age3 >= 30 & age3 <= 44 ~ 2,
    age3 >= 45 & age3 <= 59 ~ 3,
    age3 >= 60 & age3 <= 100 ~ 4,
    TRUE ~ NA_real_
  ))

# Create cultural breadth variables (numcult2, numcult3, numcult4)
df <- df %>%
  mutate(
    numcult2 = rowSums(select(., all_of(cult_vars_w2)) < 3, na.rm = TRUE),
    numcult3 = rowSums(select(., all_of(setdiff(cult_vars_w3, c("tv3", "friends3")))) < 3, na.rm = TRUE),
    numcult4 = rowSums(select(., all_of(setdiff(cult_vars_w4, c("tv4", "friends4")))) < 3, na.rm = TRUE)
  )

# Add NAs back if music variable is missing (matching Stata logic)
df$numcult2[is.na(df$music2)] <- NA
df$numcult3[is.na(df$music3)] <- NA
df$numcult4[is.na(df$music4)] <- NA

# Create numsocmems variables (from dataproc-80-85-90.do)
socmem_vars_w3 <- c("mempriv3", "memserv3", "memspor3", "memhobb3")
socmem_vars_w4 <- c("mempriv4", "memserv4", "memspor4", "memhobb4")

df <- df %>%
  mutate(
    numsocmems3 = rowSums(select(., all_of(socmem_vars_w3)) > 0, na.rm = TRUE),
    numsocmems4 = rowSums(select(., all_of(socmem_vars_w4)) > 0, na.rm = TRUE)
  )
df$numsocmems3[is.na(df$mempriv3)] <- NA
df$numsocmems4[is.na(df$mempriv4)] <- NA

# 3. Save processed data for analysis
saveRDS(df, here("R", "pcs_processed.rds"))
