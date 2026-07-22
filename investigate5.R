library(dplyr)
library(haven)
library(here)

raw_pcs <- read_spss(here("PCS", "ZA4753_v1-1-0.sav"))
cat("Raw movie3:\n")
print(table(raw_pcs$V250, useNA="always"))
cat("Raw movie4:\n")
print(table(raw_pcs$V351, useNA="always"))
