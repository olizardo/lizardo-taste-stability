import re

with open("manuscript.tex", "r") as f:
    content = f.read()

# 1. Update Taste Loss model to mention cluster-robust standard errors
taste_loss_old = r"""characteristics and \\emph\{\\beta\} is a \\emph\{k\} x 1 vector of coefficients corresponding to the effects of these variables on the odds of cultural taste loss\\.\\footnote\{Cultural taste"""
taste_loss_new = r"""characteristics and \emph{\beta} is a \emph{k} x 1 vector of coefficients corresponding to the effects of these variables on the odds of cultural taste loss. To account for the fact that observations for the same individual are not independent across time periods, I estimate the models with cluster-robust standard errors (clustered by individual respondent).\footnote{Cultural taste"""
content = re.sub(taste_loss_old, taste_loss_new, content)

# 2. Update Longitudinal Culture conversion model strategy
# We need to replace the Random-effects and IV paragraphs with the new Mundlak & Poisson approach.
conversion_section_old = r"""\\emph\{Random-effects models\}\. I also present a model that accounts for unobserved heterogeneity by including an individual level random effect.*?value of cultural taste breadth in 1980\.\}"""

conversion_section_new = r"""\emph{Mundlak (Within-Between) models}. I also present a model that accounts for unobserved heterogeneity using a Mundlak (within-between) specification. While a standard random-effects model requires the stringent assumption that the unobserved individual-level heterogeneity is uncorrelated with the regressors, the Mundlak approach relaxes this by explicitly including the person-specific longitudinal means of the time-varying covariates. This allows us to disentangle the ``within-person'' effect (how changes in an individual's cultural taste over time affect changes in their social connectivity) from the ``between-person'' effect (how average differences in cultural tastes between individuals relate to average differences in social connectivity), thus minimizing omitted variable bias. This model can be written as:

\({E(Y}_{it}^{}) = a + \gamma_{W}(C_{it}^{} - \bar{C}_i) + \gamma_{B}\bar{C}_i + \sum_{}^{}{\beta x_{it}^{} + {u_{i} + e}_{it}}\) (6)

Where everything is as in (5), except that now the observation pertains to the individual-time period, as shown by the inclusion of the \emph{t} subscript. Here, \(\bar{C}_i\) represents the individual-specific mean of cultural taste breadth across time, \(\gamma_{W}\) estimates the within-person effect, and \(\gamma_{B}\) estimates the between-person effect. Finally, \emph{e\textsubscript{it}} is a classical random disturbance.

\emph{Count data models}. Furthermore, because the primary outcome variables for social connectivity (such as the number of friends or the number of voluntary association memberships) are discrete counts rather than continuous normal variables, these models are estimated using Poisson (or Negative Binomial) regressions. This ensures that the estimates properly respect the non-negative integer nature and variance structure of the connectivity outcomes."""

content = re.sub(conversion_section_old, conversion_section_new, content, flags=re.DOTALL)

with open("manuscript.tex", "w") as f:
    f.write(content)
