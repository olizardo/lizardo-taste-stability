with open('manuscript_research_note.tex', 'r') as f:
    text = f.read()

fig1 = """

\\begin{figure}[htbp]
\\centering
\\includegraphics[width=0.85\\textwidth]{tex/taste_retention.png}
\\caption{Extremely High Over-Time Taste Stability (5-Year Window). Most cultural practices show retention rates upwards of 95\\%.}
\\label{fig:taste_retention}
\\end{figure}

"""
text = text.replace("Wellman \\emph{et al.} 1997).", "Wellman \\emph{et al.} 1997)." + fig1)

fig2 = """

\\begin{figure}[htbp]
\\centering
\\includegraphics[width=0.85\\textwidth]{tex/taste_loss_forest_plot.png}
\\caption{Network Turnover Predicts Cultural Taste Loss. Point estimates and 95\\% confidence intervals from pooled discrete-time logistic regressions.}
\\label{fig:taste_loss}
\\end{figure}

"""
text = text.replace("due to life-course changes associated with network turnover.", "due to life-course changes associated with network turnover." + fig2)

fig3 = """

\\begin{figure}[htbp]
\\centering
\\includegraphics[width=0.85\\textwidth]{tex/cultural_conversion_effects.png}
\\caption{Cultural Breadth Sustains Social Connectivity Over Time. Predicted counts from Mundlak Between-Person Effects.}
\\label{fig:culture_conversion}
\\end{figure}

"""
text = text.replace("\\input{tex/pcs_network_stability_modern.tex}", "\\input{tex/pcs_network_stability_modern.tex}" + fig3)

with open('manuscript_research_note.tex', 'w') as f:
    f.write(text)

