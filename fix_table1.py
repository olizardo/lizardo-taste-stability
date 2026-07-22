with open('tex/pcs_taste_change_modern.tex', 'r') as f:
    text = f.read()

# Add a resizebox inside the table environment
text = text.replace('\\begin{talltblr}', '\\resizebox{\\linewidth}{!}{\n\\begin{talltblr}')
text = text.replace('\\end{talltblr}', '\\end{talltblr}\n}')

with open('tex/pcs_taste_change_modern.tex', 'w') as f:
    f.write(text)

