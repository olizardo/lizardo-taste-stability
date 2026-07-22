import re

with open('manuscript_research_note.tex', 'r') as f:
    text = f.read()

# Replace Data limitations section manually
parts = text.split('\\emph{Data limitations}.')
if len(parts) > 1:
    # Find the end of the paragraph
    p2 = parts[1].split('\\subsection{Variables}', 1)
    
    new_limitations = r"""\emph{Data Processing and Limitations}. The PCS data provide a rare look at longitudinal cultural tastes, but require careful programmatic harmonization due to survey design changes across waves. First, later waves shifted to 5-point and 7-point frequency scales; these were programmatically harmonized back to the original 4-point scale (1 = Very often, 4 = Never). Second, for several out-of-home activities (e.g., going to the movies, plays), the 1990 wave entirely dropped the "Very often" category, creating structural missingness at the top of the scale. Consequently, the strict event-history models of taste loss are restricted to four consistently measured at-home activities. Finally, the raw ``frequency of interaction with friends'' indicator was reverse-coded (where 1 equaled ``Many'' and 3 equaled ``Few''); this was programmatically inverted prior to estimation so that higher integer values correctly reflect greater social connectivity in the Poisson count models. There are also no direct ego-network size measures, so interaction frequency and voluntary memberships serve as proxies for sociability.

\subsection{Variables}"""
    
    text = parts[0] + new_limitations + p2[1]

# Also let's fix the bibliography. The text literally doesn't use BibTeX keys, it uses hardcoded citations in parentheses.
# But we can replace the manual References section with an apalike BibTeX setup as requested.

ref_split = "\\subsection{References}\\label{references}"
if ref_split in text:
    text_parts = text.split(ref_split)
    
    # In order to use bibtex but since there are no \cite commands, we need to issue a \nocite{*} so the bibliography prints something!
    new_ref = "\\subsection{References}\\label{references}\n\n\\nocite{*}\n\\bibliographystyle{apalike}\n\\bibliography{references}\n\n\\end{document}\n"
    
    text = text_parts[0] + new_ref

with open('manuscript_research_note.tex', 'w') as f:
    f.write(text)

