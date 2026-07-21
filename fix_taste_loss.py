with open("manuscript.tex", "r") as f:
    content = f.read()

old_text = r"""To investigate the hypotheses related to cultural taste loss, I selected two activities associated with the consumption of culture and the arts (Alexander 2003; Crane 1993; DiMaggio 2000) as well as one activity related to the consumption of mass print media (van Eijck and van Rees 2000; van Rees, Vermunt, and Verboord 1999) (1) listening to music, (2) reading books of fiction not related to work, (3) reading the newspaper, (4) following a sports team. The criteria for selection of these activities is that they represented common, but relatively low cost (in terms of mobility and geographical accessibility) forms of cultural participation and expression of cultural taste (as opposed to attending a play or going to see a movie in a movie theater, which may decline for factors orthogonal to changing tastes)."""

new_text = r"""To investigate the hypotheses related to cultural taste loss, I examine nine activities that encompass both at-home consumption and outside leisure (Alexander 2003; Crane 1993; DiMaggio 2000; van Eijck and van Rees 2000): (1) listening to music, (2) going to the movies, (3) attending a sporting event, (4) reading the newspaper, (5) reading books of fiction, (6) watching videos, (7) engaging in a hobby, (8) reading magazines, and (9) following a sports team. This broad selection captures a wide array of potential taste changes over time across different domains of cultural participation."""

content = content.replace(old_text, new_text)

# Also fix the reference in the breadth index part
old_breadth = "In addition to the four activities discussed above"
new_breadth = "Using the same set of items,"
content = content.replace(old_breadth, new_breadth)

with open("manuscript.tex", "w") as f:
    f.write(content)
