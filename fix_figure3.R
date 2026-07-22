library(dplyr)
library(lme4)
library(ggplot2)
library(here)

df <- readRDS(here("R", "pcs_processed.rds"))
df_long <- df %>% mutate(across(everything(), haven::zap_labels)) %>% 
  select(id, female, white, friends3, friends4, friends5, numsocmems3, numsocmems4, numsocmems5, numcult3, numcult4, numcult5, educ3, educ4, educ5, married3, married4, married5, childre3, childre4, childre5, bigcity3, bigcity4, bigcity5) %>% 
  pivot_longer(cols = matches("3$|4$|5$"), names_to = c(".value", "wave"), names_pattern = "(.*)(3|4|5)$") %>% 
  mutate(wave = as.numeric(wave)) %>% 
  mutate(across(c(friends, numsocmems, numcult, educ, married, childre, bigcity), ~ as.numeric(haven::zap_labels(.))))

df_mundlak <- df_long %>% drop_na() %>% group_by(id) %>% 
  mutate(across(c(numcult, educ, married, childre, bigcity), list(mean = ~ mean(., na.rm = TRUE), within = ~ . - mean(., na.rm = TRUE)))) %>% ungroup()

m_friends <- glmer(friends ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak, family = poisson, control = glmerControl(optimizer = 'bobyqa'))
m_orgs <- glmer(numsocmems ~ numcult_within + educ_within + married_within + childre_within + bigcity_within + numcult_mean + educ_mean + married_mean + childre_mean + bigcity_mean + female + white + as.factor(wave) + (1 | id), data = df_mundlak, family = poisson, control = glmerControl(optimizer = 'bobyqa'))

# Generate predicted margins over numcult_mean holding other vars at median/mode
nd <- df_mundlak %>% 
  summarise(
    numcult_within = 0, educ_within = 0, married_within = 0, childre_within = 0, bigcity_within = 0,
    educ_mean = median(educ_mean, na.rm=T),
    married_mean = median(married_mean, na.rm=T),
    childre_mean = median(childre_mean, na.rm=T),
    bigcity_mean = median(bigcity_mean, na.rm=T),
    female = 1, white = 1, wave = 3 # just fix factors to base level for plotting margin
  )

# Create sequence for numcult_mean (from 0 to 4 since it's now out of 4)
# (wait, numcult was 4 items, let's see its range)
rng <- range(df_mundlak$numcult_mean, na.rm=TRUE)
x_vals <- seq(rng[1], rng[2], length.out = 20)

pred_df <- data.frame()
for(x in x_vals) {
  nd_temp <- nd
  nd_temp$numcult_mean <- x
  
  # Predict for Friends
  # Re.form=NA means ignore random effects for population-level prediction
  # se.fit is not supported natively in predict.merMod, so we use bootMer or manual delta method.
  # For speed, we will approximate SEs using the fixed effect variance-covariance matrix
  
  # Function to get predictions and SEs for glmer
  get_pred <- function(model, newdata) {
    X <- model.matrix(terms(model), newdata)
    beta <- fixef(model)
    V <- vcov(model)
    fit_link <- X %*% beta
    se_link <- sqrt(diag(X %*% V %*% t(X)))
    
    fit_resp <- exp(fit_link)
    ci_lower <- exp(fit_link - 1.96 * se_link)
    ci_upper <- exp(fit_link + 1.96 * se_link)
    
    return(c(fit_resp, ci_lower, ci_upper))
  }
  
  f_res <- get_pred(m_friends, nd_temp)
  o_res <- get_pred(m_orgs, nd_temp)
  
  pred_df <- rbind(pred_df, data.frame(
    Cultural_Breadth_Mean = x,
    Outcome = "Friends",
    Predicted_Count = f_res[1],
    CI_Low = f_res[2],
    CI_High = f_res[3]
  ))
  pred_df <- rbind(pred_df, data.frame(
    Cultural_Breadth_Mean = x,
    Outcome = "Orgs",
    Predicted_Count = o_res[1],
    CI_Low = o_res[2],
    CI_High = o_res[3]
  ))
}

p3 <- ggplot(pred_df, aes(x = Cultural_Breadth_Mean, y = Predicted_Count, color = Outcome, fill = Outcome)) +
  geom_line(linewidth = 1.2) +
  geom_ribbon(aes(ymin = CI_Low, ymax = CI_High), alpha = 0.2, color = NA) +
  scale_color_manual(values = c("Friends" = "#E69F00", "Orgs" = "#56B4E9"),
                     labels = c("Friends" = "Interaction with Friends", "Orgs" = "Organizational Memberships")) +
  scale_fill_manual(values = c("Friends" = "#E69F00", "Orgs" = "#56B4E9"),
                    labels = c("Friends" = "Interaction with Friends", "Orgs" = "Organizational Memberships")) +
  labs(
    title = "Cultural Breadth Sustains Social Connectivity Over Time",
    subtitle = "Predicted counts (with 95% CIs) from Mundlak Between-Person Effects",
    x = "Average Cultural Taste Breadth (0-4)",
    y = "Predicted Count",
    color = "Connectivity Measure",
    fill = "Connectivity Measure"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom", plot.title = element_text(face="bold"))

ggsave("tex/cultural_conversion_effects.png", p3, width = 8, height = 5)
