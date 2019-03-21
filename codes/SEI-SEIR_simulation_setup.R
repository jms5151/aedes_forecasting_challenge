# data to set up model simulations -------------------------------------------------------------
rm(list=ls())

# load packages
library(deSolve)

# load data
load("concatenated_data/county_populations.RData")
load("concatenated_data/LHS_inputs.RData") # initial conditions
load("weather_data/historical_weather.RData")

# set immigration and emmigration rate
ie <- 0.01

# set up list of sites
counties <- aedes_collections_counties$county

# set human population numbers for each site 
population <- aedes_collections_counties$population

# set birth and death rates
BRs <- aedes_collections_counties$Birth_rate
DRs <- aedes_collections_counties$Death_rate

# model timestep
timestep = 1/12

# rainfall threshold
Rmax <- 400
