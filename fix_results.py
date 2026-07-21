with open("manuscript.tex", "r") as f:
    content = f.read()

content = content.replace("four cultural taste domains", "nine cultural taste domains")
content = content.replace("for all four activities", "for all nine activities")
content = content.replace("three out of the four", "the majority of the nine")
content = content.replace("Across all four cultural forms", "Across all nine cultural forms")

with open("manuscript.tex", "w") as f:
    f.write(content)
