lines <- readLines("R/pcs-analysis-modern.R")

lines <- sub("vcov = ~id,", 'vcov = lapply(logit_models, function(m) sandwich::vcovCL(m, cluster = m$data$id)),', lines)

writeLines(lines, "R/pcs-analysis-modern.R")
