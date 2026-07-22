library(dplyr)
library(tidyr)
df <- readRDS("R/pcs_processed.rds")
cultlist <- c("music", "movie", "play", "sports", "paper", "books", "spevent", "videos", "hobby", "mags")
controls <- c("agegrp", "educ", "income", "married", "childre", "working", "bigcity")
demchang <- c("chngfriends", "chngorgs", "chngeduc", "chngmarital", "chngchildre", "chngwrkstat", "chngareanam")

p1 <- df %>% select(id, female, white,
                    all_of(paste0(cultlist, "3")), all_of(paste0(cultlist, "4")),
                    all_of(paste0(controls, "3")),
                    all_of(paste0(demchang, "4"))) %>%
             mutate(period = 1) %>%
             rename_with(~gsub("3$", "_start", .), ends_with("3")) %>%
             rename_with(~gsub("4$", "_end", .), ends_with("4"))

p2 <- df %>% select(id, female, white,
                    all_of(paste0(cultlist, "4")), all_of(paste0(cultlist, "5")),
                    all_of(paste0(controls, "4")),
                    all_of(paste0(demchang, "5"))) %>%
             mutate(period = 2) %>%
             rename_with(~gsub("4$", "_start", .), ends_with("4")) %>%
             rename_with(~gsub("5$", "_end", .), ends_with("5"))

df_transitions <- bind_rows(p1, p2)

for (c in cultlist) {
  df_sub <- df_transitions %>%
    filter(.data[[paste0(c, "_start")]] == 1) %>%
    mutate(event = ifelse(.data[[paste0(c, "_end")]] >= 3, 1, 0)) %>%
    drop_na(event, all_of(paste0(controls, "_start")), all_of(paste0(demchang, "_end")))
  
  cat(c, "n =", nrow(df_sub), "events =", sum(df_sub$event), "periods =", length(unique(df_sub$period)), "\n")
  if (nrow(df_sub) > 0) {
      for (v in c(paste0(demchang, "_end"), paste0(controls, "_start"), "female", "white")) {
          if (length(unique(df_sub[[v]])) < 2) {
              cat("  -> No variance in", v, "\n")
          }
      }
  }
}
