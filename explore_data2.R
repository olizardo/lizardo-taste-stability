library(haven)
library(dplyr)
df <- read_dta("PCS/pc1980-85-90-95.dta")

cat("Vars for wave 5 (1995):\n")
print(grep("5$", colnames(df), value=TRUE))

cat("\nCheck culture variables for wave 5:\n")
cult_vars_base <- c("music", "movie", "sports", "paper", "books", "play", "spevent", "videos", "hobby", "tv", "mags", "friends")
print(paste0(cult_vars_base, "5") %in% colnames(df))
print(paste0(cult_vars_base, "5")[!paste0(cult_vars_base, "5") %in% colnames(df)])

cat("\nCheck socio-demographics for wave 5:\n")
demo_base <- c("marital", "childre", "wrkstat", "areanam", "friends", "income", "educ", "categor", "race", "gender", "age")
print(paste0(demo_base, "5") %in% colnames(df))

cat("\nCheck socmem for wave 5:\n")
socmem_vars_base <- c("mempriv", "memserv", "memspor", "memhobb")
print(paste0(socmem_vars_base, "5") %in% colnames(df))
