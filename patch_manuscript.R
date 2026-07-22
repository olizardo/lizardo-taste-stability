text <- readLines("manuscript_research_note.tex")

sec_start <- grep("\\\\subsubsection\\{Cultural Taste dimensions\\}", text)
sec_end <- grep("\\\\subsubsection\\{Social connectedness indicators\\}", text)

new_cult_sec <- c(
  "\\subsubsection{Cultural Taste dimensions}\\label{cultural-taste-indicators}",
  "",
  "To assess the hypotheses connected to the effects of cultural taste on indicators of sociability and social connectivity, I created measures of cultural engagement for the 1985, 1990, and 1995 waves. Rather than relying on a single additive index of ``omnivore'' breadth, I extracted distinct, underlying dimensions of cultural practice using Principal Components Analysis (PCA). Using the same set of items across waves, respondents were scored based on whether they reported engaging in the following cultural practices either ``very often'' or ``sometimes'': listening to music, going to a movie, going to a play/theatric performance, attending a sports event, watching videos, engaging in a hobby, reading magazines, following sports, reading books, and reading a newspaper.",
  "",
  "A Varimax-rotated PCA of these harmonized items cleanly separated cultural engagement into three specialized dimensions, which together explain roughly 43\\% of the total variance. Component 1 captures \\emph{Reading/Homebound Culture} (heavy loadings on reading magazines, reading books, engaging in hobbies, and reading the newspaper). Component 2 captures \\emph{Sports Culture} (heavy loadings on following sports and attending sports events). Component 3 captures \\emph{Out-of-Home Arts/Entertainment} (heavy loadings on going to movies, going to plays, listening to music, and watching videos). I output the continuous factor scores for these three rotated components for each individual in each wave, using these distinct dimensions to predict the maintenance of network ties.\\footnote{Prior drafts of this project utilized a simple 10-item additive index of cultural breadth. Using an unrotated PCA, all 10 items load positively onto the first principal component, confirming a general dimension of omnivorousness. However, decomposing this breadth via Varimax rotation reveals important relational specialization that the additive index obscures.}",
  ""
)

text <- c(text[1:(sec_start-1)], new_cult_sec, text[sec_end:length(text)])

writeLines(text, "manuscript_research_note.tex")
