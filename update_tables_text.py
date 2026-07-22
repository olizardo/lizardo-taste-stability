import re

with open("manuscript.tex", "r") as f:
    content = f.read()

# 1. Update preamble for tabularray
if "tabularray" not in content:
    content = content.replace(r"\usepackage{longtable,booktabs,array}", r"\usepackage{longtable,booktabs,array}" + "\n" + r"\usepackage{tabularray,float,siunitx}")

# 2. Update the reference to Table 3 models in the Results section
new_results_text = r"""The results of the Mundlak (within-between) Poisson models of the effect of cultural capital (in the form of ``omnivore'' taste) on network outcomes across time periods are shown in Table 3.

The results are consistent with the culture conversion model, particularly when examining the robust between-person differences (the `mean` effects). I find that persons who display a persistently wide variety of tastes (a higher longitudinal mean of cultural breadth) sustain higher frequencies of social interaction across the time periods (\emph{p}\textless0.05). While this cross-sectional ``between'' effect does not offer definitive evidence of strict causality, it cements in a more robust longitudinal modeling framework those results reported by Lizardo (2006). Broad cultural tastes are strongly associated with sustaining larger and more active patterns of interpersonal engagement over time. 

Furthermore, we can see in the second column of the table that having a high average repertoire of tastes is not only useful in sustaining higher levels of informal social connectivity, but it also raises the chances of remaining tied to important social foci of interaction, such as voluntary associations (\emph{p}\textless0.05). Because recruitment (and the over-time stability of membership) into these foci is largely a matter of keeping alive the network ties that bind the individual to other members of the group (Popielarz and McPherson 1995), it is no surprise that whatever resource helps the individual to sustain social connections to other persons will also appear to sustain his or her connection to these larger social entities.

The Mundlak specification also allows us to evaluate the within-person effects---whether a temporary spike in an individual's cultural tastes over their own average translates to immediate gains in connectivity. The within-person effects for cultural taste breadth are smaller and only marginally significant for interaction with friends (\emph{p}\textless0.1), suggesting that it is the durable, trait-like possession of cultural capital (the between-person effect) rather than short-term fluctuations in cultural activity that primarily drives sustained social connectivity and organizational membership."""

pattern = re.compile(r"The results of the lagged, random effects.*?personal community network\.", re.DOTALL)
match = pattern.search(content)
if match:
    content = content[:match.start()] + new_results_text + content[match.end():]

# 3. Replace the actual tables at the end of the file.
# Let's find exactly "Table 2.\n" or similar
# We can find "\includegraphics[width=6.81597in,height=1.83194in]{media/image2.wmf}" and remove it
content = content.replace(r"\includegraphics[width=6.81597in,height=1.83194in]{media/image2.wmf}", r"")

# We want to replace the string "Table 2." up to just before Table 4 in the Appendix.
# Let's find "Table 2." that is at the end. (There's one around line 478).
# And we find "Table 4. Means"
table2_start = content.find("Table 2.\n")
table4_start = content.find("Table 4. Means")

if table2_start != -1 and table4_start != -1:
    new_tables = "\n\\input{tex/pcs_taste_change_modern.tex}\n\n\\input{tex/pcs_network_stability_modern.tex}\n\n"
    content = content[:table2_start] + new_tables + content[table4_start:]

with open("manuscript.tex", "w") as f:
    f.write(content)

