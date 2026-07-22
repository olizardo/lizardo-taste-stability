library(modelsummary)
library(dplyr)
library(here)
library(lme4)
library(ordinal)

cat("Running 03_make_tables.R...\n")

options(modelsummary_factory_latex = 'kableExtra')

# Data needed for descriptives
df_mundlak <- readRDS(here("data", "pcs_cleaned_mundlak.rds"))

# Read models
m_friends <- readRDS(here("models", "m_friends.rds"))
m_family  <- readRDS(here("models", "m_family.rds"))
m_orgs    <- readRDS(here("models", "m_orgs.rds"))

# Custom glance methods
glance_custom.clmm <- function(x, ...) {
  var_id <- x$ST[[1]][1]^2
  icc <- var_id / (var_id + (pi^2 / 3))
  data.frame(
    `Between-Person Variance` = var_id,
    `ICC (Between Prop.)` = icc,
    check.names = FALSE
  )
}
glance_custom.glmerMod <- function(x, ...) {
  var_id <- as.numeric(lme4::VarCorr(x)$id)
  data.frame(
    `Between-Person Variance` = var_id,
    check.names = FALSE
  )
}

# 1. Main Network Stability Table
modelsummary(
  list('Friends' = m_friends, 'Kin' = m_family, 'Org. Mem.' = m_orgs),
  align = 'lccc',
  estimate = '{estimate}{stars}', statistic = NULL, stars = c('+' = 0.1, '*' = 0.05, '**' = 0.01),
  coef_rename = c('numcult_mean' = 'Cultural Breadth (Between)', 'educ_mean' = 'Education (Between)', 'married_mean' = 'Married (Between)', 'childre_mean' = 'Children (Between)', 'bigcity_mean' = 'Big City (Between)', 'working_mean' = 'Employed (Between)', 'age_mean' = 'Age (Between)', 'numcult_within' = 'Cultural Breadth (Within)', 'educ_within' = 'Education (Within)', 'married_within' = 'Married (Within)', 'childre_within' = 'Children (Within)', 'bigcity_within' = 'Big City (Within)', 'working_within' = 'Employed (Within)', 'age_within' = 'Age (Within)', 'female' = 'Women', 'white' = 'White'),
  coef_omit = 'Intercept|wave|\\|', 
  gof_map = list(
    list("raw" = "nobs", "clean" = "Num. Observations", "fmt" = 0),
    list("raw" = "Between-Person Variance", "clean" = "Between-Person Variance", "fmt" = 2),
    list("raw" = "ICC (Between Prop.)", "clean" = "ICC (Between-Person Prop.)", "fmt" = 2)
  ),
  title = 'Mundlak Mixed-Effects Models for Network Connectivity (1985-1995)',
  notes = list('Wave fixed effects and threshold coefficients omitted for space.', 'SEs omitted for space.', '+ p < 0.1, * p < 0.05, ** p < 0.01', 'Within-person variance for count/ordinal models is fixed by their theoretical link functions.'),
  output = here('Tabs', 'pcs_network_stability_modern.tex')
)

# Fix label in the generated tex file manually since modelsummary escapes it
tex_file <- here('Tabs', 'pcs_network_stability_modern.tex')
lines <- readLines(tex_file)
lines <- gsub(
  "\\\\caption\\{Mundlak Mixed-Effects Models for Network Connectivity \\(1985-1995\\)\\}", 
  "\\\\caption{Mundlak Mixed-Effects Models for Network Connectivity (1985-1995)\\\\label{tab:network_stability}}", 
  lines
)
writeLines(lines, tex_file)

# 2. Descriptives Table
sink(here('Tabs', 'descriptives.tex'))
cat("\\begin{table}[htbp]\n\\centering\n\\caption{Descriptive Statistics of Variables Used in the Analysis}\n")
cat("\\label{tab:descriptives}\n")
cat("\\begin{tabular}{l c c c c}\n\\toprule\n")
cat("Numeric Variables & Mean & SD & Min & Max \\\\\n\\midrule\n")
cat(sprintf("Frequency of Interaction with Friends & %.2f & %.2f & %d & %d \\\\\n", mean(df_mundlak$friends, na.rm=T), sd(df_mundlak$friends, na.rm=T), min(df_mundlak$friends, na.rm=T), max(df_mundlak$friends, na.rm=T)))
cat(sprintf("Frequency of Interaction with Family & %.2f & %.2f & %d & %d \\\\\n", mean(df_mundlak$family, na.rm=T), sd(df_mundlak$family, na.rm=T), min(df_mundlak$family, na.rm=T), max(df_mundlak$family, na.rm=T)))
cat(sprintf("Voluntary Organization Memberships & %.2f & %.2f & %d & %d \\\\\n", mean(df_mundlak$numsocmems, na.rm=T), sd(df_mundlak$numsocmems, na.rm=T), min(df_mundlak$numsocmems, na.rm=T), max(df_mundlak$numsocmems, na.rm=T)))
cat(sprintf("Cultural Taste Breadth & %.2f & %.2f & %d & %d \\\\\n", mean(df_mundlak$numcult, na.rm=T), sd(df_mundlak$numcult, na.rm=T), min(df_mundlak$numcult, na.rm=T), max(df_mundlak$numcult, na.rm=T)))
cat(sprintf("Age & %.2f & %.2f & %d & %d \\\\\n", mean(df_mundlak$age, na.rm=T), sd(df_mundlak$age, na.rm=T), min(df_mundlak$age, na.rm=T), max(df_mundlak$age, na.rm=T)))
cat(sprintf("Education & %.2f & %.2f & %d & %d \\\\\n", mean(df_mundlak$educ, na.rm=T), sd(df_mundlak$educ, na.rm=T), min(df_mundlak$educ, na.rm=T), max(df_mundlak$educ, na.rm=T)))
cat("\\midrule\n")
cat("Categorical Variables (Binary) & \\multicolumn{4}{c}{\\% (Mean $\\times$ 100)} \\\\\n\\midrule\n")
cat(sprintf("Women & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_mundlak$female, na.rm=T)*100))
cat(sprintf("White & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_mundlak$white, na.rm=T)*100))
cat(sprintf("Married & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_mundlak$married, na.rm=T)*100))
cat(sprintf("Big City Resident & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_mundlak$bigcity, na.rm=T)*100))
cat(sprintf("Employed & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_mundlak$working, na.rm=T)*100))
cat("\\bottomrule\n\\end{tabular}\n\\end{table}\n")
sink()



cat("Tables generated successfully in Tabs/.\n")
