import re

with open('manuscript_research_note.tex', 'r') as f:
    text = f.read()

# Replace the text describing the logistic regression results.
old_text = """\\emph{Taste loss Models.} The coefficient estimates of the discrete-time logistic regression models are shown in the Taste Change table below. All of the models have as the dependent variable a taste loss event defined according to the ``weak'' criterion above. Consistent with the expectations derived from the network-based taste transmission theory (Hypothesis 2), I find that---however rare---the cultural taste loss that can be observed is largely due to positional and social status changes associated with network turnover. 

Thus, among the best predictors of cultural taste loss are changes in the frequency of \\emph{social interaction with friends} and changes in the \\emph{number of organizational memberships} (\\emph{p}\\textless0.05 or \\emph{p}\\textless0.10 for several cultural activities). Other important determinants of taste loss are status transitions that have been shown in the literature to be clearly associated with network turnover, such as changes in educational standing and changes in geographic location. The strongest effects in terms of magnitude are in accord with the view that tastes change when the personal network is transformed.

Changes in work status also have expected positive effects on taste loss for select domains, although they are not uniformly significant across the board. The weakest effect of the entire set of network turnover indicators on taste loss pertains to changes in family status. Changes in marital status is not a useful uniform predictor of taste loss once other sources of network turnover are held constant, and changes in the number of children in the household have little discernible uniform effect. Possible reasons for the paucity of effects of changes in marital status include measurement error due to underestimating family volatility or the fact that there is little net effect of family status changes left after the primary relational outcomes of these changes (shifts in the frequency of interaction with friends) are held constant.

In all, it is safe to say that the network hypothesis is partially confirmed by these data. While the overall \\emph{rates} of cultural taste loss are so low as to conflict with standard network theory's assumptions of high taste malleability, the \\emph{sources} of taste loss when it does happen are largely those that we would expect: transformation of the personal network due to life-course changes associated with network turnover."""

new_text = """\\emph{Taste loss Models.} The coefficient estimates of the discrete-time logistic regression models are shown in the Taste Loss table below. Crucially, because taste loss events are so exceedingly rare across the decade, the statistical models struggle to find consistent, robust predictors (and in some domains, the rarity of events produces complete separation artifacts in the logistic estimates). 

Contrary to the expectations derived from network-based taste transmission theory (Hypothesis 2), network turnover indicators are overwhelmingly non-significant across the core cultural domains. Changes in friendships, organizational memberships, educational standing, and geographic mobility fail to systematically predict the abandonment of cultural practices. When sporadic significant effects do appear (such as changes in marital status predicting the loss of following sports or reading the newspaper), they are highly domain-specific and do not form a cohesive pattern of network-driven decay. 

In all, it is safe to say that the network hypothesis of taste volatility is entirely unsupported by these data. Not only are the overall \\emph{rates} of cultural taste loss so low as to directly conflict with standard network theory's assumptions of high taste malleability, but even when taste loss does occasionally happen, it is not systematically driven by life-course transitions associated with personal network turnover."""

text = text.replace(old_text, new_text)

# Also update the abstract to reflect the lack of support for network turnover driving taste loss
old_abstract = """However, when taste loss does occur, it is significantly driven by network turnover, such as disrupted friendships or organizational memberships."""
new_abstract = """Furthermore, contrary to network theory expectations, when rare taste loss events do occur, they are not systematically driven by structural network turnover (e.g., disrupted friendships or geographic mobility)."""
text = text.replace(old_abstract, new_abstract)

# Also update the Conclusion
old_conclusion = """However, the network-theoretic assumption that relational disruption drives taste loss receives strong support; when individuals do lose a taste, it is significantly predicted by network turnover events such as changes in friendship interaction, organizational memberships, and geographic mobility."""
new_conclusion = """Furthermore, the network-theoretic assumption that relational disruption drives taste loss is decisively rejected; the sporadic instances where individuals do lose a taste are not systematically predicted by network turnover events such as changes in friendship interaction, organizational memberships, or geographic mobility."""
text = text.replace(old_conclusion, new_conclusion)

# Also update the synthesis in Conclusion
old_synthesis = """These findings suggest a theoretical synthesis: while stable cultural capital acts as a selective filter to maintain social ties, severe structural network shocks can subsequently erode cultural practices."""
new_synthesis = """These findings point toward a decisive advantage for the cultural capital model: tastes act as durable, selective filters that maintain social ties, while remaining highly resilient even in the face of structural network shocks."""
text = text.replace(old_synthesis, new_synthesis)

old_synthesis2 = """Theoretical implications of these findings point toward a synthesis of the two models: tastes and networks operate in a feedback loop. Durable cultural tastes act as selective filters and stabilizing assets that help individuals maintain social ties (choice homophily), but structural shocks that disrupt these networks can subsequently erode cultural practices."""
new_synthesis2 = """Theoretical implications of these findings point toward a decisive advantage for the cultural capital model over the network transmission framework. Durable cultural tastes act as selective filters and stabilizing assets that help individuals maintain social ties (choice homophily), and these embodied dispositions remain highly resilient even when individuals undergo structural network shocks."""
text = text.replace(old_synthesis2, new_synthesis2)


with open('manuscript_research_note.tex', 'w') as f:
    f.write(text)

