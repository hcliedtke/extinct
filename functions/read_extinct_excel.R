read_extinct_excel<-function(x){
  # where x is the input$file uploaded by the user
  
  # prepare list
  dat<-list()
  
  # get species
  file <- x
  ext <- tools::file_ext(x)
  
  req(file)
  validate(need(ext == "xlsx", "Please upload an xlsx file"))
  
  dat$species<-read_excel(file, sheet = "Threats", range = "B5" , col_names = F) %>%
    pull(`...1`)
  
  # get survey data
  
  dat$surveys<-read_excel(file, sheet = "Surveys", range = anchored("A14", dim = c(1000, 10)),col_names = TRUE) %>%
    as_tibble() %>%
    drop_na(year)
  
  # get records data
  
  dat$records<-read_excel(file, sheet = "Records", range = anchored("A9", dim = c(1000, 4),col_names = TRUE)) %>%
    as_tibble() %>%
    drop_na(year)
  
  # get passive survey data
  
  dat$passive_surveys<-read_excel(file, sheet = "Surveys", range = "B11:J12" , col_names = TRUE) %>%
    as_tibble() %>%
    pivot_longer(everything(), names_to = "parameter") %>%
    separate(parameter, sep="_", into=c("parameter","bound")) %>%
    group_by(parameter) %>%
    summarise(named_vec = list(value)) %>%
    deframe()
  
  
  
  # return list as output
  return(dat)
}
