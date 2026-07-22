text <- readLines("manuscript_research_note.tex")

# Find indices
idx_dp_start <- grep("\\\\emph\\{Data Processing and Limitations\\}", text)
idx_dp_end <- grep("proxies for sociability\\.", text)

# Ensure we got the right lines
if(length(idx_dp_start) == 1 && length(idx_dp_end) == 1) {
  new_dp <- c(
    "\\emph{Data Processing and Harmonization}. The PCS data provide a rare look at longitudinal cultural tastes and sociability, but require harmonization due to survey design changes across waves. Notably, the exact response categories for both the cultural practice items and the network interaction indicators (friends and family) varied over the decade. Wave 3 (1985) used a 4-point scale (``Very often'', ``Sometimes'', ``Seldom'', ``Never''); Wave 4 (1990) introduced a 5-point scale with an intermediate ``Monthly'' category; and Wave 5 (1995) used a 7-point scale ranging from ``Daily'' to ``Never''.",
    "",
    "To maintain longitudinal comparability, a single harmonization scheme was applied across all of these cultural and network variables. Responses were collapsed into a consistent three-category ordinal scale: (1) ``Seldom/Never'', (2) ``Sometimes'', and (3) ``Very Often''. For Wave 4, the ``Monthly'' category was mapped to ``Sometimes'' to prevent artificial drops in engagement levels for out-of-home activities. For Wave 5, the top three frequencies (from ``Daily'' to ``About once a week'') were mapped to ``Very Often'', while the next two (``2-3 times a month'' and ``About once a month'') were mapped to ``Sometimes''. All variables were coded such that higher integer values correctly reflect greater cultural consumption or social connectivity in the models. Finally, because there are no direct ego-network size measures in the survey, interaction frequency and voluntary memberships serve as proxies for sociability."
  )
  text <- c(text[1:(idx_dp_start-1)], new_dp, text[(idx_dp_end+1):length(text)])
}

# Find cultural footnote
idx_cult <- grep("where the respondent's participation frequency corresponds to ``very often'' or ``sometimes.''\\\\footnote\\{Because survey response categories changed over the decade", text)
if(length(idx_cult) == 1) {
  text[idx_cult] <- sub("\\\\footnote\\{Because survey response categories changed over the decade, harmonization was required to maintain longitudinal comparability\\. Wave 3 \\(1985\\) used a 4-point scale; Wave 5 \\(1995\\) used a 7-point scale, which was collapsed so that the top three frequencies \\(e\\.g\\., Daily to About once a week\\) mapped to ``very often'' and the next two \\(2-3 times a month / About once a month\\) mapped to ``sometimes\\.'' Notably, Wave 4 \\(1990\\) introduced a 5-point scale with an intermediate ``Monthly'' category\\. For this wave, ``Monthly'' was mapped to ``sometimes'' to prevent an artificial drop in the breadth index, given that monthly participation in out-of-home activities like plays or movies represents active consumption in this context\\.\\} ", "", text[idx_cult])
}

# Find social connectedness paragraph
idx_soc_start <- grep("The indicators for frequency of interaction with close friends and family members rely on questions", text)
if(length(idx_soc_start) == 1) {
  new_soc <- "The indicators for frequency of interaction with close friends and family members rely on questions that were asked across the 1985, 1990, and 1995 waves. As detailed in the data processing section, these items were harmonized using the exact same scheme applied to the cultural taste indicators, resulting in a consistent three-category ordinal scale: (1) ``Seldom/Never'', (2) ``Sometimes'', and (3) ``Very Often''."
  text[idx_soc_start] <- new_soc
}

writeLines(text, "manuscript_research_note.tex")
