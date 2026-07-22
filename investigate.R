library(dplyr)
library(tidyr)
library(lme4)
library(here)

df <- readRDS(here("R", "pcs_processed.rds"))

# Check numcult
cat("Summary of numcult3:\n")
print(summary(df$numcult3))
cat("\nSummary of friends3:\n")
print(summary(df$friends3))

# Is numcult highly correlated with friends?
cor_val <- cor(as.numeric(df$numcult3), as.numeric(df$friends3), use="complete.obs")
cat("\nCorrelation between numcult3 and friends3:", cor_val, "\n")

# Check scoring of cultural variables
cat("\nTable of music3:\n")
print(table(df$music3))

cat("\nTable of friends3:\n")
print(table(df$friends3))

