text <- readLines("manuscript_research_note.tex")
insert_idx <- grep("decomposing this breadth via Varimax rotation reveals important relational specialization that the additive index obscures.\\}", text)

new_text <- c(
  text[1:insert_idx],
  "",
  "Figure \\ref{fig:pca_loadings} visualizes the item-component correlations (loadings) for this rotated solution. This decomposition clarifies that ``omnivorousness'' is not a monolithic trait. Reading books and magazines anchors a homebound dimension; going to plays and movies anchors a public arts dimension; and following and attending sports anchors a third. By extracting these scores, we can isolate whether specific types of cultural capital perform specialized relational work.",
  "",
  "\\begin{figure}[htbp]",
  "\\centering",
  "\\includegraphics[width=0.85\\textwidth]{Plots/pca_loadings.png}",
  "\\caption{Item-Component Correlations (Varimax PCA Loadings). Heatmap cells display the correlation between each binarized cultural practice and the extracted principal components.}",
  "\\label{fig:pca_loadings}",
  "\\end{figure}",
  text[(insert_idx+1):length(text)]
)

writeLines(new_text, "manuscript_research_note.tex")
