with open('manuscript_research_note.tex', 'r') as f:
    text = f.read()

# We want to remove everything from \input{tex/pcs_taste_change_modern.tex} that appears after the References,
# down to \end{document}.

# The references end with the Wellman citation. We can just cut right after that paragraph.
split_marker = "Wellman, Barry and Scot Wortley. 1990. \"Different Strokes from Different Folks: Community Ties and Social Support.\" \\emph{American Journal of Sociology} 96:558-588."

if split_marker in text:
    parts = text.split(split_marker)
    # Reconstruct text: everything before + the marker + \n\n\end{document}
    new_text = parts[0] + split_marker + "\n\n\\end{document}\n"
    
    with open('manuscript_research_note.tex', 'w') as f:
        f.write(new_text)

