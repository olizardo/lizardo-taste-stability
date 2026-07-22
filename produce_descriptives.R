library(dplyr)
library(tidyr)
library(modelsummary)
library(kableExtra)
library(here)

df <- readRDS(here("R", "pcs_processed.rds"))

# Let's extract the actual variables used in the models.
# The Mundlak models use the long format. Let's make a summary of the long format data.
df_long <- df %>% 
  mutate(across(everything(), haven::zap_labels)) %>% 
  select(id, female, white, 
         friends3, friends4, friends5, 
         numsocmems3, numsocmems4, numsocmems5, 
         numcult3, numcult4, numcult5, 
         educ3, educ4, educ5, 
         married3, married4, married5, 
         childre3, childre4, childre5, 
         bigcity3, bigcity4, bigcity5) %>% 
  pivot_longer(cols = matches("3$|4$|5$"), names_to = c(".value", "wave"), names_pattern = "(.*)(3|4|5)$") %>% 
  mutate(wave = as.numeric(wave)) %>% 
  mutate(across(c(friends, numsocmems, numcult, educ, married, childre, bigcity), ~ as.numeric(haven::zap_labels(.)))) %>%
  drop_na()

desc_data <- df_long %>%
  select(
    `Interaction with Friends` = friends,
    `Org. Memberships` = numsocmems,
    `Cultural Breadth` = numcult,
    `Education` = educ,
    `Married` = married,
    `Children` = childre,
    `Big City` = bigcity,
    `Female` = female,
    `White` = white
  )

# Output summary
options(modelsummary_factory_latex = "kableExtra")
tbl <- datasummary(All() ~ N + Mean + SD + Min + Max, data = desc_data, 
                   title = "Descriptive Statistics (Person-Wave Observations)",
                   output = "kableExtra") %>%
       kable_styling(latex_options = c("hold_position"))

save_kable(tbl, here("tex", "descriptive_stats.tex"))
