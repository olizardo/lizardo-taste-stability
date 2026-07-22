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
# We use a quick shell script to dynamically update the date and word count before building
paper: tables plots manuscript_research_note.tex
	@WORDS=$$(detex manuscript_research_note.tex | wc -w | awk '{print $$1}'); \
	TODAY=$$(date +"%d-%b-%y"); \
	sed -i -E "s/\\\\date\\{Words: ~[0-9,]+ \\\\\\\\ Last Revised: [0-9]{2}-[a-zA-Z]{3}-[0-9]{2}\\}/\\\\date\\{Words: ~$$WORDS \\\\\\\\ Last Revised: $$TODAY\\}/" manuscript_research_note.tex
	pdflatex -interaction=nonstopmode manuscript_research_note.tex
	pdflatex -interaction=nonstopmode manuscript_research_note.tex

# Clean up
clean:
	rm -rf data/pcs_cleaned_mundlak.rds models/*.rds
	rm -f Tabs/*.tex Plots/*.png
	rm -f *.aux *.log *.out *.bbl *.blg *.pdf
