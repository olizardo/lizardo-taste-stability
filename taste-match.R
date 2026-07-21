library("Hmisc")
library("foreign")
library("Matrix")
library("lme4")
library("texreg")

mydata <- stata.get("C:/Users/olizardo/Google Drive/SOCIOLOGY OF CULTURE/taste-change/decay-long.dta")
mydata$close <- as.numeric(mydata$closeness)
mydata <- mydata[which(mydata$close != "NA"), ]


mod1 <- glmer(decay ~ factor(time) + (1 | sender), data = mydata, family = binomial(link = "logit"))
summary(mod1)

mod2 <- glmer(decay ~ factor(time) + 
music.match + movies.match + books.match + sports.match + games.match + outdoor.match + numshared.acts  
+ (1 | sender), data = mydata, family = binomial(link = "logit"))
summary(mod2)

mod3 <- glmer(decay ~ factor(time) + 
music.match + movies.match + books.match + sports.match + games.match + outdoor.match + numshared.acts  
+ close + (1 | sender), data = mydata, family = binomial(link = "logit"))
summary(mod3)

kin <- which(mydata$reltype == "Parent" | mydata$reltype == "Sibling" | mydata$reltype == "Other family")
fr <- which(mydata$reltype == "Friend")

kindata <- mydata[kin, ]
frdata <- mydata[fr, ]

mod4 <- glmer(decay ~ factor(time) + 
music.match + movies.match + books.match + sports.match + games.match + outdoor.match + numshared.acts  
+ close + (1 | sender), data = kindata, family = binomial(link = "logit"))

summary(mod4)

mod5 <- glmer(decay ~ factor(time) + 
music.match + movies.match + books.match + sports.match + games.match + outdoor.match + numshared.acts  
+ close + (1 | sender), data = frdata, family = binomial(link = "logit"))
summary(mod5)


png("match-coefs.png", width = 600, height = 800)
plotreg(list(mod4, mod5), naive = T,
		custom.model.names = 
			c("Kin Ties", "Friend Ties"),	
		custom.coef.names = 
			c("Constant", 
			"Wave.2",
			"Wave.3",
			"Wave.4", 
			"Wave.5",
			"Wave.6",
			"Music.Match",
			"Movies.Match", 
			"Books.Match",
			"Sports.Match",
			"Games.Match",
			"Outdoors.Match", 
			"N.Shared.Activities",
			"Closeness"),
			omit.coef = "(Constant)|(Wave.2)|(Wave.3)|(Wave.4)|(Wave.5)|(Wave.6)",
			xlim = c(-1, 1),
			lwd.inner = 2,
			lwd.outer = 0.35,
			lwd.vbars = 0,
			cex = 2,
			custom.note = ""
			)
require(png)
require(grid)
dev.off()
img <- readPNG("match-coefs.png")
grid.raster(img)

setwd("C:/Users/olizardo/Google Drive/SOCIOLOGY OF CULTURE/taste-change")
htmlreg(list(mod1, mod2, mod3, mod4, mod5), file = "reg-table.rtf",
		custom.model.names = 
			c("Baseline", "Cultural.Match", "Closeness", "Kin Ties", "Friend Ties"),	
		custom.coef.names = 
			c("Constant", 
			"Wave.2",
			"Wave.3",
			"Wave.4", 
			"Wave.5",
			"Wave.6",
			"Music.Match",
			"Movies.Match", 
			"Books.Match",
			"Sports.Match",
			"Games.Match",
			"Outdoors.Match", 
			"N.Shared.Activities",
			"Closeness"),
			custom.note = "",
			naive = T
			)
			
screenreg(list(mod1, mod2, mod3, mod4, mod5),
		custom.model.names = 
			c("Baseline", "Cultural.Match", "Closeness", "Kin Ties", "Friend Ties"),	
		custom.coef.names = 
			c("Constant", 
			"Wave.2",
			"Wave.3",
			"Wave.4", 
			"Wave.5",
			"Wave.6",
			"Music.Match",
			"Movies.Match", 
			"Books.Match",
			"Sports.Match",
			"Games.Match",
			"Outdoors.Match", 
			"N.Shared.Activities",
			"Closeness"),
			custom.note = "",
			naive = T
			)