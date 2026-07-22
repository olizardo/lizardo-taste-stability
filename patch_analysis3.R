lines <- readLines("R/pcs-analysis-modern.R")

# Find where we do df_long <- df %>%
# And insert mutate(across(everything(), haven::zap_labels)) %>%

idx <- grep("df_long <- df %>%", lines)
lines <- c(lines[1:idx], "  mutate(across(everything(), haven::zap_labels)) %>%", lines[(idx+1):length(lines)])

writeLines(lines, "R/pcs-analysis-modern.R")
