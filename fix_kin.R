lines <- readLines("R/kin_script.R")
lines <- gsub("writeLines(as.character.*", "", lines, fixed=TRUE)
lines <- gsub("output = 'latex'", "output = here('Tabs', 'pcs_kin_comparison.tex')", lines, fixed=TRUE)
writeLines(lines, "R/kin_script.R")
