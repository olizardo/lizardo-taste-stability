import re

with open('manuscript_research_note.tex', 'r') as f:
    text = f.read()

# 1. Fix the mention of 'videos' in the results
old_video_text = "Changes in work status also have the expected positive effects on taste loss for select domains (like videos), although they are not uniformly significant across the board."
new_video_text = "Changes in work status also have expected positive effects on taste loss for select domains, although they are not uniformly significant across the board."
text = text.replace(old_video_text, new_video_text)

# 2. Convert parenthetical citations to \citep{}
cite_map = {
    "(Lazarsfeld and Merton 1954; McPherson, Smith-Lovin, and Cook 2001)": "\\citep{lazarsfeld1954, mcpherson2001}",
    "(Mark 1998b, 2003)": "\\citep{1998b, 2003}",
    "(Burt 2000; Suitor, Wellman, and Morgan 1997)": "\\citep{burt2000, suitor1997}",
    "(Bourdieu 1984; Holt 1998)": "\\citep{bourdieu1984, holt1998}",
    "(Lizardo 2006)": "\\citep{lizardo2006}",
    "(McPherson 1983; McPherson and Smith-Lovin 1987)": "\\citep{mcpherson1983, mcpherson1987}",
    "(Suitor and Keeton 1997)": "\\citep{suitorkeeton1997}",
    "(Fischer and Oliker 1983)": "\\citep{fischer1983}",
    "(Degenne and Lebeaux 2005)": "\\citep{degenne2005}",
    "(Munch, McPherson, and Smith-Lovin 1997)": "\\citep{munch1997}",
    "(Brass 1985; Ibarra 1992; Straits 1996)": "\\citep{brass1985, ibarra1992, straits1996}",
    "(Bidart and Lavenu 2005)": "\\citep{bidart2005}",
    "(Relish 1997)": "\\citep{relish1997}",
    "(Gerstel 1988; Leslie and Grady 1985; Milardo 1987; Pahl and Pevalin 2005)": "\\citep{gerstel1988, leslie1985, milardo1987, pahl2005}",
    "(Anderson 1984; Morgan, Carder, and Neal 1997; Morgan, Neal, and Carde 1997)": "\\citep{anderson1984, morgan1997, morganetal1996}",
    "(Belsky and Rovine 1984; Bott 1971; Munch, McPherson, and Smith-Lovin 1997)": "\\citep{belsky1984, bott1971, munch1997}",
    "(Long 2003)": "\\citep{long2003}",
    "(McPherson, Popielarz, and Drobnic 1992; Popielarz and McPherson 1995)": "\\citep{mcpherson1992, popielarz1995}",
    "(Allison 1982)": "\\citep{allison1982}",
    "(Popielarz and McPherson 1995)": "\\citep{popielarz1995}",
    "(Suitor, Wellman, and Morgan 1997; Wellman \\emph{et al.} 1997)": "\\citep{suitor1997, wellman1997}"
}

for old, new in cite_map.items():
    text = text.replace(old, new)

# add natbib to preamble if not there
if "\\usepackage{natbib}" not in text:
    text = text.replace("\\usepackage{bookmark}", "\\usepackage{natbib}\n\\usepackage{bookmark}")

with open('manuscript_research_note.tex', 'w') as f:
    f.write(text)

