import re

with open('manuscript.tex', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Add natbib to preamble
if r'\usepackage{natbib}' not in text:
    text = text.replace(r'\usepackage{amsmath}', r'\usepackage{amsmath}' + '\n' + r'\usepackage{natbib}')

# 2. Insert Theory paragraph on core vs periphery (from notes / home.txt)
theory_para = r"""
To fully appreciate this dynamic, it is necessary to recognize that network instability is a fundamental feature of social life, not merely an artifact of measurement error \citep{morganetal1996}. Longitudinal studies of personal communities consistently demonstrate a high degree of volatility in network membership over time, with average overlap rates across periods sometimes hovering around fifty percent \citep{morganetal1996, suitorkeeton1997}. This aggregate instability is largely driven by the underlying core-periphery structure of personal networks \citep{hammer1983}: while a small ``core'' of kin and close confidants remains relatively stable, the larger ``extended'' periphery of casual acquaintances and socializing partners undergoes continuous circulation and flux. If cultural tastes are primarily transmitted and reinforced through this highly variable peripheral network, then it follows that the cultural tastes themselves should exhibit corresponding fluidity and decay. 

"""
# Find insertion point
target = "Thus if we take the network perspective seriously"
if target in text:
    text = text.replace(target, theory_para + target)

# 3. Expand the citations for the life transitions
old_citations = r"""(4) changes in work status (Fischer and Oliker 1983), (5) changes in geographical location (Degenne and Lebeaux 2005), (6) changes in marital status (Fischer and Oliker 1983) and (7) changes child rearing status (Munch, McPherson, and Smith-Lovin 1997)."""

new_citations = r"""(4) changes in work status \citep{fischer_oliker83, larson1984, newman1988, larsonetal1994}, (5) changes in geographical location \citep{degenne_lebeaux05}, (6) changes in marital status such as divorce or widowhood \citep{fischer_oliker83, anderson1984, leighgrady1985, morgan1989, morganmarch1992}, and (7) changes in child rearing status \citep{belskyrovine1984, mccannell1987, gottliebpancer1988, munch_etal97}."""

text = text.replace(old_citations, new_citations)

# 4. Remove the manual References block and insert BibTeX commands
# Use regex to find the references block and replace it
# It starts at \subsection{References}\label{references} and ends right before \section{\texorpdfstring{Appendix
import re
text = re.sub(r'\\subsection\{References\}\\label\{references\}.*?(?=\\section\{\\texorpdfstring\{Appendix)', 
              r'\\bibliographystyle{apalike}\n\\bibliography{references}\n\n', 
              text, flags=re.DOTALL)

with open('manuscript.tex', 'w', encoding='utf-8') as f:
    f.write(text)

print("Text and references patched.")
