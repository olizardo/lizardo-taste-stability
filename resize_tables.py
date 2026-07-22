with open('manuscript_research_note.tex', 'r') as f:
    text = f.read()

# Add graphics package if needed, though we already have it.
text = text.replace(
    '\\input{tex/pcs_taste_change_modern.tex}',
    '\\begin{table}[htbp]\\centering\\resizebox{\\textwidth}{!}{\\input{tex/pcs_taste_change_modern.tex}}\\end{table}'
)

text = text.replace(
    '\\input{tex/pcs_network_stability_modern.tex}',
    '\\begin{table}[htbp]\\centering\\resizebox{0.75\\textwidth}{!}{\\input{tex/pcs_network_stability_modern.tex}}\\end{table}'
)

with open('manuscript_research_note.tex', 'w') as f:
    f.write(text)

