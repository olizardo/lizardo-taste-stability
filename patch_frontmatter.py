import re

with open('manuscript_research_note.tex', 'r') as f:
    text = f.read()

# 3. Fix Author again (escaping the backslashes correctly in Python)
new_author = r'\author{Omar Lizardo \\ LeRoy Neiman Term Chair Professor of Sociology \\ Department of Sociology \\ University of California, Los Angeles \\ \href{mailto:olizardo@soc.ucla.edu}{\nolinkurl{olizardo@soc.ucla.edu}} \\ \url{https://olizardo.github.io/mysite/}}'
text = re.sub(
    r'\\author\{Omar Lizardo \\\\ Department of Sociology \\\\ University of Notre Dame \\\\ 810 Flanner Hall \\\\ Notre Dame, IN, 46556 \\\\ \\href\{mailto:olizardo@nd\.edu\}\{\\nolinkurl\{olizardo@nd\.edu\}\}\}',
    new_author.replace('\\', '\\\\'),
    text
)

with open('manuscript_research_note.tex', 'w') as f:
    f.write(text)

