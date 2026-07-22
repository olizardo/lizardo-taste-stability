library(dplyr)
library(here)

df <- readRDS(here("R", "pcs_processed.rds"))
cat("numsocmems3:\n")
print(table(df$numsocmems3, useNA="always"))

cat("\nfriends3 labels:\n")
print(attr(df$friends3, "labels"))
