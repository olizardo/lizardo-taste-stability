library(dplyr)
library(lme4)
library(modelsummary)
library(here)
library(kableExtra)
options(modelsummary_factory_latex = 'kableExtra')

# Read processing script
lines <- readLines(here("R", "pcs-analysis-modern.R"))
# Find the m_friends line
idx <- grep("m_friends <- glmer\\(friends ~.*family = poisson", lines)
if (length(idx) > 0) {
  lines[idx] <- gsub("glmer\\(", "lmer\\(", lines[idx])
  lines[idx] <- gsub(", family = poisson, control = glmerControl\\(optimizer = 'bobyqa'\\)", "", lines[idx])
}
# Find the m2 modelsummary title
idx_title <- grep("Mundlak Poisson Models for Network Connectivity", lines)
if (length(idx_title) > 0) {
  lines[idx_title] <- "  title = 'Mundlak Mixed-Effects Models for Network Connectivity (1985-1995)',"
}
writeLines(lines, here("R", "pcs-analysis-modern.R"))
