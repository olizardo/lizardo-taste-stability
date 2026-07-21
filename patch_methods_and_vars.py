import re

with open("manuscript.tex", "r") as f:
    content = f.read()

# 1. Update Taste Loss model to mention cluster-robust standard errors
# Let's use simple string replace
old_1 = "characteristics and \\emph{\\beta} is a \\emph{k} x 1 vector of coefficients corresponding to the effects of these variables on the odds of cultural taste loss.\\footnote{Cultural taste"
new_1 = "characteristics and \\emph{\\beta} is a \\emph{k} x 1 vector of coefficients corresponding to the effects of these variables on the odds of cultural taste loss. To account for the fact that observations for the same individual are not independent across time periods, I estimate the models with cluster-robust standard errors (clustered by individual respondent).\\footnote{Cultural taste"

content = content.replace(old_1, new_1)

# 2. Update Longitudinal Culture conversion model strategy
# Look for the section mentioning random-effects and instrumental variables
# We can find the start and end and replace the middle.

start_marker = "\\emph{Random-effects models}. I also present a model that accounts for unobserved heterogeneity by including an individual level random effect."
end_marker = "value of cultural taste breadth in 1980.}"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker) + len(end_marker)

if start_idx != -1 and end_idx > start_idx:
    new_text = r"""\emph{Mundlak (Within-Between) models}. I also present a model that accounts for unobserved heterogeneity using a Mundlak (within-between) specification. While a standard random-effects model requires the stringent assumption that the unobserved individual-level heterogeneity is uncorrelated with the regressors, the Mundlak approach relaxes this by explicitly including the person-specific longitudinal means of the time-varying covariates. This allows us to disentangle the ``within-person'' effect (how changes in an individual's cultural taste over time affect changes in their social connectivity) from the ``between-person'' effect (how average differences in cultural tastes between individuals relate to average differences in social connectivity), thus minimizing omitted variable bias. This model can be written as:

\({E(Y}_{it}^{}) = a + \gamma_{W}(C_{it}^{} - \bar{C}_i) + \gamma_{B}\bar{C}_i + \sum_{}^{}{\beta x_{it}^{} + {u_{i} + e}_{it}}\) (6)

Where everything is as in (5), except that now the observation pertains to the individual-time period, as shown by the inclusion of the \emph{t} subscript. Here, \(\bar{C}_i\) represents the individual-specific mean of cultural taste breadth across time, \(\gamma_{W}\) estimates the within-person effect, and \(\gamma_{B}\) estimates the between-person effect. Finally, \emph{e\textsubscript{it}} is a classical random disturbance.

\emph{Count data models}. Furthermore, because the primary outcome variables for social connectivity (such as the number of friends or the number of voluntary association memberships) are discrete counts rather than continuous normal variables, these models are estimated using Poisson (or Negative Binomial) regressions. This ensures that the estimates properly respect the non-negative integer nature and variance structure of the connectivity outcomes."""
    
    content = content[:start_idx] + new_text + content[end_idx:]

# 3. Update Variable descriptions
# Cultural taste breadth scale (numcult)
old_numcult = "These include the frequency in which the respondent engaged in (1) listening to music, (2) going to the movies, (3) attending a theatric performance, (45) going to a sporting event, (6) watching videos, (7) engaging in a hobby, (8) reading magazines, (9) following a sports team, and (10) reading books of fiction."
new_numcult = "These include the frequency in which the respondent engaged in (1) listening to music, (2) going to the movies, (3) attending a theatric performance, (4) going to a sporting event, (5) watching videos, (6) engaging in a hobby, (7) reading magazines, (8) following a sports team, (9) reading books of fiction, and (10) reading the newspaper."

# Actually let's just find where it says "(45) going to a sporting event" and replace the whole list.
content = content.replace("(45)", "(4)")
content = content.replace("and (10) reading books of fiction.", "(9) reading books of fiction, and (10) reading the newspaper.")

# Taste loss items - if we are aligning the text to the code (9 items instead of 4).
old_taste_loss = r"""\emph{Cultural taste loss indicators}. The PCS collected information for the years 1985 and 1990 related to the frequency of consumption of a variety of leisure culture activities and mass media outlets. To investigate the hypotheses related to cultural taste loss, I examine four activities"""
new_taste_loss = r"""\emph{Cultural taste loss indicators}. The PCS collected information for the years 1985 and 1990 related to the frequency of consumption of a variety of leisure culture activities and mass media outlets. To investigate the hypotheses related to cultural taste loss, I examine nine activities"""

content = content.replace(old_taste_loss, new_taste_loss)

# Also fix the list of four to nine
old_list_4 = r"""(1) listening to music, (2) reading books of fiction, (3) reading the newspaper and (4) following a sports team."""
new_list_9 = r"""(1) listening to music, (2) going to the movies, (3) attending a sporting event, (4) reading the newspaper, (5) reading books of fiction, (6) watching videos, (7) engaging in a hobby, (8) reading magazines, and (9) following a sports team."""

content = content.replace(old_list_4, new_list_9)

# We also need to fix: "Because of changes in the wording of the questions in 1990 (i.e. for going to the movies and attending the theater). While some cultural practices were affected by this wording change, I selected four distinct cultural activities that were measured in an identical fashion across both surveys."
# Since we are keeping all 9 in the code, let's remove or alter this justification.
old_justification = r"""Because of changes in the wording of the questions in 1990 (i.e. for going to the movies and attending the theater). While some cultural practices were affected by this wording change, I selected four distinct cultural activities that were measured in an identical fashion across both surveys."""
new_justification = r"""Although some cultural practices were affected by wording changes (i.e. for going to the movies and attending the theater), I examine a broader set of nine distinct cultural activities to capture a wide array of potential taste changes over time."""
content = content.replace(old_justification, new_justification)

with open("manuscript.tex", "w") as f:
    f.write(content)
