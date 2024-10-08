read_extinct_excel<-function(x){
  # where x is the input$file uploaded by the user
  

  # get file path and extension
  file <- x
  ext <- tools::file_ext(x)
  
  req(file)
  validate(need(ext == "xlsx", "Please upload an xlsx file"))

  # prepare empty listlist
  dat<-list()
  
  # get species name
    
  dat$species<-read_excel(file, sheet = "Threats", range = "B5" , col_names = F) %>%
    pull(`...1`)
  
  # get threats probabilities
  
  dat$threats<-read_excel(file, sheet = "Threats", range = "B11:D13" , col_names = TRUE) %>%
    as_tibble() %>%
    mutate(parameter=c("p_local","p_spatial")) %>%
    pivot_longer(-parameter, names_to="bound") %>%
    group_by(parameter) %>%
    summarise(named_vec = list(value)) %>%
    deframe()
  
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
