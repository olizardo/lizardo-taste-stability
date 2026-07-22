library(dplyr)
library(tidyr)
library(lme4)
library(modelsummary)
library(lmtest)
library(sandwich)
library(here)

df <- readRDS(here('R', 'pcs_processed.rds'))

cultlist <- c('music', 'sports', 'paper', 'books')
controls <- c('agegrp', 'educ', 'income', 'married', 'childre', 'working', 'bigcity')
demchang <- c('chngfriends', 'chngorgs', 'chngeduc', 'chngmarital', 'chngchildre', 'chngwrkstat', 'chngareanam')

p1 <- df %>% select(id, female, white, all_of(paste0(cultlist, '3')), all_of(paste0(cultlist, '4')), all_of(paste0(controls, '3')), all_of(paste0(demchang, '4'))) %>% mutate(period = 1) %>% rename_with(~gsub('3$', '_start', .), ends_with('3')) %>% rename_with(~gsub('4$', '_end', .), ends_with('4'))
p2 <- df %>% select(id, female, white, all_of(paste0(cultlist, '4')), all_of(paste0(cultlist, '5')), all_of(paste0(controls, '4')), all_of(paste0(demchang, '5'))) %>% mutate(period = 2) %>% rename_with(~gsub('4$', '_start', .), ends_with('4')) %>% rename_with(~gsub('5$', '_end', .), ends_with('5'))
df_transitions <- bind_rows(p1, p2)

logit_models <- list()
for (c in cultlist) {
  df_sub <- df_transitions %>% filter(.data[[paste0(c, '_start')]] == 1) %>% mutate(event = ifelse(.data[[paste0(c, '_end')]] >= 3, 1, 0)) %>% drop_na(event, all_of(paste0(controls, '_start')), all_of(paste0(demchang, '_end')))
  if (nrow(df_sub) > 0) {
    vars_to_check <- c(paste0(demchang, '_end'), paste0(controls, '_start'), 'female', 'white', 'period')
    valid_vars <- c()
    for (v in vars_to_check) {
      if (length(unique(df_sub[[v]])) > 1) {
        if (v == 'period') { valid_vars <- c(valid_vars, 'as.factor(period)') } else { valid_vars <- c(valid_vars, v) }
      }
    }
    if (length(valid_vars) > 0) {
       f_str <- paste('event ~', paste(valid_vars, collapse=' + '))
       m <- glm(as.formula(f_str), data = df_sub, family = binomial(link='logit'))
       logit_models[[c]] <- m
    }
  }
}

for(c in names(logit_models)) {
  cat("\n---", c, "---\n")
  print(coeftest(logit_models[[c]], vcov = vcovCL(logit_models[[c]], cluster = logit_models[[c]]$data$id)))
}
