
# load data files for recordings and surveys
recordings <- read_csv("./c_maridadi/recordings.csv")
surveys <- read_csv("./c_maridadi/surveys.csv")

# Make a passive survey data table (set ranges of eps, pi and pr manually). Max years will be present year automatically. 
## if last survey year is used: max(recordings$year, surveys$year)

passive_surveys<- tibble(
  year = min(recordings$year, surveys$year):lubridate::year(Sys.Date()),
  eps_lower=0.01,
  eps_upper=0.05,
  pi_lower=0.7,
  pi_upper=0.95,
  pr_lower=0.7,
  pr_upper=0.95
)

# remove survey and record years, and add real data from active surveys

all_surveys<-passive_surveys %>%
  filter(!year %in% c(recordings$year, surveys$year)) %>%
  bind_rows(surveys) %>%
  arrange(year)


### NOTE streamline this to with a fill_downup() function

## fill in 0 recordings for survey years

record_years<-tibble(
  year=sort(unique(c(recordings$year, all_surveys$year))),
  record=ifelse(year %in% recordings$year, 1, 0)
)

## run model
PXt= px.mid(recordings=recordings, surveys = all_surveys, all_years=record_years) ### NOTE: FIRST SURVEY YEAR NEEDS TO OCCUR AFTER THE FIRST RECORD!!!

# make nicer table
PXt_tbl<-PXt %>%
  as_tibble() %>%
  rename(MC_lower=V1,
         MC_upper=V3) %>%
  mutate(year=all_years$year) %>%
  select(year, everything())

PXt_tbl

## plot
gg<-PXt_tbl %>%
  ggplot(aes(x=year)) +
  geom_hline(aes(yintercept=0.5), linetype="dashed") +
  geom_hline(aes(yintercept=0.0), color="red") +
  geom_ribbon(aes(ymin=PXt.min, ymax=PXt.max), fill="grey70") +
  geom_ribbon(aes(ymin=MC_lower, ymax=MC_upper), fill="grey50") +
  scale_x_continuous(n.breaks=10) +
  geom_line(aes(y=PXt)) +
  theme_classic()

plotly::ggplotly(gg)

#The boundaries of the dark shaded region are 5% and 95% intervals derived from a Monte Carlo projection of the associated density functions, assuming normality and independence.
