library(haven)
library(dplyr)
library(tidyr)
df <- read_dta("PCS/pc1980-85-90-95.dta")

# Example for music
table(df$music3)
# 1=VO, 2=Some, 3=Seldom, 4=Never

table(df$music4)
# 1=VO, 2=Some, 3=Seldom, 4=Monthly, 5=Hardly/Never

table(df$music5)
# 1=Daily, 2=Sev/wk, 3=Once/wk, 4=2-3/mo, 5=Once/mo, 6=Hardly, 7=Never

# If we harmonize wave 5:
# 1,2,3 -> 1 (VO)
# 4,5 -> 2 (Sometimes)
# 6 -> 3 (Seldom)
# 7 -> 4 (Never)

df <- df %>%
  mutate(music4_h = case_match(music4, 4 ~ 3, 5 ~ 4, .default = music4),
         music5_h = case_match(music5, 1:3 ~ 1, 4:5 ~ 2, 6 ~ 3, 7 ~ 4, .default = music5))

cat("Harmonized music4:\n")
print(table(df$music4_h))
cat("Harmonized music5:\n")
print(table(df$music5_h))

cat("Check proportions:\n")
cat("W3:", prop.table(table(df$music3)), "\n")
cat("W4:", prop.table(table(df$music4_h)), "\n")
cat("W5:", prop.table(table(df$music5_h)), "\n")
