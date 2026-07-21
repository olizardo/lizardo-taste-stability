require(ggplot2)
require(foreign)

setwd("C:/Users/olizardo/Google Drive/NetSense/WORK/Matt Work")

dat <- read.csv("demsurveyMergedCoded.csv")
dat$extraDiff <- dat$extraversion_2 - dat$extraversion_1
dat$agreeDiff <- dat$agreeableness_2 - dat$agreeableness_1
dat$neuroDiff <- dat$neuroticism_2 - dat$neuroticism_1
dat$consDiff <- dat$conscientiousness_2 - dat$conscientiousness_1
dat$ethnicity_1[dat$ethnicity_1 == ''] <- NA 
plot.dat <- na.omit(dat[, c("extraDiff", "ethnicity_1", "gender_1")])

p <- ggplot(plot.dat, aes(y = extraDiff, x = reorder(factor(ethnicity_1), extraDiff, median), shape = factor(gender_1), color = factor(ethnicity_1)))
p <- p + geom_jitter(position = position_jitter(width = 0.05, height = 0.1), alpha = 0.75, size = 2.5)
p <- p + theme_minimal() + geom_hline(yintercept = 0) + coord_flip() 
p <- p + labs(y = "Time 2 vs. Time 1 Difference", x = "", color = "", shape = "", title = "Extraversion") 
p <- p + guides(color = FALSE)
p
setwd("C:/Users/olizardo/Google Drive/NetSense/WORK/Omar Work")
savePlot(filename = "extraDiff-eth.png", type = "png")	


p <- ggplot(dat, aes(x = factor(ethnicity_1), color = factor(ethnicity_1), y = consDiff))
p <- p + geom_jitter(position = position_jitter(width = 0.05, height = 0.1), alpha = 0.75, size = 2.5)
p <- p + theme_minimal() + geom_hline(yintercept = 0) + coord_flip() 
p <- p + labs(y = "Time 2 vs. Time 1 Difference", x = "", color = "", shape = "", title = "Conscientiousness") 
p <- p + guides(color = FALSE)
p

p <- ggplot(dat, aes(x = factor(ethnicity_1), color = factor(ethnicity_1), y = neuroDiff))
p <- p + geom_jitter(position = position_jitter(width = 0.05, height = 0.1), alpha = 0.75, size = 2.5)
p <- p + theme_minimal() + geom_hline(yintercept = 0) + coord_flip() 
p <- p + labs(y = "Time 2 vs. Time 1 Difference", x = "", color = "", shape = "", title = "Neuroticism") 
p <- p + guides(color = FALSE)
p



