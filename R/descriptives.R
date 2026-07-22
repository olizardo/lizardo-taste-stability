library(dplyr)
library(tidyr)
library(modelsummary)
library(kableExtra)
library(here)

df <- readRDS(here('R', 'pcs_processed.rds'))

df_long <- df %>% mutate(across(everything(), haven::zap_labels)) %>% select(id, female, white, friends3, friends4, friends5, family3, family4, family5, numsocmems3, numsocmems4, numsocmems5, numcult3, numcult4, numcult5, educ3, educ4, educ5, married3, married4, married5, childre3, childre4, childre5, bigcity3, bigcity4, bigcity5, age3, age4, age5, working3, working4, working5) %>% pivot_longer(cols = matches('3$|4$|5$'), names_to = c('.value', 'wave'), names_pattern = '(.*)(3|4|5)$') %>% mutate(wave = as.numeric(wave)) %>% mutate(across(c(friends, family, numsocmems, numcult, educ, married, childre, bigcity, age, working), ~ as.numeric(haven::zap_labels(.))))


df_desc_num <- df_long %>%
  select(friends, family, numsocmems, numcult, age, educ) %>%
  drop_na()

df_desc_cat <- df_long %>%
  select(female, white, married, bigcity, working) %>%
  drop_na()

sink(here('Tabs', 'descriptives.tex'))
cat("\\begin{table}[htbp]\n\\centering\n\\caption{Descriptive Statistics of Variables Used in the Analysis}\n")
cat("\\label{tab:descriptives}\n")
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
cat(sprintf("Women & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_long$female, na.rm=T)*100))
cat(sprintf("White & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_long$white, na.rm=T)*100))
cat(sprintf("Married & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_long$married, na.rm=T)*100))
cat(sprintf("Big City Resident & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_long$bigcity, na.rm=T)*100))
cat(sprintf("Employed & \\multicolumn{4}{c}{%.1f\\%%} \\\\\n", mean(df_long$working, na.rm=T)*100))
cat("\\bottomrule\n\\end{tabular}\n\\end{table}\n")
sink()
