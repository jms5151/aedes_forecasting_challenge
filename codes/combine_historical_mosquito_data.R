# combine historical mosquito data -------------------------------------------------------------------
# load data
aedes.files <- list.files("data/")

for (i in 1:length(aedes.files)){
  filePath <- paste0("data/", aedes.files[i])
  x <- read.csv(filePath, head=T, stringsAsFactors = F)
  fileName <- substr(aedes.files[i], 1, nchar(aedes.files[i])-4)
  assign(fileName, x)
}

# rbind aedes data
aedes_collections <- do.call(rbind, list(aedes_collections_california
                                         , aedes_collections_connecticut
                                         , aedes_collections_florida
                                         , aedes_collections_new_jersey
                                         , aedes_collections_new_york
                                         , aedes_collections_north_carolina
                                         , aedes_collections_texas
                                         , aedes_collections_wisconsin))

# set date as last day of month
library(lubridate)
aedes_collections$Date <- paste(aedes_collections$year, aedes_collections$month, "01", sep='-')
aedes_collections$Date <- as.Date(aedes_collections$Date, "%Y-%m-%d")
aedes_collections$Date <- ceiling_date(aedes_collections$Date, "month") - days(1)

# save data
save(aedes_collections, file="concatenated_data/aedes_collections.RData")
