library(dplyr)
library(tidyr)
library(modelsummary)
library(kableExtra)
library(here)

df <- readRDS(here('R', 'pcs_processed.rds'))
source(here('R', 'pcs-analysis-modern.R'))

df_desc_num <- df_long %>%
  select(friends, numsocmems, numcult) %>%
  drop_na()

df_desc_cat <- df_transitions %>%
  select(female, white, chngfriends_end, chngorgs_end, 
         chngeduc_end, chngmarital_end, 
         chngchildre_end, chngwrkstat_end, 
         chngareanam_end, married_start, 
         working_start, bigcity_start)

sink(here('tex', 'descriptives.tex'))
cat("\\begin{table}[htbp]\n\\centering\n\\caption{Descriptive Statistics of Variables Used in the Analysis}\n")
cat("\\begin{tabular}{l c c c c}\n\\toprule\n")
cat("Numeric Variables & Mean & SD & Min & Max \\\\\n\\midrule\n")
cat(sprintf("Frequency of Interaction with Friends & %.2f & %.2f & %d & %d \\\\\n", mean(df_long$friends, na.rm=T), sd(df_long$friends, na.rm=T), min(df_long$friends, na.rm=T), max(df_long$friends, na.rm=T)))
cat(sprintf("Frequency of Interaction with Family & %.2f & %.2f & %d & %d \\\\\n", mean(df_long$family, na.rm=T), sd(df_long$family, na.rm=T), min(df_long$family, na.rm=T), max(df_long$family, na.rm=T)))
cat(sprintf("Voluntary Organization Memberships & %.2f & %.2f & %d & %d \\\\\n", mean(df_long$numsocmems, na.rm=T), sd(df_long$numsocmems, na.rm=T), min(df_long$numsocmems, na.rm=T), max(df_long$numsocmems, na.rm=T)))
cat(sprintf("Cultural Taste Breadth & %.2f & %.2f & %d & %d \\\\\n", mean(df_long$numcult, na.rm=T), sd(df_long$numcult, na.rm=T), min(df_long$numcult, na.rm=T), max(df_long$numcult, na.rm=T)))
cat(sprintf("Age & %.2f & %.2f & %d & %d \\\\\n", mean(df_long$age, na.rm=T), sd(df_long$age, na.rm=T), min(df_long$age, na.rm=T), max(df_long$age, na.rm=T)))
cat(sprintf("Education & %.2f & %.2f & %d & %d \\\\\n", mean(df_long$educ, na.rm=T), sd(df_long$educ, na.rm=T), min(df_long$educ, na.rm=T), max(df_long$educ, na.rm=T)))
cat("\\midrule\n")
cat("Categorical Variables (Binary) & \\multicolumn{4}{c}{\\% (Mean $\\times$ 100)} \\\\\n\\midrule\n")
cat(sprintf("Female & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_long$female, na.rm=T)*100))
cat(sprintf("White & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_long$white, na.rm=T)*100))
cat(sprintf("Married & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_long$married, na.rm=T)*100))
cat(sprintf("Big City Resident & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_long$bigcity, na.rm=T)*100))
cat(sprintf("Working & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_transitions$working_start, na.rm=T)*100))

cat(sprintf("Change in Friends & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_transitions$chngfriends_end, na.rm=T)*100))
cat(sprintf("Change in Org. Memberships & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_transitions$chngorgs_end, na.rm=T)*100))
cat(sprintf("Change in Educ. Standing & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_transitions$chngeduc_end, na.rm=T)*100))
cat(sprintf("Change in Marital Status & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_transitions$chngmarital_end, na.rm=T)*100))
cat(sprintf("Change in Children & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_transitions$chngchildre_end, na.rm=T)*100))
cat(sprintf("Change in Work Status & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_transitions$chngwrkstat_end, na.rm=T)*100))
cat(sprintf("Geographic Mobility & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_transitions$chngareanam_end, na.rm=T)*100))

cat("\\bottomrule\n\\end{tabular}\n\\end{table}\n")
sink()
