import re

with open("manuscript.tex", "r") as f:
    content = f.read()

# Define the boundaries of the text we want to replace
start_marker = r"\subsection{\texorpdfstring{Variables }{Variables }}\label{variables}"
end_marker = r"\subsection{Discussion and conclusion}\label{discussion-and-conclusion}"

idx_start = content.find(start_marker)
idx_end = content.find(end_marker)

if idx_start == -1 or idx_end == -1:
    print("Could not find boundaries")
    exit(1)

new_text = r"""\subsection{Variables}\label{variables}

\subsubsection{Cultural Taste indicators}\label{cultural-taste-indicators}

\emph{Cultural taste loss indicators}. The PCS collected information for the years 1985 and 1990 related to the frequency of consumption of a variety of leisure culture activities and mass media outlets. To investigate the hypotheses related to cultural taste loss, I examine nine activities that encompass both at-home consumption and outside leisure (Alexander 2003; Crane 1993; DiMaggio 2000; van Eijck and van Rees 2000): (1) listening to music, (2) going to the movies, (3) attending a sporting event, (4) reading the newspaper, (5) reading books of fiction, (6) watching videos, (7) engaging in a hobby, (8) reading magazines, and (9) following a sports team. This broad selection captures a wide array of potential taste changes over time across different domains of cultural participation. Respondents were asked to report the frequency with which they engaged in each of these activities using the following prompt:\footnote{The various codebooks for all waves of the PCS survey (1975, 1980, 1985, 1990 and 1995) are available online at: http://www.thearda.com/Archive/IntSurveys.asp.}

\emph{Thinking now of your life outside of formal work, how often would you estimate that you: [i.e. listen to music]?}

Four categories of responses were allowed: (1) very often, (2) sometimes, (3) Seldom and (4) Never.\footnote{As noted above, the 1990 coded the same variables using a slightly more elaborate categorization. I recoded those variables to match the 1985 scheme.} Thus for each respondent (\emph{i}), for a given cultural activity (\emph{k}) at time (\emph{t}) is defined as their score in the respective ordered categorical variable y\textsubscript{\emph{ikt}.}

\emph{Cultural taste breadth indicators}. To assess the hypotheses connected to the effects of cultural taste on indicators of sociability and social connectivity, I created a cultural taste breadth variable for the 1980, 1985 and 1990 waves. This is a simple additive index indicating participation in a wide range of cultural activities. Using the same set of items, the respondent receives one point in the cultural taste breadth scale if he or she reports engaging in the following cultural practices either ``very often'' or ``sometimes'': (1) listening to music, (2) going to the movies, (3) going to a theatric performance, (4) going to a sports event outside the home, (5) watching videos at home, (6) engaging in a hobby, (7) reading magazines, (8) following a sports team, (9) reading a novel or book, and (10) reading the newspaper.

\subsubsection{Network turnover indicators}\label{network-turnover-indicators}

As noted above, network theory and research provide several guidelines as to what life-course events are associated with radical changes in the personal network. The PCS contains two measures that tap more or less direct transformations of the personal network: (1) longitudinal changes in frequency of interaction with friends and (2) over-time changes in memberships across a variety of voluntary associations (McPherson 1983; McPherson and Smith-Lovin 1987). I also use five other indicators of personal network turnover based on positional shifts: (3) changes in educational status (Suitor and Keeton 1997) (4) changes in work status (Fischer and Oliker 1983), (5) changes in geographical location (Degenne and Lebeaux 2005), (6) changes in marital status (Fischer and Oliker 1983) and (7) changes in child rearing status (Munch, McPherson, and Smith-Lovin 1997). Since a non-negligible part of the individual's personal network comes from contacts that are often seen at work (Brass 1985; Ibarra 1992; Straits 1996), we should expect that either entrance into or exit from the labor force, or shifts from part-time to full-time work, should have a clear impact on the size and composition of the personal network over time (Bidart and Lavenu 2005). The same can be said of geographical mobility (Relish 1997), with geographically mobile respondents more likely to be subject to radical transformation of their personal networks from those who are not mobile.\footnote{The nominal employment status from which the binary indicator for changes in work status is constructed from has six categories (1) full time, (2) part time, (3) unemployed, (4) retired, (5) keeping house, and (6) other. The geographical mobility item is based on the region in which respondent reported residing in each wave. The marital status variable has five categories: (1) married, (2) cohabiting, (3) divorced, (4) widowed and (5) never married.} Finally, a large body of research shows that family status transitions, such as getting married or getting divorced (Gerstel 1988; Leslie and Grady 1985; Milardo 1987; Pahl and Pevalin 2005) and experiencing widowhood (Anderson 1984; Morgan, Carder, and Neal 1997; Morgan, Neal, and Carde 1997), have significant effects on the social networks of men and women. We should thus expect that transformations in family life, such as getting divorced, getting married or having children (Belsky and Rovine 1984; Bott 1971; Munch, McPherson, and Smith-Lovin 1997), should result in direct effects on the size and composition of the personal network.

\subsubsection{Social connectedness indicators}\label{social-connectedness-indicators}

In order to test the cultural capital hypotheses (3 and 4), I use two indicators of social connectivity: (a) the count of close friends with whom the respondent interacts, and (b) the ability to remain connected to important foci for social interaction, such as voluntary associations. 

Retention of connections to important interaction foci is measured using a scale that simply counts the distinct types of voluntary associations the respondent belongs to in each wave of the survey: these include private clubs, sport clubs, service organizations, and hobby clubs. These types of memberships are the kinds of interaction foci in which mass media and arts-related culture-mediated social interaction is most likely to play a key role in the formation and maintenance of social contacts (Long 2003), and thus on the likelihood that the individual will retain or drop the membership (McPherson, Popielarz, and Drobnic 1992; Popielarz and McPherson 1995).

\subsubsection{Sociodemographic controls}\label{sociodemographic-controls}

The models shown below include the following sociodemographic controls: gender, age, education, city size, employment status, marital status, and presence of children in the household. The descriptive statistics of the variables are detailed in Table 4 of the Appendix.

\subsection{Network driven taste loss}\label{network-driven-taste-loss}

\subsubsection{Analytic Strategy}\label{analytic-strategy}

The cultural taste loss model can be thought of as a discrete-time event history analysis for two time periods (1985 and 1990) (Allison 1982). The dependent variable equals 1 if a cultural taste loss event is observed (the individual reported engaging in the activity ``very often'' in 1985, but ``seldom'' or ``never'' in 1990) and 0 otherwise. 

To model this, I employ a pooled discrete-time logistic regression equation estimating the log odds of taste loss for each of the nine cultural activities. The predictors include a vector of network turnover indicators (e.g., changes in marital status, changes in work status, geographical mobility, changes in friends) as well as the standard matrix of sociodemographic controls. To account for the fact that observations for the same individual are not independent across time periods (unobserved heterogeneity within respondents), I estimate the models with cluster-robust standard errors (clustered by individual respondent). If the network hypothesis is correct (hypothesis 2), we should observe significant, positive coefficients for the network turnover indicators, implying that relational disruptions drive taste loss.

\subsubsection{Results}\label{results}

\emph{Frequency of Taste Loss.} Consistent with the cultural capital hypothesis, across all nine cultural taste domains, taste loss is a relatively rare event. This is the case whether this is defined in a ``strong'' form (from ``very often'' in the first wave to ``never'' in the second) or in a weaker form (from ``very often'' to \emph{either} ``seldom'' or ``never''). Less than 1\% of respondents go from having a strong taste in listening to music or reading the newspaper to losing that taste in the five-year period. A relatively larger number of respondents lose the taste for reading books (1.07\%) or following sports (1.43\%), but the main empirical finding here is that the great majority of respondents retain their tastes ($\approx$98\%). When taste loss is defined in a weaker form, the worst retention rate drops to about 95\% for reading books. This supports the cultural capital assumption that tastes are relatively stable over time, exhibiting stability rates that far exceed what is typically observed for personal networks (Suitor, Wellman, and Morgan 1997; Wellman \emph{et al.} 1997).

\emph{Taste loss Models.} The coefficient estimates of the discrete-time logistic regression models are shown in the Taste Change table below. All of the models have as the dependent variable a taste loss event defined according to the ``weak'' criterion above. Consistent with the expectations derived from the network-based taste transmission theory (Hypothesis 2), I find that---however rare---the cultural taste loss that can be observed is largely due to positional and social status changes associated with network turnover. 

Thus, among the best predictors of cultural taste loss are changes in the frequency of \emph{social interaction with friends} and changes in the \emph{number of organizational memberships} (\emph{p}\textless0.05 or \emph{p}\textless0.10 for several cultural activities). Other important determinants of taste loss are status transitions that have been shown in the literature to be clearly associated with network turnover, such as changes in educational standing and changes in geographic location. The strongest effects in terms of magnitude are in accord with the view that tastes change when the personal network is transformed.

Changes in work status also have the expected positive effects on taste loss for select domains (like videos), although they are not uniformly significant across the board. The weakest effect of the entire set of network turnover indicators on taste loss pertains to changes in family status. Changes in marital status is not a useful uniform predictor of taste loss once other sources of network turnover are held constant, and changes in the number of children in the household have little discernible uniform effect. Possible reasons for the paucity of effects of changes in marital status include measurement error due to underestimating family volatility or the fact that there is little net effect of family status changes left after the primary relational outcomes of these changes (shifts in the frequency of interaction with friends) are held constant.

In all, it is safe to say that the network hypothesis is partially confirmed by these data. While the overall \emph{rates} of cultural taste loss are so low as to conflict with standard network theory's assumptions of high taste malleability, the \emph{sources} of taste loss when it does happen are largely those that we would expect: transformation of the personal network due to life-course changes associated with network turnover.

\input{tex/pcs_taste_change_modern.tex}

\subsection{Longitudinal Culture conversion model}\label{longitudinal-culture-conversion-model}

\subsubsection{Analytic Strategy}\label{analytic-strategy-1}

In this section, I estimate the potential causal effect of cultural capital (as measured by taste diversity) on the maintenance of network connectivity over time. Estimating this reciprocal effect longitudinally presents two major methodological challenges: unobserved individual heterogeneity (time-invariant individual-level factors correlated with both variables) and simultaneity bias.

To deal with these issues and properly model count-based network outcomes, I present a unified longitudinal modeling framework:

\emph{Mundlak (Within-Between) Poisson Models}. I employ a Mundlak (within-between) specification using a Poisson regression framework. Standard random-effects models require the stringent assumption that unobserved individual-level heterogeneity is entirely uncorrelated with the regressors. The Mundlak approach relaxes this assumption by explicitly including the person-specific longitudinal means (the "between" effect) of the time-varying covariates alongside the group-mean-centered deviations (the "within" effect). 

This allows us to cleanly disentangle the ``within-person'' effect (how temporary changes in an individual's cultural taste over time affect changes in their social connectivity) from the ``between-person'' effect (how stable, average differences in cultural tastes between individuals relate to average differences in social connectivity), thereby minimizing omitted variable bias. 

Furthermore, because the primary outcome variables for social connectivity (the number of friends and the number of voluntary association memberships) are discrete, non-negative integer counts rather than continuous normal variables, these models are estimated using Poisson regressions. This ensures that the estimates correctly respect the variance structure of the count data.

\subsubsection{Results}\label{results-1}

The culture conversion model (Lizardo 2006) implies that individuals who have command of a wide variety of tastes will be able to sustain larger and sparser personal networks over time, allowing them to reap the benefits of those social connections in the form of higher than average rates of social interaction and a higher ability to remain connected to important social foci where new contacts are made and old ones are sustained. 

The results of the Mundlak (within-between) Poisson models of the effect of cultural capital (in the form of ``omnivore'' taste breadth) on network outcomes across time periods are shown below.

\input{tex/pcs_network_stability_modern.tex}

The results are highly consistent with the culture conversion model, particularly when examining the robust between-person differences (the `mean` effects). I find that persons who display a persistently wide variety of tastes (a higher longitudinal mean of cultural breadth) sustain higher frequencies of social interaction with friends (\emph{p}\textless0.05). While this cross-sectional ``between'' effect does not offer definitive evidence of strict causality, it cements in a robust longitudinal modeling framework the results previously reported by Lizardo (2006). Broad cultural tastes are strongly associated with sustaining larger and more active patterns of interpersonal engagement over time. 

Furthermore, having a high average repertoire of tastes is not only useful in sustaining higher levels of informal social connectivity, but it also significantly raises the chances of remaining tied to important social foci of interaction, such as voluntary associations (\emph{p}\textless0.05). Because recruitment (and the over-time stability of membership) into these foci is largely a matter of keeping alive the network ties that bind the individual to other members of the group (Popielarz and McPherson 1995), it is no surprise that whatever resource helps the individual to sustain social connections to other persons will also appear to sustain his or her connection to these larger social entities.

The Mundlak specification also allows us to evaluate the within-person effects---whether a temporary spike in an individual's cultural tastes over their own average translates to immediate gains in connectivity. The within-person effects for cultural taste breadth are smaller and only marginally significant for interaction with friends (\emph{p}\textless0.1) and non-significant for organizational memberships. This suggests that it is the durable, trait-like possession of cultural capital (the between-person effect), rather than short-term fluctuations in cultural activity, that primarily drives sustained social connectivity and organizational integration over the life course.

"""

content = content[:idx_start] + new_text + content[idx_end:]

with open("manuscript.tex", "w") as f:
    f.write(content)

