import re

# Fix manuscript_research_note.tex (remove the bad wrappers)
with open('manuscript_research_note.tex', 'r') as f:
    text = f.read()

text = text.replace(
    '\\begin{table}[htbp]\\centering\\resizebox{\\textwidth}{!}{\\input{tex/pcs_taste_change_modern.tex}}\\end{table}',
    '\\input{tex/pcs_taste_change_modern.tex}'
)

text = text.replace(
    '\\begin{table}[htbp]\\centering\\resizebox{0.75\\textwidth}{!}{\\input{tex/pcs_network_stability_modern.tex}}\\end{table}',
    '\\input{tex/pcs_network_stability_modern.tex}'
)

with open('manuscript_research_note.tex', 'w') as f:
    f.write(text)

# Fix the generated tex tables to just be smaller font or proper resize if they use standard table.
# Since modelsummary uses tinytable by default, it uses tabularray.
def make_small(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    # add \small or \footnotesize after \begin{table}
    content = content.replace('\\begin{table}', '\\begin{table}\n\\footnotesize')
    
    with open(file_path, 'w') as f:
        f.write(content)

make_small('tex/pcs_taste_change_modern.tex')
make_small('tex/pcs_network_stability_modern.tex')

