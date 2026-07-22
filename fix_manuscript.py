import re

with open("manuscript.tex", "r") as f:
    content = f.read()

# Fix the dataset timeframe section
old_text1 = r"""In the following study, I use the two-wave panel covering the years 1985 and 1990. While there is data available for these same respondents for the year 1995, I restrict myself to the core set of respondents who participated in both of these waves (N=560).\footnote{This subset of the sample while not representative of the Canadian population can be used to monitor change in habits and practices and the determinants of these changes as it is attempted in the present study. Response rates for 1985 and 1995 where about 60\%. About 65\% of those interviewed in 1985 where available to be re-interviewed in 1995.} . I do this for two reasons. First, it is well know that cultural participation declines with age (Smith 1995), so it is advantageous to measure cultural taste with behavioral data before cultural activity begins to tail off. Second, these two waves used a comparable coding on the taste indicators (a slightly different coding was used in 1995) allowing an operationally valid measure of over-time taste loss.

\emph{Data limitations}. While this data provide one of the few existing quantitative sources of information of cultural taste over-time for a large sample of respondents, there are some limitations of the data at hand that deserve mention: first, there are no direct measures of network connectivity (i.e. size of the personal network). The two measures available, frequency of interaction with friends, and number of associational memberships are important components of being sociable but certainly do not represent the notion of social connectivity in its entirety. Second, there are slight changes in the coding of the cultural activity and friendship interaction variables across waves, with the introduction of a slightly more elaborate scheme in 1990 (including a ``monthly'' category) and changing to never category to a composite ``hardly ever/never.'' This may compromise inferences made in investigating taste-loss, by leading to an over-estimation of taste loss events for instance.

I attempted to deal with this last issue by counting a taste loss event as one that involved a shift from one of the extreme categories to the other (the coding of which did not change across waves) and by not using items that showed a clear effect of the shift in wording. For instance, it is clear that for the item related to ``going to the movies'' something like this happened, with 15\% of respondents saying that they ``never'' go to the movies in 1985, but with 84\% saying that they either ``hardly ever or never'' go to the movies in 1990. A cross-classification of the responses to the same question across time, reveals that this dramatic shift is mostly due to the fact that most of the respondents who answer ``seldom'' in 1985 (55\%), where overwhelmingly more likely to answer ``hardly ever or never'' in 1990. The same artificial taste shift occurs for other cultural taste indicators associated with \emph{attending events outside the home} (going to a sports event, going to see a dramatic performance in a theater). Cultural practices that do not involve going outside of the home were shown to not be affected by the change in wording, and are therefore the items that I use below in the taste stability and taste loss analyses."""

new_text1 = r"""In the following study, I use the longitudinal panel covering the core years of 1985, 1990, and 1995, focusing on the core set of respondents who participated across these waves. While previous analyses restricted themselves to the 1985--1990 window to avoid coding inconsistencies in 1995 and age-related taste declines, the use of modern longitudinal estimators (such as Mundlak within-between models with wave fixed-effects) allows us to gracefully handle both age-related secular trends and programmatic harmonization of the taste indicators across the entire panel timeframe.

\emph{Data limitations}. While this data provide one of the few existing quantitative sources of information of cultural taste over-time for a large sample of respondents, there are some limitations that deserve mention: there are no direct measures of network connectivity (i.e., size of the personal network). The two measures available, frequency of interaction with friends and number of associational memberships, are important components of sociability but do not capture network properties entirely. To address the slight changes in the coding of cultural activities across waves (such as the shift to a 7-point frequency scale in 1995), all indicators have been programmatically harmonized back to the original 4-point scale (Very often, Sometimes, Seldom, Never) prior to estimation."""

content = content.replace(old_text1, new_text1)

# Fix the Taste Loss indicator years
content = content.replace("information for the years 1985 and 1990 related", "information across the 1985, 1990, and 1995 waves related")

# Fix breadth indicators
content = content.replace("cultural taste breadth variable for the 1980, 1985 and 1990 waves", "cultural taste breadth variable for the 1980, 1985, 1990, and 1995 waves")

# Fix strategy years
content = content.replace("discrete-time event history analysis for two time periods (1985 and 1990)", "discrete-time event history analysis spanning the pooled wave transitions (1985--1990 and 1990--1995)")
content = content.replace("``seldom'' or ``never'' in 1990)", "``seldom'' or ``never'' in the subsequent wave)")

with open("manuscript.tex", "w") as f:
    f.write(content)
