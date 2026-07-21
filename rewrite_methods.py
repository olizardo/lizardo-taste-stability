import re

with open("manuscript.tex", "r") as f:
    content = f.read()

# Replace the description of the random effects model and IV model with Mundlak and Poisson
# Look for sections mentioning random-effects and instrumental variables

old_methods = r"\\emph\{Random-effects models\}. I also present a model that accounts for unobserved heterogeneity by including an individual level random effect. However, while the random-effects model takes care of the unobserved heterogeneity issue, thus insuring that any observed effect of cultural taste breadth on social connectivity is not spuriously caused by some underlying individual-level factor that is constant across time, it is still open to the simultaneity bias caused by reciprocal causation going from social connectivity to taste breadth \(Lizardo 2006\)\. This model can be written as:.*?\\emph\{Instrumental variables random-effects models\}. To take this issue into account I also present a third specification, using an \\emph\{instrumental variables random effects model\}."

# We'll just manually replace the relevant paragraphs using string indexing if regex fails
