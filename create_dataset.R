library(dplyr)
library(tidyr)

possible_dir <- c("~/Documents/mcc/panel/panel_methods_slides")
repmis::set_valid_wd(possible_dir)

income <- read.csv("data/income/2005/D120305_1779_GeoPolicy_MSOA.CSV",skip=5,na.strings="x") %>% 
  mutate(income_est = as.numeric(Average.Weekly.Household.Total.Income.Estimate)) %>%
  select(GOR_NAME:MSOA_NAME,income_est) %>%
  mutate(GOR_NAME = as.character(GOR_NAME))
energy <- read.csv("data/energy/2005/H320305_2010_GeoPolicy_MSOA.CSV",skip=5,na.strings="x") %>% 
  mutate(energy_consumption_alt = as.numeric(Total.Consumption.of.Domestic.Electricity.and.Gas)/
           as.numeric(Number.of.Ordinary.Domestic.Electricity.meters),
         energy_consumption = Average.Consumption.of.Ordinary.Domestic.Electricity +
           Average.Consumption.of.Domestic.Gas
  ) %>%
  select(MSOA_CODE,energy_consumption,energy_consumption_alt,Total.Consumption.of.Domestic.Electricity.and.Gas,Number.of.Ordinary.Domestic.Electricity.meters)
pop_density <- read.csv("data/pop_density/2001/UV020301_790_GeoPolicy_UK_MSOA.CSV",skip=5,na.strings="x") %>% 
  mutate(pop_density = as.numeric(Density..Number.of.Persons.per.Hectare.)) %>%
  select(MSOA_CODE,pop_density)
age <- read.csv("data/age/2001/UV040301_92_GeoPolicy_UK_MSOA.CSV",skip=5)
household_size <- read.csv("data/household_size/2001/UV510301_144_GeoPolicy_UK_MSOA.CSV",skip=5,na.strings="x")

mean_cols <-   function(a,start,end) {
  x <-numeric(0)
  for(i in names(a[,start:end])) {
    age_b <- as.numeric(gsub("X","",i))
    r <- rep(age_b,a[,i])
    x <- c(x,r)
  }
  m <- mean(x,na.rm=TRUE)
  return(m)
}

for (k in 1:nrow(age)) {
  age[k,"mean_age"] = mean_cols(age[k,],3,83)
}

age <- age %>%
  select(MSOA_CODE,mean_age)

for (k in 1:nrow(household_size)) {
  household_size[k,"mean_household_size"] = mean_cols(household_size[k,],2,9)
}

household_size <- household_size %>%
  select(MSOA_CODE,mean_household_size)

dataset <- merge(income,energy,by=c("MSOA_CODE"))
dataset <- merge(dataset,pop_density,by=c("MSOA_CODE"))
dataset <- merge(dataset,age,by=c("MSOA_CODE"))
dataset <- merge(dataset,household_size,by=c("MSOA_CODE"))
#dataset <- left_join(income,energy)
#dataset <- right_join(income,energy)
#dataset <- cbind(income,energy)

dataset[dataset$GOR_NAME=="","GOR_NAME"] <- "Wales"

write.csv(dataset,"data/dataset.csv")
foreign::write.dta(dataset, "data/dataset.dta")
