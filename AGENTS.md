# Taste Stability Project Agent

**Description**: Agent configuration for the Taste Stability modernization project

## Metadata
- **Primary Language**: R
- **Document Format**: LaTeX
- **Dataset**: Project Canada Survey (PCS) 1985-1995

## Instructions
You are an AI assistant helping Omar Lizardo modernize a legacy sociological data analysis project.

### Key Project Context
- The project analyzes cultural capital and its reciprocal relationship with social networks using longitudinal panel data from the Project Canada Survey (PCS).
- The original code was written in Stata circa 2008. It has been ported to modern R.
- The main manuscript is the research note `manuscript_research_note.tex`. The legacy `taste-stability.tex` should be ignored.
- The project previously included analyses of taste stability and loss via discrete-time event history models and network turnover indicators. These have been dropped to focus strictly on Mundlak mixed-effects models.

### Code and Analysis Guidelines
- R scripts are stored in the `R/` directory.
- The main data processing script is `R/pcs-data-processing.R`.
- The main analysis scripts are `R/pcs-analysis-modern.R` and `R/kin_script.R`.
- Visualization scripts include `R/visualize_results.R` and `R/plot_within_effects.R`.
- All table outputs go into the `Tabs/` directory.
- All plot outputs go into the `Plots/` directory.
- Use `renv` to manage dependencies. If you need a new package, run `renv::install()` and `renv::snapshot()`.

### Statistical Standards (2026 Modernization)
- Use Mundlak (Within-Between) models instead of standard Random Effects to account for unobserved heterogeneity while keeping between-person variance.
- Use Poisson mixed-effects models (`glmer` from `lme4`) for count data like `numsocmems`.
- Use cumulative link mixed-models (`clmm` from `ordinal`) for ordered categorical data like `friends` and `family` interactions.
- Use `modelsummary` to export LaTeX tables. Ensure compatibility with `tabularray`, `siunitx`, and `ulem`.

### LaTeX Guidelines
- The main file is `manuscript_research_note.tex`.
- Ensure math formulas are properly escaped if writing regex scripts to patch text.
- Do not manually insert tables; use `\input{Tabs/filename.tex}` where possible.
- Include graphics using `\includegraphics{Plots/filename.png}`.
- Ensure proper paragraph spacing (avoid hard wrapping that breaks LaTeX paragraphs).
- Include `\DeclareUnicodeCharacter{2212}{-}` in the preamble to correctly render minus signs in `modelsummary` outputs.
