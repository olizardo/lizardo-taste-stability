library(ggplot2)
library(dplyr)
library(here)
library(ordinal)
library(lme4)

cat("Running 04_make_plots.R...\n")

# Read models
m_friends <- readRDS(here("models", "m_friends.rds"))
m_family  <- readRDS(here("models", "m_family.rds"))
m_orgs    <- readRDS(here("models", "m_orgs.rds"))

# 1. Unified Cultural Effects Plot
# Because we now have three separate PCA factors, we need to extract effects for each
coef_names <- c("pca_read", "pca_sports", "pca_arts")
labels <- c("Reading/Homebound (RC1)", "Sports Culture (RC2)", "Arts/Entertainment (RC3)")

coefs_list <- list()

for (i in 1:3) {
  var_mean <- paste0(coef_names[i], "_mean")
  var_within <- paste0(coef_names[i], "_within")
  
  df_temp <- data.frame(
    Outcome = rep(c("Friends\n(Ordinal)", "Org. Memberships\n(Count)", "Family\n(Ordinal)"), each = 2),
    EffectType = rep(c("Between-Person (Average)", "Within-Person (Spike)"), 3),
    Component = labels[i],
    Estimate = c(
      summary(m_friends)$coefficients[var_mean, "Estimate"],
      summary(m_friends)$coefficients[var_within, "Estimate"],
      summary(m_orgs)$coefficients[var_mean, "Estimate"],
      summary(m_orgs)$coefficients[var_within, "Estimate"],
      summary(m_family)$coefficients[var_mean, "Estimate"],
      summary(m_family)$coefficients[var_within, "Estimate"]
    ),
    SE = c(
      summary(m_friends)$coefficients[var_mean, "Std. Error"],
      summary(m_friends)$coefficients[var_within, "Std. Error"],
      summary(m_orgs)$coefficients[var_mean, "Std. Error"],
      summary(m_orgs)$coefficients[var_within, "Std. Error"],
      summary(m_family)$coefficients[var_mean, "Std. Error"],
      summary(m_family)$coefficients[var_within, "Std. Error"]
    )
  )
  coefs_list[[i]] <- df_temp
}

coefs <- do.call(rbind, coefs_list)

coefs$Outcome <- factor(coefs$Outcome, levels = c("Friends\n(Ordinal)", "Family\n(Ordinal)", "Org. Memberships\n(Count)"))

p_unified <- ggplot(coefs, aes(x = Component, y = Estimate, fill = EffectType)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.6), width = 0.5) +
  geom_errorbar(aes(ymin = Estimate - 1.96*SE, ymax = Estimate + 1.96*SE), position = position_dodge(width = 0.6), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  coord_flip() +
  theme_minimal() +
  facet_wrap(~Outcome) +
  labs(
    title = "Effects of Cultural Dimensions on Network Connectivity", 
    subtitle = "Estimates (Log Link Scale) and 95% Confidence Intervals",
    y = "Coefficient Estimate", 
    x = "Cultural Dimension (PCA Component)", 
    fill = "Mundlak Effect"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, face="bold"), 
    plot.subtitle = element_text(hjust = 0.5), 
    legend.position = "bottom"
  ) +
  scale_fill_manual(values = c("Between-Person (Average)" = "#2c7bb6", "Within-Person (Spike)" = "#d7191c"))

ggsave(here("Plots", "unified_cultural_effects.png"), p_unified, width = 10, height = 5)

cat("Plots generated successfully in Plots/.\n")
