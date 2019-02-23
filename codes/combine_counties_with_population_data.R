# CDC Aedes forecasting challenge ---------------------------------
rm(list=ls()) #remove previous variable assignments

# load libraries
library(plyr)

# load data
aedes.files <- list.files("data/")

for (i in 1:length(aedes.files)){
  filePath <- paste0("data/", aedes.files[i])
  x <- read.csv(filePath, head=T, stringsAsFactors = F)
  fileName <- substr(aedes.files[i], 1, nchar(aedes.files[i])-4)
  assign(fileName, x)
}

# fix state name for wisconsin
colnames(aedes_collections_wisconsin)[colnames(aedes_collections_wisconsin)=="ï..state"] <- "state"

# connect popuation data
colnames(fid_sum_pop_tl)[colnames(fid_sum_pop_tl)=="OBJECTID"] <- "FID"

fid_merged <- merge(fid_sum_pop_tl, tl_2016_us_county, by="FID")
fid_merged$population <- fid_merged$AREA * fid_merged$SUM

# subset and rename columns 
fid_merged <- fid_merged[,c("STATEFP", "COUNTYFP", "NAME", "population")]
colnames(fid_merged) <- c("statefp", "countyfp", "county", "population")

# rbind aedes data
aedes_collections <- do.call(rbind, list(aedes_collections_california, aedes_collections_connecticut, aedes_collections_north_carolina, aedes_collections_wisconsin))

# subset by unique counties
aedes_collections_counties <- aedes_collections[,c("state", "statefp", "county", "countyfp")]
aedes_collections_counties <- aedes_collections_counties[!duplicated(aedes_collections_counties),]

# combine population data for each county in collection dataset
aedes_collections_counties <- merge(aedes_collections_counties, fid_merged, by=c("statefp", "countyfp", "county"))

# save data
save(aedes_collections_counties, file = "data/county_populations.RData")
