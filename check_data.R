library(dplyr)
library(tidyr)
library(here)

df <- readRDS(here("R", "pcs_processed.rds"))
cultlist <- c("music", "movie", "play", "sports", "paper", "books", "spevent", "videos", "hobby", "mags")
controls <- c("agegrp", "educ", "income", "married", "childre", "working", "bigcity")
demchang <- c("chngfriends", "chngorgs", "chngeduc", "chngmarital", "chngchildre", "chngwrkstat", "chngareanam")

cat("Total rows in df:", nrow(df), "\n")

# Check NA counts for wave 3, 4, 5 variables
cat("\nNAs in control variables (Wave 3):\n")
print(colSums(is.na(df %>% select(all_of(paste0(controls, "3"))))))

cat("\nNAs in demchang variables (Wave 4):\n")
print(colSums(is.na(df %>% select(all_of(paste0(demchang, "4"))))))

cat("\nNAs in demchang variables (Wave 5):\n")
print(colSums(is.na(df %>% select(all_of(paste0(demchang, "5"))))))

cat("\nCheck specific cult variable (music3):\n")
print(table(df$music3, useNA="always"))
