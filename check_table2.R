library(dplyr)
library(lme4)
library(here)

df <- readRDS(here('R', 'pcs_processed.rds'))

cat("\nChecking Network Connections models\n")
# The question asked to ensure the discussion matches the CURRENT results in the 4-item context.
# Actually, the 4-item context ONLY applies to the taste loss models (Table 1).
# The culture conversion model (Mundlak Poisson) uses `numcult` - the additive breadth index!
# Let's see what happens to `numcult`! Wait... earlier we saw `numcult` uses all 10 items.
