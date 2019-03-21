# CDC Aedes forecasting challenge ---------------------------------
rm(list=ls()) #remove previous variable assignments

# load libraries
library(plyr)

# load data
load("concatenated_data/aedes_collections.RData")
AC_county_coords <- read.csv("data/AC_county_coords.csv", head=T, stringsAsFactors=F)
us_census_data <- read.csv("data/us_census_data.csv", head=T, stringsAsFactors=F)

# subset by unique counties and calculate min and max date by county
aedes_collections <- ddply(aedes_collections, .(state, statefp, county, countyfp), summarize
                            , minimum_date = min(Date)-180
                            , maximum_date = max(Date))

# format demographic data
us_census_2015 <- us_census_data[,c("STATE", 'COUNTY', "STNAME", "CTYNAME", "POPESTIMATE2015", "RDEATH2015", "RBIRTH2015")]
colnames(us_census_2015) <- c("statefp", "countyfp", "state", "county", "Population", "Death_rate", "Birth_rate")
us_census_2015$county <- gsub(" County", "", us_census_2015$county)

# format geographic coordinate data
AC_county_coords <- AC_county_coords[,c("STATEFP", "COUNTYFP", "NAME", "Lat", "Long")]
colnames(AC_county_coords) <- c("statefp", "countyfp", "county", "Latitude", "Longitude")

# combine population data for each county in collection dataset
aedes_collections_counties <- merge(aedes_collections, us_census_2015, by=c("statefp", "countyfp", "state", "county"), all.x=T)
aedes_collections_counties <- merge(aedes_collections_counties, AC_county_coords, by=c("statefp", "countyfp", "county"), all.x=T)

# save data
save(aedes_collections_counties, file = "concatenated_data/county_populations.RData")
