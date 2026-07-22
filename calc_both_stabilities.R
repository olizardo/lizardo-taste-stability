library(dplyr)
library(tidyr)
library(here)

df <- readRDS(here("R", "pcs_processed.rds"))
cultlist <- c("music", "sports", "paper", "books")

p1 <- df %>% select(id, all_of(paste0(cultlist, "3")), all_of(paste0(cultlist, "4"))) %>% mutate(period = 1) %>% rename_with(~gsub("3$", "_start", .), ends_with("3")) %>% rename_with(~gsub("4$", "_end", .), ends_with("4"))
p2 <- df %>% select(id, all_of(paste0(cultlist, "4")), all_of(paste0(cultlist, "5"))) %>% mutate(period = 2) %>% rename_with(~gsub("4$", "_start", .), ends_with("4")) %>% rename_with(~gsub("5$", "_end", .), ends_with("5"))
df_transitions <- bind_rows(p1, p2)

results <- data.frame(Activity = character(), N_At_Risk = numeric(), 
                      Weak_Loss_N = numeric(), Weak_Retention_Pct = numeric(),
                      Strong_Loss_N = numeric(), Strong_Retention_Pct = numeric())

for (c in cultlist) {
  df_sub <- df_transitions %>% 
    filter(.data[[paste0(c, "_start")]] == 1) %>% 
    drop_na(paste0(c, "_end"))
  
  if(nrow(df_sub) > 0) {
    n_at_risk <- nrow(df_sub)
    
    # Weaker definition: from "Very Often" (1) to "Seldom" (3) or "Never" (4)
    n_loss_weak <- sum(df_sub[[paste0(c, "_end")]] >= 3)
    retention_weak <- 100 * (1 - (n_loss_weak / n_at_risk))
    
    # Strong definition: from "Very Often" (1) to "Never" (4)
    n_loss_strong <- sum(df_sub[[paste0(c, "_end")]] == 4)
    retention_strong <- 100 * (1 - (n_loss_strong / n_at_risk))
    
    results <- rbind(results, data.frame(
      Activity = c, 
      N_At_Risk = n_at_risk, 
      Weak_Loss_N = n_loss_weak,
      Weak_Retention_Pct = round(retention_weak, 2),
      Strong_Loss_N = n_loss_strong,
      Strong_Retention_Pct = round(retention_strong, 2)
    ))
  }
}

print(results)
