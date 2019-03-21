rm(list=ls()) #remove previous variable assignments

# load data
load("concatenated_data/historical_model_simulations.RData")
load("concatenated_data/aedes_collections.RData")

# format and merge data
aegypti_sims <- subset(historical_simulations, Model == "Aegypti")
albopictus_sims <- subset(historical_simulations, Model == "Albopictus")

aegypti_df <- merge(aegypti_sims, aedes_collections, by=c("county", "Date"), all=T)
albopictus_df <- merge(albopictus_sims, aedes_collections, by=c("county", "Date"), all=T)

# convert abundance data to presence/absence data 
aegypti_df$PA_aegypti <- ifelse(aegypti_df$num_aegypti_collected > 0, 1, 0)
albopictus_df$PA_albopictus <- ifelse(albopictus_df$num_albopictus_collected > 0, 1, 0)
# mosq_data$Mtot <- mosq_data$M1 + mosq_data$M2 + mosq_data$M3

# logistic regression for Aedes aegypti  
aegypti_model <- glm(PA_aegypti ~ M1 + M2 + M3 + county, family="binomial", data=aegypti_df)
aegypti_df$pred_aegypti <- predict(aegypti_model, aegypti_df)
aegypti_df$prob_aegypti <- exp(aegypti_df$pred_aegypti)/(1+exp(aegypti_df$pred_aegypti))
aegypti_df$pred_aegypti2 <- ifelse(aegypti_df$prob_aegypti > 0.5, 1, 0)
plot(aegypti_df$prob_aegypti, aegypti_df$PA_aegypti, main='Mtot')
table(aegypti_df$PA_aegypti, aegypti_df$pred_aegypti2)

# logistic regression for Aedes aegypti  
albopictus_model <- glm(PA_albopictus ~ M1 + M2 + M3 + county, family="binomial", data=albopictus_df)
albopictus_df$pred_albopictus <- predict(albopictus_model, albopictus_df)
albopictus_df$prob_albopictus <- exp(albopictus_df$pred_albopictus)/(1+exp(albopictus_df$pred_albopictus))
albopictus_df$pred_albopictus2 <- ifelse(albopictus_df$prob_albopictus > 0.5, 1, 0)
plot(albopictus_df$prob_albopictus, albopictus_df$PA_albopictus)
table(albopictus_df$PA_albopictus, albopictus_df$pred_albopictus2)

# save model objects
save(aegypti_model, file = "model_objects/aegypti_model.rda")
save(albopictus_model, file = "model_objects/albopictus_model.rda")
