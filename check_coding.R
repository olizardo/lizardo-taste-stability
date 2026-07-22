library(haven)
library(dplyr)
df <- read_dta("PCS/pc1980-85-90-95.dta")

cult_vars_base <- c("music", "movie", "sports", "paper", "books", "play", "spevent", "videos", "hobby", "mags")
waves <- c(2, 3, 4, 5)

for (wave in waves) {
  cat("\n=== Wave", wave, "===\n")
  for (var in cult_vars_base) {
    vname <- paste0(var, wave)
    if (vname %in% names(df)) {
      cat(vname, "- labels:\n")
      print(attr(df[[vname]], "labels"))
      cat("Value counts:\n")
      print(table(df[[vname]], useNA="ifany"))
    } else {
      cat(vname, "NOT FOUND\n")
    }
  }
}

