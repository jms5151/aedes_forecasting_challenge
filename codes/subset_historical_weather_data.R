# concatenate ESRL historical temperature and rainfall data with trap data ----------------------------
# https://www.esrl.noaa.gov/psd/forecasts/reforecast2/download.html
# clear environment
rm(list=ls())

# load libraries
library(rvest)
library(ncdf4)
library(plyr)

# load data
load("concatenated_data/county_populations.RData")

# open nc files and extract climate data for each location and date with mmrr data
esrl_temp <- nc_open("D:/weather_data/tmp_2m_gaussian_all_20070101_20190317_jamiZy6qoJ.nc")
esrl_rain <- nc_open("D:/weather_data/rain_gaussian_all_20070101_20190317_jamiql4HP.nc")

# print(esrl_temp) # get attribute information

# subset esrl temperature and rainfall data: datasets are identical except for weather variable
nc_temp <- ncvar_get(esrl_temp, attributes(esrl_temp$var)$names[3]) # get temperature data
nc_rain <- ncvar_get(esrl_rain, attributes(esrl_rain$var)$names[3]) # get rainfall data

# subset esrl latitude and longitude data
nc_lat <- ncvar_get(esrl_temp, attributes(esrl_temp$dim)$names[2]) # get latitude data
nc_lon <- ncvar_get(esrl_temp, attributes(esrl_temp$dim)$names[3]) # get longitude data 
nc_lon2 <- nc_lon - 360 # need to subtract 360 to get [-180, 180]

# subset esrl dates
nc_time <- ncvar_get(esrl_temp, attributes(esrl_temp$var)$names[2]) # separate date data 
nc_time2 <- paste(substr(nc_time, 1,4), substr(nc_time, 5,6), substr(nc_time, 7,8), sep='-') # remove last two digits referring to hours 
nc_time2 <- as.Date(nc_time2, "%Y-%m-%d") # format date variable

# create new dataframe for weather data
historical_weather <- data.frame(matrix(ncol=4, nrow=0))
colnames(historical_weather) <- c("Date", "Temperature", "Rainfall", "county")

for (i in 1:nrow(aedes_collections_counties)){
  first_date <- which(nc_time2 == aedes_collections_counties$minimum_date[i]) 
  last_date <- which(nc_time2 == "2019-03-17") # last date of data download    
  closestLat <- which.min(abs(nc_lat-aedes_collections_counties$Latitude[i]))
  closestLon <- which.min(abs(nc_lon2-aedes_collections_counties$Longitude[i]))
  # use control ensemble (third variable spot in next two lines). 1=control, 2-11=perturbations. for (j in 1:11){ to loop through ensembles here. 
  Temperature <- round(nc_temp[closestLon, closestLat, 1, first_date:last_date] − 273.15)
  Rainfall <- round(nc_rain[closestLon, closestLat, 1, first_date:last_date])
  Date <- nc_time2[first_date:last_date]
  tmp_df <- data.frame(Date, Temperature, Rainfall) 
  tmp_df$county <- aedes_collections_counties$county[i]
  historical_weather <- rbind(historical_weather, tmp_df)
}

nc_close(esrl_temp)
nc_close(esrl_rain)

# remove NA values and change column order
historical_weather <- historical_weather[complete.cases(historical_weather),c("Date", "county", "Temperature", "Rainfall")]

# ESRL data is missing for 2017-11-29. Average temperature and rainfall values from day before and after this date 
nov2017 <- subset(historical_weather, Date == "2017-11-28" | Date == "2017-11-30")
nov2017 <- ddply(nov2017, .(county), summarize, Temperature = mean(Temperature), Rainfall = mean(Rainfall))
nov2017$Date <- as.Date("2017-11-29", "%Y-%m-%d")

#  merge and order data by county and date
historical_weather <- rbind(historical_weather, nov2017)
historical_weather <- historical_weather[order(historical_weather$county, historical_weather$Date), ]

# save data
save(historical_weather, file="weather_data/historical_weather.RData")