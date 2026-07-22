import re

with open('manuscript.tex', 'r') as f:
    lines = f.readlines()

# Find section indices
def find_line(pattern):
    for i, line in enumerate(lines):
        if re.search(pattern, line):
            return i
    return -1

intro_start = find_line(r'\\section\{Introduction\}')
theory_start = find_line(r'\\subsection\{Network versus cultural capital theories')
data_start = find_line(r'\\section\{Data and variables\}')
discussion_start = find_line(r'\\subsection\{Discussion and conclusion\}')
ref_start = find_line(r'\\subsection\{References\}')

if ref_start == -1:
    ref_start = find_line(r'\\section\{References\}')

preamble = lines[:intro_start]

new_intro = """\\section{Introduction}\\label{introduction}

Prevailing models of taste formation, transmission, and decay in the sociology of culture posit that current tastes are largely a product of the individual's current network configuration. The standard assumption is that tastes are transmitted through existing network ties, in particular those social connections characterized by sociodemographic similarity (Lazarsfeld and Merton 1954; McPherson, Smith-Lovin, and Cook 2001). From this perspective, tastes are not enduring aspects of the person but malleable, ``thin'' contents liable to change when network ties change (Mark 1998b, 2003). Given that personal networks are highly volatile (Burt 2000; Suitor, Wellman, and Morgan 1997), this network perspective implies that cultural tastes should also exhibit significant instability over time.

In contrast, the cultural capital model (Bourdieu 1984; Holt 1998) conceives of cultural tastes as highly durable dispositions. Formed early in life, these embodied cultural practices are resistant to change and serve as stable resources to maintain and forge network connections (Lizardo 2006). Rather than being at the mercy of shifting networks, stable cultural tastes may act as a reciprocal driver of network maintenance, enabling individuals to sustain interaction across constantly shifting personal communities. 

This research note empirically adjudicates between these divergent expectations using longitudinal panel data. Specifically, I address the following research questions: 
(1) Do cultural tastes exhibit the high volatility implied by network transmission models, or the high stability expected by cultural capital models? 
(2) When cultural taste loss does occur, is it primarily driven by life-course events associated with network turnover? 
(3) Does a broad, stable repertoire of cultural tastes (cultural capital) longitudinally predict the maintenance of social connectivity, independent of reciprocal effects?

By leveraging the Project Canada Survey (1985-1995) and employing modern panel data estimators (discrete-time pooled logits and Mundlak within-between Poisson models), this note provides a direct test of the cultural capital versus network transmission frameworks.

"""

data_to_results = lines[data_start:discussion_start]

new_discussion = """\\section{Discussion and Conclusion}\\label{discussion-and-conclusion}

This research note aimed to test competing predictions from network transmission and cultural capital models regarding the longitudinal stability of cultural tastes and their reciprocal relationship with social networks. 

The results reveal a clear pattern: cultural tastes exhibit remarkably high levels of stability over time (with roughly 98\\% retention over five-year periods), strongly contradicting the volatility corollary of traditional network transmission models. Tastes behave as durable forms of embodied cultural capital. However, the network-theoretic assumption that relational disruption drives taste loss receives strong support; when individuals do lose a taste, it is significantly predicted by network turnover events such as changes in friendship interaction, organizational memberships, and geographic mobility. 

Furthermore, the Mundlak Poisson models provide robust evidence for the culture conversion model (Lizardo 2006). Between-person differences in cultural taste breadth significantly predict the maintenance of both informal social interactions (friends) and formal ties (organizational memberships) over time. The lack of significant within-person effects suggests that it is the stable, trait-like possession of cultural capital that maintains social connectivity, rather than short-term fluctuations in cultural activity.

Theoretical implications of these findings point toward a synthesis of the two models: tastes and networks operate in a feedback loop. Durable cultural tastes act as selective filters and stabilizing assets that help individuals maintain social ties (choice homophily), but structural shocks that disrupt these networks can subsequently erode cultural practices. 

A limitation of this study is the reliance on proxy measures for network size (frequency of interaction and organizational memberships) rather than full ego-network data. Future research should utilize more granular, multi-wave personal network generators alongside detailed cultural consumption diaries to further untangle the micro-dynamics of how cultural capital sustains specific dyadic ties during life-course transitions.

"""

post_matter = lines[ref_start:]

with open('manuscript_research_note.tex', 'w') as f:
    f.writelines(preamble)
    f.write(new_intro)
    f.writelines(data_to_results)
    f.write(new_discussion)
    f.writelines(post_matter)

print("Created manuscript_research_note.tex")
