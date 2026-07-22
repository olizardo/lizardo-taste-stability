with open('manuscript_research_note.tex', 'r') as f:
    text = f.read()

text = text.replace('\\nocite{*}', '')

with open('manuscript_research_note.tex', 'w') as f:
    f.write(text)

