import re

with open('manuscript_research_note.tex', 'r') as f:
    text = f.read()

block = """\\begin{figure}[htbp]
\\centering
\\includegraphics[width=0.85\\textwidth]{tex/cultural_conversion_effects.png}
\\caption{Cultural Breadth Sustains Social Connectivity Over Time. Predicted counts from Mundlak Between-Person Effects.}
\\label{fig:culture_conversion}
\\end{figure}

"""

# Split by the block and reconstruct so it only appears once
parts = text.split(block)
if len(parts) > 2:
    # It appears multiple times, join them back with only one instance
    # The first instance is right after Results-1, the second is at the end.
    # Let's just remove the second one.
    text = parts[0] + block + parts[1] + "".join(parts[2:])

with open('manuscript_research_note.tex', 'w') as f:
    f.write(text)

