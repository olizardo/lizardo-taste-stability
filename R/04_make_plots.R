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
coefs <- data.frame(
  Outcome = rep(c("Friends\n(Ordinal)", "Org. Memberships\n(Count)", "Family\n(Ordinal)"), each = 2),
  EffectType = rep(c("Between-Person (Average)", "Within-Person (Spike)"), 3),
  Estimate = c(
    summary(m_friends)$coefficients["numcult_mean", "Estimate"],
    summary(m_friends)$coefficients["numcult_within", "Estimate"],
    summary(m_orgs)$coefficients["numcult_mean", "Estimate"],
    summary(m_orgs)$coefficients["numcult_within", "Estimate"],
    summary(m_family)$coefficients["numcult_mean", "Estimate"],
    summary(m_family)$coefficients["numcult_within", "Estimate"]
  ),
  SE = c(
    summary(m_friends)$coefficients["numcult_mean", "Std. Error"],
    summary(m_friends)$coefficients["numcult_within", "Std. Error"],
    summary(m_orgs)$coefficients["numcult_mean", "Std. Error"],
    summary(m_orgs)$coefficients["numcult_within", "Std. Error"],
    summary(m_family)$coefficients["numcult_mean", "Std. Error"],
    summary(m_family)$coefficients["numcult_within", "Std. Error"]
  )
)

coefs$Outcome <- factor(coefs$Outcome, levels = c("Friends\n(Ordinal)", "Family\n(Ordinal)", "Org. Memberships\n(Count)"))

p_unified <- ggplot(coefs, aes(x = Outcome, y = Estimate, fill = EffectType)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.6), width = 0.5) +
  geom_errorbar(aes(ymin = Estimate - 1.96*SE, ymax = Estimate + 1.96*SE), position = position_dodge(width = 0.6), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  theme_minimal() +
  labs(
    title = "Effects of Cultural Breadth on Network Connectivity", 
    subtitle = "Estimates (Log Link Scale) and 95% Confidence Intervals",
    y = "Coefficient Estimate", 
    x = "Outcome Variable", 
    fill = "Mundlak Effect"
  ) +
  theme(plot.title = element_text(hjust = 0.5), plot.subtitle = element_text(hjust = 0.5), legend.position = "bottom") +
  scale_fill_manual(values = c("Between-Person (Average)" = "#2c7bb6", "Within-Person (Spike)" = "#d7191c"))

ggsave(here("Plots", "unified_cultural_effects.png"), p_unified, width = 8, height = 5)

# 2. Kin vs Non-Kin Plot (from kin_script.R)
coefs_kin <- data.frame(
  Model = rep(c("Friends", "Family"), each = 2),
  EffectType = rep(c("Between-Person (Mean)", "Within-Person (Deviation)"), 2),
  Estimate = c(
    summary(m_friends)$coefficients["numcult_mean", "Estimate"],
    summary(m_friends)$coefficients["numcult_within", "Estimate"],
    summary(m_family)$coefficients["numcult_mean", "Estimate"],
    summary(m_family)$coefficients["numcult_within", "Estimate"]
  ),
  SE = c(
    summary(m_friends)$coefficients["numcult_mean", "Std. Error"],
    summary(m_friends)$coefficients["numcult_within", "Std. Error"],
    summary(m_family)$coefficients["numcult_mean", "Std. Error"],
    summary(m_family)$coefficients["numcult_within", "Std. Error"]
  )
)

p_kin <- ggplot(coefs_kin, aes(x = Model, y = Estimate, fill = EffectType)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.6), width = 0.5) +
  geom_errorbar(aes(ymin = Estimate - 1.96*SE, ymax = Estimate + 1.96*SE), position = position_dodge(width = 0.6), width = 0.2) +
  theme_minimal() +
  labs(title = "Effect of Cultural Capital on Interaction Frequency", y = "Log-Odds Estimate", x = "Tie Type", fill = "Effect Type") +
  theme(plot.title = element_text(hjust = 0.5), legend.position = "bottom") +
  scale_fill_manual(values = c("Between-Person (Mean)" = "#1f77b4", "Within-Person (Deviation)" = "#ff7f0e"))

ggsave(here("Plots", "kin_vs_nonkin.png"), p_kin, width = 7, height = 5)

cat("Plots generated successfully in Plots/.\n")
