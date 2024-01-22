

# set species working directory
setwd("~/Dropbox/John PhD documents/IUCN/extinction/c_maridadi/")

# load functions
source("../_functions_thompson_et_al.R")

# load data files for recordings and surveys
recordings <- read.csv("recordings.csv")
surveys <- read.csv("surveys.csv")

# data for passive surveys
#data for passive surveys
pi = c(0.06, 0.14)
eps.passive = c(0.01,	0.05)
pi.passive = c(0.7,	0.95)
pr.passive = c(0.7,	0.95)
pas.sur = c(eps.passive ,pi.passive,pr.passive)




#total number of years
years = seq(min(recordings[,'year'],surveys[,'year']),max(recordings[,'year'],surveys[,'year']),by =
              1)
Total.years = length(years)

#add passive surveys to the surveys
pas.sur.years = years[!years %in% surveys[,1] &
                        !years %in% recordings[,1]] #find years without either surveys or recordings
pas.surveys = cbind(pas.sur.years,t(replicate(length(pas.sur.years), pas.sur)))

colnames(pas.surveys) = names(surveys)
surveys = rbind(surveys,pas.surveys)

rec.year = cbind(recordings[,'year'],1) #whether a recording was made this year
rec.year = rbind(rec.year,cbind(surveys[,'year'],0))
rec.year = rec.year[order(rec.year[,1]),]


PXt= px.mid() ### NOTE: FIRST SURVEY YEAR NEEDS TO OCCUR AFTER THE FIRST RECORD!!!


# Plot the results -----------------------------
xx <- c(years, rev(years))


yysd=c( PXt[,1],rev(PXt[,3]))

yyint=c( PXt[,4],rev(PXt[,5]))

par(family="serif")
plot(
  years,PXt[,2], "l",ylim = c(0,1), xaxt = 'n',xaxs = "i", yaxs = "i" ,xlab =
    "Years", ylab = "P(X|t)"
)

polygon(xx, yyint, col = 'lightgrey', border = NA)
polygon(xx, yysd, col = 'darkgrey', border = NA)

lines(years,PXt[,2], "l")

axis(1, at = seq(min(years), max(years), by = 3), las = 2)
axis(1, at = c(min(years), max(years)), las = 2)

# Table of results -----------------------------
# PXt = cbind(years,PXt.min,PXt.mid,PXt.max)
PXt = cbind(years,PXt)
print (PXt)

