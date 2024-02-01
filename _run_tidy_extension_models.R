
# set species working directory
setwd("~/Documents/git_projects/extinct/")
library(tidyverse)

# load functions
source("./_functions_thompson_et_al.R")

# load data files for recordings and surveys
recordings <- read_csv("./c_maridadi/recordings.csv")
surveys <- read_csv("./c_maridadi/surveys.csv")

# Make a passive survey data table (set ranges of eps, pi and pr manually)

passive_surveys<- tibble(
  year = min(recordings$year, surveys$year):max(recordings$year, surveys$year),
  eps_lower=0.01,
  eps_upper=0.05,
  pi_lower=0.7,
  pi_upper=0.95,
  pr_lower=0.7,
  pr_upper=0.95
)

# remove survey and record years, and add real data

all_years<-passive_surveys %>%
  filter(!year %in% c(recordings$year, surveys$year)) %>%
  bind_rows(surveys) %>%
  arrange(year)

### NOTE streamline this to with a fill_downup() function

## fill in 0 recordings for survey years

record_years<-tibble(
  year=sort(unique(c(recordings$year, all_years$year))),
  record=ifelse(year %in% recordings$year, 1, 0)
)

## run model
PXt= px.mid(recordings=recordings, surveys = surveys) ### NOTE: FIRST SURVEY YEAR NEEDS TO OCCUR AFTER THE FIRST RECORD!!!

