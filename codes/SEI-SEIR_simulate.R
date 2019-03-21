# Temperature, humidity, and rainfall dependent SEI-SEIR model simulations -----------------------------------------------
source("codes/SEI-SEIR_simulation_setup")

# run simulations
historical_simulations <- data.frame(matrix(ncol = 11, nrow = 0))
colnames(historical_simulations) <- c("time", "M1", "M2", "M3", "S", "E", "I", "R", "Date", "county", "Model")
fileName <- "concatenated_data/historical_model_simulations.RData"
save(historical_simulations, file=fileName, row.names = F)
models <- c("Aegypti", "Albopictus")

for (mod in models){
  if (mod == "Aegypti"){
    source("codes/SEI-SEIR_aegypti_model.R")
    seiseir_model_tr <- seiseir_aegypti_model
  } else {
    source("codes/SEI-SEIR_albopictus_model.R")
    seiseir_model_tr <- seiseir_albopictus_model
  }
  for (l in 1:length(counties)){
    weatherData <- subset(historical_weather, county == counties[l])
    weatherData <- weatherData[complete.cases(weatherData),]
    temp <- weatherData$Temperature
    rain <- weatherData$monthly_rain
    H0 <- population[l]
    M0 <- K_tr(temp[1], rain[1], Rmax, H0)
    Date <- weatherData$Date
    BR <- BRs[l]
    DR <- DRs[l]
    times <- seq(1,length(Date), by=1)
    parameters <- c(EFD, pEA, MDR, K_tr, a, pMI, mu_t, PDR, b, timestep=timestep)
    state <- c(M1 = startIC$m1*M0, M2 = startIC$m2*M0, M3 = startIC$m3*M0, S = startIC$s*H0, E = startIC$e*H0, I = startIC$i*H0, R = startIC$r*H0)
    out <- ode(y = state, times = times, func = seiseir_model_tr, parms = parameters, method="rk4", atol = 1e-14, rtol = 1e-14, hini = timestep)
    out2 <- as.data.frame(out)
    out2$Date <- Date
    out2$county <- counties[l]
    out2$Model <- mod
    historical_simulations <- rbind(historical_simulations, out2)
    save(historical_simulations, file=fileName)
    cat("finished running ode for", mod, counties[l], "\n")
  }
}

