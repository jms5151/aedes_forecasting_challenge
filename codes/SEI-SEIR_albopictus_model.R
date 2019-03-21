# Temperature, humidity, and rainfall dependent SEI-SEIR model
seiseir_albopictus_model <- function(t, state, parameters) {
  with(as.list(c(state,parameters)), {
    dM1 <- (EFD(temp[t])*pEA(temp[t])*MDR(temp[t])*mu_t(temp[t])^(-1))*(M1+M2+M3)*max((1-((M1+M2+M3)/K_tr(temp[t], rain[t], Rmax, (S+E+I+R)))),0)-min((a(temp[t])*pMI(temp[t])*I/(S+E+I+R)+mu_t(temp[t])*M1), M1)
    dM2 <- (a(temp[t])*pMI(temp[t])*I/(S+E+I+R))*M1-(PDR(temp[t])+mu_t(temp[t]))*M2
    dM3 <- PDR(temp[t])*M2-mu_t(temp[t])*M3
    dS <- -a(temp[t])*b(temp[t])*(M3/(M1+M2+M3+0.001))*S + BR*(S/1000)/360 - DR*(S/1000)/360 + ie*(S+E+I+R) - ie*S
    dE <- a(temp[t])*b(temp[t])*(M3/(M1+M2+M3+0.001))*S-(1.0/5.9)*E - DR*(E/1000)/360 - ie*E
    dI <- (1.0/5.9)*E-(1.0/5.0)*I - DR*(I/1000)/360 - ie*I
    dR <- (1.0/5.0)*I - DR*(R/1000)/360 - ie*R
    list(c(dM1, dM2, dM3, dS, dE, dI, dR))
  })
}    

# This is the general function for the Briere fit.
briere <- function(x, c, T0, Tm){
  if((x < T0) | (x > Tm))
    0.0
  else
    c*x*(x-T0)*sqrt(Tm-x)
}

# This is the general function for the quadratic fit. 
quadratic <- function(x, c, T0, Tm){
  if((x < T0) | (x > Tm))
    0.0
  else
    c*(x-T0)*(x-Tm)
}

# This is the general function for the inverted quadratic fit.
inverted_quadratic <- function(x, c, T0, Tm){
  if((x < T0) | (x > Tm))
    24.0
  else
    1.0/(c*(x-T0)*(x-Tm))
}

# Entomological parameters for the Ae. albopictus vector. 
# eggs per female per day = eggs laid per female per gonotrophic cycle * 1/gonotrophic cycle length
EFD <- function(temp){
  briere(temp,8.56e-03,14.58,34.61)*briere(temp,1.93e-04,10.25,38.32)
}

# probability egg to adult survival
pEA <- function(temp){
  quadratic(temp,-3.61e-03,9.04,39.33)
}

# mosquito development rate (1/larval development period)
MDR <- function(temp){
  briere(temp,6.38e-05,8.60,39.66)
}

# biting rate
a <- function(temp){
  briere(temp,1.93e-04,10.25,38.32)
}

# probability	of mosquito	infection per	bite	on	an	infectious	host (c in paper)
pMI <- function(temp){
  briere(temp,4.39e-04,3.62,36.82)
}

# adult mosquito mortality rate (1/adult lifespan)
mu_t <- function(temp){
  inverted_quadratic(temp,-1.43,13.41,31.51) # scaling helps for Ukunda *1.48
}

# parasite development rate
PDR <- function(temp){
  briere(temp,1.09e-04,10.39,43.05)
}

# transmission competence: probability of human	infection	per	bite	by	an	infectious mosquito
b <- function(temp){
  briere(temp,7.35e-04,15.84,36.40)
}

# carrying capacity (right skewed)
carrying_capacity_t <- function(temp, T0, EA, N){
  kappa <- 8.617e-05; # Boltzmann constant 
  alpha <- (EFD(T0)*pEA(T0)*MDR(T0)*mu_t(T0)^(-1)-mu_t(T0))/(EFD(T0)*pEA(T0)*MDR(T0)*mu_t(T0)^(-1))
  (alpha*N*exp(-EA*((temp-T0)^2)/(kappa*(temp+273.0)*(T0+273.0))))
}

K_tr <- function(temp, rain, Rmax, N){
  R0 <- 1
  if((rain < R0) | (rain > Rmax)){
    0.01*carrying_capacity_t(temp,26.0,0.05, N)
  }
  else {
    c <- -5.99e-03
    carrying_capacity_t(temp,26.0,0.05, N)*(c*(rain-R0)*(rain-Rmax))/(rain/4) + 0.001
  }
}

