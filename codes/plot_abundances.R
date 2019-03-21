# concatenate historical aedes data ----------------------------------------------------------
(list=ls()) #remove previous variable assignments

# load libraries
library(plyr)
library(ggplot2)

# load data
load("concatenated_data/aedes_collections.RData")

# plot positive counties -------------------------------------------------------------------
# format data
aedes_collections$Location <- paste0(aedes_collections$county, ", ", aedes_collections$state)
aedes_collections$Date <- paste(aedes_collections$year, aedes_collections$month, "01", sep='-')
aedes_collections$Date <- as.Date(aedes_collections$Date, "%Y-%m-%d")

# subset data to counties with mosquitoes
aegypti <- unique(aedes_collections$county[aedes_collections$num_aegypti_collected>0])
albopictus <- unique(aedes_collections$county[aedes_collections$num_albopictus_collected>0])
aegypti.df <- aedes_collections[aedes_collections$county %in% aegypti,]
albopictus.df <- aedes_collections[aedes_collections$county %in% albopictus,]

# plot
ggplot(data=aegypti.df, aes(x=Date, y = num_aegypti_collected, group=Location)) + geom_line() + facet_wrap(~Location, scales = 'free') + theme_bw() + ylab("Abundance of Aedes aegypti")
ggplot(data=albopictus.df, aes(x=Date, y = num_albopictus_collected, group=Location)) + geom_line() + facet_wrap(~Location, scales = 'free') + theme_bw() + ylab("Abundance of Aedes albopictus")

