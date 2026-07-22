import re

with open("manuscript.tex", "r") as f:
    content = f.read()

content = content.replace("Where everything is as in (5), except that now the observation", "Here, the observation")
content = content.replace(r"\( (6)", r"\( (5)")

with open("manuscript.tex", "w") as f:
    f.write(content)
