
run_extinct<-function(records, surveys, eps, pi, pr){

  
  # Make a passive survey data table (set ranges of eps, pi and pr from slider input). 
  # Max years will be present year automatically.if last survey year is to be used, change to: max(records$year, surveys$year)
  

  passive_surveys<- tibble(
     year = min(records$year, surveys$year):lubridate::year(Sys.Date()),
     eps_lower=eps[1],
     eps_upper=eps[2],
     pi_lower=pi[1],
     pi_upper=pi[2],
     pr_lower=pr[1],
     pr_upper=pr[2]
  )
  # remove survey and record years, and add real data from active surveys
  
  all_surveys<-passive_surveys %>%
    filter(!year %in% c(records$year, surveys$year)) %>%
    bind_rows(surveys) %>%
    arrange(year)
  

  
  ## fill in 0 records for survey years
  
  record_years<-tibble(
    year=sort(unique(c(records$year, all_surveys$year))),
    record=ifelse(year %in% records$year, 1, 0)
  )
  
  ## run model
  PXt= px.mid(records=records, surveys = all_surveys, all_years=record_years) ### NOTE: FIRST SURVEY YEAR NEEDS TO OCCUR AFTER THE FIRST RECORD!!!
  
  # make nicer table
  PXt_tbl<-PXt %>%
    as_tibble() %>%
    rename(MC_lower=V1,
           MC_upper=V3) %>%
    mutate(year=record_years$year) %>%
    select(year, everything())
  
  return(PXt_tbl)
}

