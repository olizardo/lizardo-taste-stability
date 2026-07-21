import re

with open("manuscript.tex", "r") as f:
    content = f.read()

author_block = r"\author{Omar Lizardo \\ Department of Sociology \\ University of Notre Dame \\ 810 Flanner Hall \\ Notre Dame, IN, 46556 \\ \href{mailto:olizardo@nd.edu}{\nolinkurl{olizardo@nd.edu}}}"
date_block = r"\date{Words: 12,254 \\ Last Revised: 08-Feb-24}"

content = content.replace(r"\author{}", author_block)
content = content.replace(r"\date{}", date_block)

text_to_remove = """Omar Lizardo

Department of Sociology

University of Notre Dame

810 Flanner Hall

Notre Dame, IN, 46556

\\href{mailto:olizardo@nd.edu}{\\nolinkurl{olizardo@nd.edu}}

Words: 12,254

Last Revised: 08-Feb-24"""

content = content.replace(text_to_remove, "")

content = content.replace(r"\subsection{\texorpdfstring{\hfill\break" + "\n" + r"Introduction}{ Introduction}}\label{introduction}", r"\section{Introduction}\label{introduction}")

with open("manuscript.tex", "w") as f:
    f.write(content)
