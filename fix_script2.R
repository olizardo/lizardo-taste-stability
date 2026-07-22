lines <- readLines("R/pcs-analysis-modern.R")
# Fix the second modelsummary
lines[76] <- "  output = here('Tabs', 'pcs_network_stability_modern.tex')"
writeLines(lines, "R/pcs-analysis-modern.R")
