lines <- readLines("R/pcs-analysis-modern.R")
lines <- gsub("writeLines(as.character.*", "", lines, fixed=TRUE)
lines <- gsub("output = 'latex'", "output = here('Tabs', 'pcs_taste_change_modern.tex')", lines)
writeLines(lines, "R/pcs-analysis-modern.R")
