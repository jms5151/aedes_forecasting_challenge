# aedes_forecasting_challenge

Stanford University & University of Florida model for the 2019 CDC Aedes Forecasting challenge (https://predict.cdc.gov/post/5c4f6d687620e103b6dcd015)

Team name: Aedes ladies

Model description: 
We are using mechanistic compartmental models to predict mosquito abundances through time and then using statistical models to calculate 
the probability of mosquito presence as a function of predicted mosquito abundance from the mechanistic models. We used an SEI-SEIR model framework developed to predict dengue transmission (see Huber et al. 2018 below for equations) and parameterized separate models for Aedes aegypti and Aedes albopictus based on species-specific temperature-dependent mosquito traits. We allowed mosquito carrying capacity to vary with rainfall (moving window of monthly rainfall accumulation). We ran the mechanistic models using demographic and weather data for the 95 counties participating in this challenge to produce a time series of retrospectively predicted mosquito abundances for each species. Using logistic regressions, we calculated the probability of Aedes aegypti or Aedes albopictus presence as a function of predicted mosquito abundance from the mechanistic model with county as a fixed effect. For each monthly forecast, we run the mechanistic models using 16-day weather forecasts and use the output of estimated mosquito abundances in the logistic regression models to produce probabilities of mosquito presence for Aedes aegypti and Aedes albopictus.

Description of codes in repository:
Mechanistic models:
- SEI-SEIR_aegypti_model.R: Aedes aegypti SEI-SEIR model
- SEI-SEIR_albopictus_model.R: Aedes albopictus SEI-SEIR model

Static data concatenation:
- combine_counties_with_population_data.R: combines human population size, birth rate, and death rate for all 95 US counties with historical mosquito data.

Simulations with training data and model development: 
- combine_historical_mosquito_data.R: combines data on mosquito abundances for both species for all 95 counties provided by the CDC.
- subset_historical_weather_data.R: concatenate daily time series of temperature and a moving window of 30-day accumulated rainfall corresponding to the time period where historical mosquito data was collected.
- SEI-SEIR_simulate.R: run mechanistic model simulations for Aedes aegypti and Ae. albopictus
- logistic_regression_models.R: create regression models to predict the probability of mosquito presence for each species given mechanistic model output

Forecasting:
- concat_forecast_weather_data.R: concatenate daily time series of temperature and a moving window of 30-day accumulated rainfall for all 95 counties for previous month and 16-day forecasted weather data.
- SEI-SEIR_simulate.R: run mechanistic model simulations for Aedes aegypti and Ae. albopictus (same code used for training data)
- forecast.R: predict probability of mosquito presence based on updated simulations with forecasted weather data and plot results.

Data sources: 
 - CDC Aedes Forecasting challenge mosquito abundance data for 95 US counties (https://predict.cdc.gov/post/5c4f6d687620e103b6dcd015) 
 - human population size, birth rates, and death rates from the U.S. Census (https://www.census.gov/data/tables/2017/demo/popest/counties-total.html) 
 - modeled daily mean temperature and precipitation data from NOAA (https://www.esrl.noaa.gov/psd/forecasts/reforecast2/download.html)
 
Computational resources: 
 - R statistical software v 3.5.1
 
Previous publications associated with this model:
1.	Mordecai, Erin A., et al. "Detecting the impact of temperature on transmission of Zika, dengue, and chikungunya using
        mechanistic models." PLoS neglected tropical diseases 11.4 (2017): e0005568. 
        https://journals.plos.org/plosntds/article?rev=1&id=10.1371/journal.pntd.0005568
2.	Huber, John H., et al. "Seasonal temperature variation influences climate suitability for dengue, chikungunya, and Zika 
        transmission." PLoS neglected tropical diseases 12.5 (2018): e0006451. 
        https://journals.plos.org/plosntds/article?id=10.1371/journal.pntd.0006451
