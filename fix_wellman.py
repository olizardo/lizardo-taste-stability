with open('references.bib', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("Wellman, Barry, Renita Yuk-Lin Wong, David Tindall and Nancy Nazer", "Wellman, Barry and Wong, Renita Yuk-Lin and Tindall, David and Nazer, Nancy")

with open('references.bib', 'w', encoding='utf-8') as f:
    f.write(text)
