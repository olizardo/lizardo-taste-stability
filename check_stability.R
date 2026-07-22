library(dplyr)
library(tidyr)
library(here)

df <- readRDS(here("R", "pcs_processed.rds"))
cultlist <- c("music", "movie", "play", "sports", "paper", "books", "spevent", "videos", "hobby", "mags")

p1 <- df %>% select(id, all_of(paste0(cultlist, "3")), all_of(paste0(cultlist, "4"))) %>% mutate(period = 1) %>% rename_with(~gsub("3$", "_start", .), ends_with("3")) %>% rename_with(~gsub("4$", "_end", .), ends_with("4"))
p2 <- df %>% select(id, all_of(paste0(cultlist, "4")), all_of(paste0(cultlist, "5"))) %>% mutate(period = 2) %>% rename_with(~gsub("4$", "_start", .), ends_with("4")) %>% rename_with(~gsub("5$", "_end", .), ends_with("5"))
df_transitions <- bind_rows(p1, p2)

cat("Actual Retention Rates (Pooled 5-Year Windows: 85->90 & 90->95)\n")
cat("Defined as: Starting at '1' (Very Often) and NOT dropping to '3' or '4' (Seldom/Never)\n\n")

results <- data.frame(Activity = character(), Retention = numeric(), N_At_Risk = numeric())

for (c in cultlist) {
  df_sub <- df_transitions %>% filter(.data[[paste0(c, "_start")]] == 1) %>% drop_na(paste0(c, "_end"))
  
  if(nrow(df_sub) > 0) {
    n_at_risk <- nrow(df_sub)
    n_loss <- sum(df_sub[[paste0(c, "_end")]] >= 3)
    retention_pct <- 100 * (1 - (n_loss / n_at_risk))
    
    results <- rbind(results, data.frame(Activity = c, Retention = retention_pct, N_At_Risk = n_at_risk))
  }
}

print(results)
