check_files<-function(file, user_data){
  
  # check file is .xslx
  xlsx_check<-tools::file_ext(file)=="xlsx"
  xlsx_log<-if(!xlsx_check) print("Please upload an excel file with an .xlsx extension")
  
  # check file has relevant sheets
  tabs<-excel_sheets(path = file)
  tabs_check<-all(c("Threats","Records","Surveys") %in% tabs)
  tabs_log<-if(!tabs_check) print("Please upload an excel file that contains at least the following sheets: 'Threats','Records','Surveys'")
  
  
  # check NAs
  na_check<-lapply(user_data, function(x) any(is.na(x)))
  na_check
  na_log<-if(any(na_check==T)) print(paste("The following tables/fields contain missing data (NAs): ", paste0(names(na_check)[na_check==T], collapse=",")))
  
  
  # check upper and lower bounds
  check_parameter_order<-function(x){
    if(is_tibble(x)){
      x %>%
        pivot_longer(-year) %>%
        separate(name, into=c("param","bound"), sep="_") %>%
        group_by(param, year) %>%
        mutate(value_lag=lag(value, default = value[1]),
               check= value>=value_lag) %>%
        pull(check) %>%
        all()
    } else {
      y<-lapply(x, function(x) all(x >= lag(x, default = x[1])))
      all(y==T)
    }
  }
  
  order_check<-list()
  order_check$surveys<-check_parameter_order(user_data$surveys)
  order_check$records<-check_parameter_order(user_data$records)
  order_check$survey<-check_parameter_order(user_data$passive_surveys)
  
  order_log<-if(!all(order_check==T)) print(paste("The following tables/fields have lower/upper parameter bounds that are not in ascending order: ", paste0(names(order_check)[order_check!=T], collapse=",")))
  
  # check first year is a record year
  year_check<-min(user_data$records$year)<min(user_data$surveys$year)
  year_log<-if(!year_check) print("The first year must be a 'Records' year.")
  ### output all errors
  
  error_list<-list()
  error_list$xlsx_log<-xlsx_log
  error_list$tabs_log<-tabs_log
  error_list$na_log<-na_log
  error_list$order_log<-order_log
  
  return(error_list)
  
}

