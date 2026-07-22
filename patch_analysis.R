lines <- readLines("R/pcs-analysis-modern.R")
# Replace the glm loop block
new_block <- '
  if (nrow(df_sub) > 0) {
    # Only include variables with variance
    vars_to_check <- c(paste0(demchang, "_end"), paste0(controls, "_start"), "female", "white", "period")
    valid_vars <- c()
    for (v in vars_to_check) {
      if (length(unique(df_sub[[v]])) > 1) {
        if (v == "period") {
           valid_vars <- c(valid_vars, "as.factor(period)")
        } else {
           valid_vars <- c(valid_vars, v)
        }
      }
    }
    
    if (length(valid_vars) > 0) {
       f_str <- paste("event ~", paste(valid_vars, collapse=" + "))
       m <- glm(as.formula(f_str), data = df_sub, family = binomial(link="logit"))
       logit_models[[c]] <- m
    }
  }
'
# find where `if (nrow(df_sub) > 0) {` starts
idx_start <- grep("if \\(nrow\\(df_sub\\) > 0\\) \\{", lines)[1]
idx_end <- grep("logit_models\\[\\[c\\]\\] <- m", lines)[1] + 2

lines <- c(lines[1:(idx_start-1)], new_block, lines[idx_end:length(lines)])
writeLines(lines, "R/pcs-analysis-modern.R")
