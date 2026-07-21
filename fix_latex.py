with open('manuscript.tex', 'r', encoding='utf-8') as f:
    text = f.read()

# Fix unicode characters
text = text.replace('γ', r'$\gamma$')
text = text.replace('β', r'$\beta$')
text = text.replace('≈', r'$\approx$')
text = text.replace('χ', r'$\chi$')
text = text.replace('Δ', r'$\Delta$')

# Fix double backslash before emph from the previous patch
text = text.replace(r'\\emph', r'\emph')
text = text.replace(r'\\subsubsection', r'\subsubsection')

# Comment out missing media images
import re
text = re.sub(r'(\\includegraphics.*?\{media/image.*?\})', r'% \1', text)

with open('manuscript.tex', 'w', encoding='utf-8') as f:
    f.write(text)
print("Latex fixes applied.")
