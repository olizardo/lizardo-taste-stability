library(dplyr)

lines <- readLines("R/pcs-analysis-modern.R")
new_lines <- character(0)

# Replace the output strings to not write directly, but save as objects, 
# then pipe to kable_styling(latex_options = "scale_down") and write

# Actually, the easiest way with kableExtra in modelsummary is:
# modelsummary(...) |> kableExtra::kable_styling(latex_options = "scale_down") %>% kableExtra::save_kable("tex/...")

for (line in lines) {
    if (grepl("output = here\\('tex', 'pcs_taste_change_modern.tex'\\)", line)) {
        new_lines <- c(new_lines, "output = 'kableExtra'")
    } else if (grepl("output = here\\('tex', 'pcs_network_stability_modern.tex'\\)", line)) {
        new_lines <- c(new_lines, "output = 'kableExtra'")
    } else if (grepl("title = 'Predictors of Taste Loss", line)) {
        new_lines <- c(new_lines, "title = 'Predictors of Taste Loss (Pooled Discrete-Time Logistic Regression)',")
    } else if (grepl("title = 'Mundlak Poisson Models", line)) {
        new_lines <- c(new_lines, "title = 'Mundlak Poisson Models for Network Connectivity (1985-1995)',")
    } else if (line == ")") {
        # Check context: if it's the end of a modelsummary call
        new_lines <- c(new_lines, line)
    } else {
        new_lines <- c(new_lines, line)
    }
}

writeLines(new_lines, "R/pcs-analysis-modern.R")
