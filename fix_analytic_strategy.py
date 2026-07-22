import re

with open("manuscript.tex", "r") as f:
    content = f.read()

# Fix Taste Loss section analytic strategy (it still says "\beta is a k x 1 vector of coefficients ...")
old_taste_loss_sentence = r"""characteristics and \emph{\beta} is a \emph{k} x 1 vector of coefficients corresponding to the effects of these variables on the odds of cultural taste loss.\footnote{Cultural taste"""
new_taste_loss_sentence = r"""characteristics and \emph{\beta} is a \emph{k} x 1 vector of coefficients corresponding to the effects of these variables on the odds of cultural taste loss. To account for the fact that observations for the same individual are not independent across time periods, I estimate the models with cluster-robust standard errors (clustered by individual respondent).\footnote{Cultural taste"""

content = content.replace(old_taste_loss_sentence, new_taste_loss_sentence)
# Let's check if the previous attempt failed due to regex escaping. Here we are using exact string replace.
# The text actually says: "characteristics and \emph{β} is a \emph{k} x 1 vector of coefficients corresponding to the effects of these variables on the odds of cultural taste loss.\footnote{Cultural taste"
# Note the unicode beta symbol `β` vs `\beta`

old_taste_loss_sentence_2 = "characteristics and \\emph{β} is a \\emph{k} x 1 vector of coefficients corresponding to the effects of these variables on the odds of cultural taste loss.\\footnote{Cultural taste"
new_taste_loss_sentence_2 = "characteristics and \\emph{β} is a \\emph{k} x 1 vector of coefficients corresponding to the effects of these variables on the odds of cultural taste loss. To account for the fact that observations for the same individual are not independent across time periods, I estimate the models with cluster-robust standard errors (clustered by individual respondent).\\footnote{Cultural taste"

content = content.replace(old_taste_loss_sentence_2, new_taste_loss_sentence_2)

# Check for the lag models text
old_lag = r"""I deal with both of these issues in turn by presenting three different specifications, all of which take advantage of the availability of panel data at two points in time:

\emph{Lagged independent variables model}. First, I present I lagged independent variable model, in which the effects of cultural taste breadth 1985 on measures of social network connectivity in 1990 are estimated holding constant sociodemographic factors measured in 1985. While this strategy takes explicit advantage of the longitudinal aspect of the data, this specification is open to bias produced by any unmeasured, time-invariant individual level factor not included in the model that is constant over time and which thus spuriously produces the cross-temporal association of cultural taste breadth and network connectivity. The longitudinal nature of the data allows us to deal effectively with the issue of unobserved individual heterogeneity by modeling it directly. In the following I opt for a random-effects modeling framework. This model is:

\({E(Y}_{i}^{1990}) = a + \gamma C_{i}^{1985} + \sum_{}^{}{\beta x_{i}^{1985} + e_{i}}\) (5)

Where \emph{Y\textsubscript{i}} is an indicator of social connectivity measured in 1990, \emph{C\textsubscript{i}} is a measure of cultural taste breadth measured in 1985 and x is a vector of sociodemographic control variables measured in 1985."""

new_lag = r"""I deal with both of these issues by presenting a unified longitudinal modeling framework that takes advantage of the availability of panel data across time periods:"""

# Since the previous fix added Mundlak and Poisson, but left the lagged models block. Let's remove the lagged models block completely, as we don't present lagged models anymore, only Mundlak.
# First, let's see if we can find the exact text of old_lag
import textwrap

idx_start = content.find(r"I deal with both of these issues in turn by presenting three different specifications")
idx_end = content.find(r"\emph{Mundlak (Within-Between) models}.")

if idx_start != -1 and idx_end != -1:
    content = content[:idx_start] + new_lag + "\n\n" + content[idx_end:]


with open("manuscript.tex", "w") as f:
    f.write(content)
