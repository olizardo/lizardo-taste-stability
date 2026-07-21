with open('manuscript.tex', 'r', encoding='utf-8') as f:
    text = f.read()

# I need to inject nocite{*} so the bibliography actually prints since we left the in-text manual citations!
text = text.replace(r'\bibliographystyle{apalike}', r'\nocite{*}' + '\n' + r'\bibliographystyle{apalike}')

with open('manuscript.tex', 'w', encoding='utf-8') as f:
    f.write(text)
