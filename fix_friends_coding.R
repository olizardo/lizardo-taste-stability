library(dplyr)
library(tidyr)
library(haven)
library(here)

df <- readRDS(here("R", "pcs_processed.rds"))

# In PCS, typically 1 = "Very often" or "Many", and higher numbers mean "Never" or "Few"
# Let's see the correlation again
cat("Original friends3/numcult3 corr:", cor(df$friends3, df$numcult3, use="complete.obs"), "\n")

# If 1="Often" and 3="Seldom/Never", we should reverse code it for a Poisson model where we want "higher = more friends"
df <- df %>% 
  mutate(
    friends3_rev = 4 - friends3,
    friends4_rev = 4 - friends4,
    friends5_rev = 4 - friends5
  )

cat("Reversed friends3/numcult3 corr:", cor(df$friends3_rev, df$numcult3, use="complete.obs"), "\n")

# Replace old variables with reversed in the dataframe
df <- df %>%
  mutate(
    friends3 = friends3_rev,
    friends4 = friends4_rev,
    friends5 = friends5_rev
  )

saveRDS(df, here("R", "pcs_processed.rds"))
cat("Reversed the coding of 'friends' so higher values mean MORE friends (as expected in a count model)\n")
