import re

with open("manuscript.tex", "r") as f:
    content = f.read()

# Replace Unicode Delta with LaTeX Delta in math mode
content = content.replace("Δ", r"$\Delta$")

# Remove image1.emf inclusion and Figure 1 since we stripped Table 1 and Table 2 already
content = re.sub(r"\\includegraphics\[.*?\]\{media/image1\.emf\}", "", content)
content = re.sub(r"Figure 1\n", "", content)
content = re.sub(r"Table 1\.\n", "", content)

# I should also just remove "Figure\n\nTable 1.\n" which might be lingering at the bottom
content = content.replace("Figure\n\nTable 1.\n\n", "")
content = content.replace("Figure\n", "")

with open("manuscript.tex", "w") as f:
    f.write(content)

