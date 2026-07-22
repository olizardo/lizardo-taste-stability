library(dplyr)
library(tidyr)
library(here)
df <- readRDS(here("R", "pcs_processed.rds"))
cultlist <- c("music", "sports", "paper", "books")

cat("--- 10-Year Cumulative Taste Loss (1985 -> 1995) ---\n")
for (c in cultlist) {
  df_sub <- df %>% filter(.data[[paste0(c, "3")]] == 1) %>% drop_na(paste0(c, "5"))
  n_at_risk <- nrow(df_sub)
  n_loss <- sum(df_sub[[paste0(c, "5")]] >= 3)
  cat(c, "- At risk:", n_at_risk, "| Lost by 1995:", n_loss, "| Loss Rate:", round(100*n_loss/n_at_risk, 2), "%\n")
}
