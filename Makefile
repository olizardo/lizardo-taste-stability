# Makefile for the Taste Stability Analytical Pipeline

# The default target builds everything
all: paper

# 1. Data Processing
data/pcs_cleaned_mundlak.rds: R/01_data_processing.R PCS/pc1980-85-90-95.dta
	@mkdir -p data
	Rscript R/01_data_processing.R

# 2. Model Fitting
# Depends on the cleaned data and the model script
models/m_friends.rds models/m_family.rds models/m_orgs.rds: R/02_model_fitting.R data/pcs_cleaned_mundlak.rds
	@mkdir -p models
	Rscript R/02_model_fitting.R

# 3. Tables
# Depends on the fitted models and the table script
tables: R/03_make_tables.R models/m_friends.rds models/m_family.rds models/m_orgs.rds
	Rscript R/03_make_tables.R

# 4. Plots
# Depends on the fitted models and the plots script
plots: R/04_make_plots.R models/m_friends.rds models/m_family.rds models/m_orgs.rds
	Rscript R/04_make_plots.R

# 5. Paper compilation
# Depends on tables and plots and the tex file
paper: tables plots manuscript_research_note.tex
	pdflatex -interaction=nonstopmode manuscript_research_note.tex
	pdflatex -interaction=nonstopmode manuscript_research_note.tex

# Clean up
clean:
	rm -rf data/pcs_cleaned_mundlak.rds models/*.rds
	rm -f Tabs/*.tex Plots/*.png
	rm -f *.aux *.log *.out *.bbl *.blg *.pdf
