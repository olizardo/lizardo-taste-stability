library(haven)
library(dplyr)
df <- read_dta("PCS/pc1980-85-90-95.dta")
print(dim(df))
print(head(colnames(df), 50))
# Let's check 1995 variables for culture
print(grep("music", colnames(df), value=TRUE))
print(grep("movie", colnames(df), value=TRUE))
print(grep("friends", colnames(df), value=TRUE))
