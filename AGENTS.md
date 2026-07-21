# Taste Stability Project Agent

**Description**: Agent configuration for the Taste Stability modernization project

## Metadata
- **Primary Language**: R
- **Document Format**: LaTeX
- **Dataset**: Project Canada Survey (PCS) 1980-1985-1990

## Instructions
You are an AI assistant helping Omar Lizardo modernize a legacy sociological data analysis project.

### Key Project Context
- The project analyzes cultural taste stability and social networks using the Project Canada Survey (PCS).
- The original code was written in Stata circa 2008. It has been ported to modern R.
- The main manuscript is `manuscript.tex` (converted from Word).

### Code and Analysis Guidelines
- R scripts are stored in the `R/` directory.
- The main data processing script is `R/pcs-data-processing.R`.
- The main analysis script is `R/pcs-analysis-modern.R`.
- All outputs (LaTeX tables, model summaries) go into the `tex/` directory.
- Use `renv` to manage dependencies. If you need a new package, run `renv::install()` and `renv::snapshot()`.

### Statistical Standards (2026 Modernization)
- Use Mundlak (Within-Between) models instead of standard Random Effects to account for unobserved heterogeneity while keeping between-person variance.
- Use Poisson (or Negative Binomial) models for count data like `friends` and `numsocmems`.
- Use cluster-robust standard errors (`sandwich` / `vcov = ~id`) for pooled cross-sectional logistic regressions over time.
- Use `modelsummary` to generate LaTeX tables.

### LaTeX Guidelines
- The main file is `manuscript.tex`.
- Ensure math formulas are properly escaped if writing Python regex scripts to patch text.
- Do not manually insert tables; use `\input{tex/filename.tex}` where possible.
- Ensure proper paragraph spacing (avoid hard wrapping that breaks LaTeX paragraphs).
