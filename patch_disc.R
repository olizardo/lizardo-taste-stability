text <- readLines("manuscript_research_note.tex")
disc_start <- grep("This research note aimed to test competing predictions", text)
limit_start <- grep("A limitation of this study is the reliance", text)

new_disc <- c(
  "This research note aimed to test competing predictions from network transmission and cultural capital models regarding the longitudinal stability of cultural tastes and their reciprocal relationship with social networks.",
  "",
  "The Mundlak mixed-effects models provide strong, nuanced evidence consistent with the culture conversion model \\citep{lizardo2006}. Looking across the three primary forms of connectivity (friends, family, and formal organizations), stable differences in cultural tastes significantly predict the maintenance of ties over time. Crucially, breaking down generic ``omnivorousness'' into specific dimensions reveals a profound relational specialization. Out-of-home arts and sports are the primary engines for forming and maintaining \\emph{elective} public ties (friends and formal organizations), while homebound reading and hobbies serve as the fundamental cultural glue for \\emph{prescribed}, intimate family ties.",
  "",
  "The within-person effects reveal a dual-track dynamic. Temporary spikes in an individual's specialized cultural repertoires yield significant immediate boosts to fluid, informal socializing (arts for friends, reading for family). In contrast, temporary expansions in cultural taste provide no immediate benefit for structural integration into formal organizations. Navigating the formalized structures of organizational life appears to rely exclusively on long-term, stable possession of cultural capital, rather than fleeting bursts of engagement.",
  "",
  "These findings point toward a decisive advantage for the cultural capital model over the network transmission framework. Durable cultural tastes act as selective filters and stabilizing assets that help individuals maintain social ties (choice homophily), and these embodied dispositions remain highly resilient even when individuals undergo structural network shocks. This aligns with recent work demonstrating that ``cultural talk'' and shared cultural participation serve as fundamental mechanisms for enhancing network stability and quality over time \\citep{jaeger2026, meuleman2023}. Furthermore, finding that specific forms of cultural capital aid not just elective friendships but also prescribed family ties highlights its broad utility as a conversational and interactional resource in modern societies. By acting as structural opportunities for positive social exchange \\citep{vanzella2022}, deep and specialized cultural repertoires allow individuals to navigate the inevitable network churn driven by life-course transitions without suffering a collapse in overall sociability \\citep{lin2022, weiss2022}.",
  ""
)

text <- c(text[1:(disc_start-1)], new_disc, text[limit_start:length(text)])
writeLines(text, "manuscript_research_note.tex")
