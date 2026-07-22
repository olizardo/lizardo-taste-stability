# Longitudinal Stability of Cultural Tastes and Social Networks

This repository contains the complete replication materials—code, manuscripts, and results—for the research note analyzing the longitudinal stability of cultural tastes and their reciprocal relationship with social networks. 

Using panel data from the Project Canada Survey (PCS) spanning 1985–1995, the study employs Mundlak mixed-effects models to disaggregate the between-person (stable traits) and within-person (temporary spikes) effects of specialized cultural dimensions on maintaining friendships, family ties, and organizational memberships.

---

## 📂 Repository Structure

The project directory is structured as follows:

```text
├── R/                              # R scripts comprising the computational pipeline
│   ├── 01_data_processing.R        # Harmonizes raw data, runs PCA, creates Mundlak dataset
│   ├── 02_model_fitting.R          # Fits Mundlak mixed-effects models
│   ├── 03_make_tables.R            # Generates summary stats and regression tables
│   └── 04_make_plots.R             # Produces coefficient plots and PCA loading visualizations
├── Tabs/                           # Auto-generated regression and summary tables
├── Plots/                          # Auto-generated data visualizations
├── PCS/                            # Raw Project Canada Survey datasets
├── manuscript_research_note.tex    # Main LaTeX manuscript
├── references.bib                  # BibTeX file containing all references
├── renv.lock                       # renv lockfile for exact package versions
└── renv/                           # Project-local R library configuration
```

---

## 🛠️ Prerequisites & Installation

To run the reproducibility workflow, you will need **R**.

### 1. Required R Packages
This project uses `renv` to lock down dependencies and ensure exact reproducibility. To install the required packages, open the project in your R console and run:

```R
renv::restore()
```

This will automatically download and install the precise versions of the packages needed to execute the scripts (such as `lme4`, `ordinal`, `modelsummary`, and `lavaan`).

---

## 🚀 How to Reproduce the Findings

1. **Clone the Repository**: Clone this repository to your local machine using `git` or download it as a ZIP file.
2. **Open the Project**: Start an R session from the root directory or open the project folder in your preferred IDE (e.g., Positron, RStudio) to ensure relative paths resolve correctly.
3. **Install Dependencies**: Run `renv::restore()` to install the necessary packages.
4. **Run the Computational Pipeline**:
   The replication pipeline is divided into four sequential R scripts in the `R/` directory. Run them in order:
   
   * **Step 1: Data Processing**
     ```R
     source("R/01_data_processing.R")
     ```
     This script processes the raw PCS data, performs Principal Components Analysis (PCA) to extract cultural dimensions, and generates the final analysis dataset (`pcs_processed.rds`).
     
   * **Step 2: Model Fitting**
     ```R
     source("R/02_model_fitting.R")
     ```
     This fits the cumulative link mixed models (CLMM) for categorical tie frequency and Poisson mixed models for organizational memberships.
     
   * **Step 3: Tables**
     ```R
     source("R/03_make_tables.R")
     ```
     Outputs LaTeX-formatted tables into the `Tabs/` folder.
     
   * **Step 4: Plots**
     ```R
     source("R/04_make_plots.R")
     ```
     Outputs the PCA loading figures and the within/between coefficients visualization into the `Plots/` folder.

Once the pipeline finishes, you can compile the `manuscript_research_note.tex` file using your preferred LaTeX compiler (e.g., `pdflatex` or `latexmk`) to generate the final PDF.