server <- function(input,output,session){
  #======================
  # global server settings
  options(shiny.maxRequestSize=30*1024^2) 
  
  
  #=======================
  # help button
  observeEvent(input$help_btn, {
    # Show a simple modal
    shinyalert(title="Loading Data", type="info",
    text = "To get started, download the Extinction probability data template from the IUCN Red List website (see link in app). Fill this in for your species of interest. This provide information on the years with sightings of the targe species (records) and years in which surveys were conducted, but no animals were sighted (i.e. unsuccessful surveys). These two tables contain upper and lower probability limits for each. The format of the tables is as follows:
    
    1. Record data - a table with tree columns with the following headers: year, pci_lower, pci_upper
    2. Survey data - a table with seven columns with the following headers: year, eps_lower, eps_upper, pi_lxower, pi_upper, pr_lower, pr_upper
    
    
    The lower and upper bounds refer to:
    
    eps: the proportion of the taxon's habitat within its likely entire range that was surveyed (0 to 1)
    pi: the probability that the taxon, or recent evidence of it, could have been reliably identified in the survey if it had been recorded (0 to 1)
    pr: the probability that the taxon, or recent evidence of it, would have been recorded in the survey (0 to 1)
    pci: the probability that the taxon is correctly identified as extant (0 to 1)
    
    IMPORTANT!! The first year MUST be a record year. i.e. there cannot be unsuccessful surveys prior to the first record.
    
    Check out the demo files availaible form the github reporostory or the original Thompson et al. 2013 publication for help.
    
    For any problems, raise an issue in the github repository (link at bottom of page)"
    
    )
  })
  
  #=======================
  # Create reactive value that will either take input data or demo data
  
  user_data<-reactiveVal(NULL)
  
  
  #=======================
  # Load demo data on button press
  
  
  observeEvent(input$run_btn,{
    
      demo_data<-list()
      
      # get species
      
      demo_file <- "./t_rufolavatus/Tachybaptus rufolavatus.xlsx"
      
      
      demo_data$species<-read_excel(demo_file, sheet = "Threats", range = "B5" , col_names = F) %>%
        pull(`...1`)
      
      # get survey data
    
      demo_data$surveys<-read_excel(demo_file, sheet = "Surveys", range = anchored("A14", dim = c(1000, 10)),col_names = TRUE) %>%
        as_tibble() %>%
        drop_na()
      
      # get records data
      
      demo_data$records<-read_excel(demo_file, sheet = "Records", range = anchored("A9", dim = c(1000, 4),col_names = TRUE)) %>%
        as_tibble() %>%
        drop_na()
      
      # get passive survey data
      
      demo_data$passive_surveys<-read_excel(demo_file, sheet = "Surveys", range = "B11:J12" , col_names = TRUE) %>%
        as_tibble() %>%
        drop_na()
      
      # get threats data
      
      demo_data$threats<-read_excel(demo_file, sheet = "Threats", range = "A11:D13" , col_names = TRUE) %>%
        as_tibble() 
      
      
      # return list as output
      user_data(demo_data)
      
    
  })
 
  
  #=======================
  # Load user-specified input data
  
  # Load the user-uploaded dataset
  observeEvent(input$data_input, {
    
    # prepare list
    dat<-list()
    
    # get species
    file <- input$data_input
    ext <- tools::file_ext(file$datapath)
    
    req(file)
    validate(need(ext == "xlsx", "Please upload an xlsx file"))
    
    dat$species<-read_excel(file$datapath, sheet = "Threats", range = "B5" , col_names = F) %>%
      pull(`...1`)
    
    # get survey data
    
    dat$surveys<-read_excel(file$datapath, sheet = "Surveys", range = anchored("A14", dim = c(1000, 10)),col_names = TRUE) %>%
      as_tibble() %>%
      drop_na()
    
    # get records data
    
    dat$records<-read_excel(file$datapath, sheet = "Records", range = anchored("A9", dim = c(1000, 4),col_names = TRUE)) %>%
      as_tibble() %>%
      drop_na()
    
    # get passive survey data
    
    dat$passive_surveys<-read_excel(file$datapath, sheet = "Surveys", range = "B11:J12" , col_names = TRUE) %>%
      as_tibble() %>%
      drop_na()
    
    
    # return list as output
    user_data(dat)
    
  })
  
  
  
  #=======================
  # Get starting values for passive survey sliders
  
  observe({
    
    passive_surveys<-user_data()$passive_surveys
    
    updateSliderInput(inputId = "eps",
                      value = c(passive_surveys$eps_lower, passive_surveys$eps_upper))
    
    
    updateSliderInput(inputId = "pi",
                      value = pi_init<-c(passive_surveys$pi_lower, passive_surveys$pi_upper))
    
    updateSliderInput(inputId = "pr",
                      value = c(passive_surveys$pr_lower, passive_surveys$pr_upper))
    
    
  })
  
  #=======================
  # Reset sliders on button press
  
  observeEvent(ignoreInit = TRUE, input$reset_ext_btn,{
    
    passive_surveys<-user_data()$passive_surveys
    
    updateSliderInput(inputId = "eps",
                      value = c(passive_surveys$eps_lower, passive_surveys$eps_upper))
    
    
    updateSliderInput(inputId = "pi",
                      value = c(passive_surveys$pi_lower, passive_surveys$pi_upper))
    
    updateSliderInput(inputId = "pr",
                      value = c(passive_surveys$pr_lower, passive_surveys$pr_upper))
    
    
  })
  
  #=======================
  # Run extinct code

  
  pxt <- reactive({
    
    # ensure user data exists
    req(user_data())
    
    # update passive survey input from sliders
    eps<-input$eps
    pi<-input$pi
    pr<-input$pr
    
    
    # run extinction calculations
    
    pxt<-run_extinct(surveys=user_data()$surveys, records=user_data()$records,
                          eps=eps,pi=pi,pr=pr)
    
    pxt
    
  })
  
  
  
  #=======================
  # Plot extinction plot
  
  gg_ext<-reactive({
    
    # ensure pxt exits
    req(pxt())
    
    # make plot
    
    gg<-pxt() %>%
      ggplot(aes(x=year)) +
      geom_hline(aes(yintercept=0.5), linetype="dashed") +
      geom_hline(aes(yintercept=0.0), color="red") +
      geom_ribbon(aes(ymin=PXt.min, ymax=PXt.max), fill="grey70") +
      geom_ribbon(aes(ymin=MC_lower, ymax=MC_upper), fill="grey50") +
      scale_x_continuous(n.breaks=10) +
      geom_line(aes(y=PXt)) +
      theme_classic() +
      ggtitle(user_data()$species)
    
    
    gg
  })
  
      output$ext_ply<-renderPlotly({
        plotly::ggplotly(gg_ext())
      })
    
    
      #=======================
      # Get starting values for threats model
      
      observe({
        
        threats<-user_data()$threats
        
        updateSliderInput(inputId = "p_local",
                          value = c(threats$minimum[1], threats$maximum[1]))
        
        
        updateSliderInput(inputId = "p_spatial",
                          value = c(threats$minimum[2], threats$maximum[2]))
        
        
      })
      
      #=======================
      # Reset sliders on button press
      
      observeEvent(ignoreInit = TRUE, input$reset_threats_btn,{
        
        threats<-user_data()$threats
        
        updateSliderInput(inputId = "p_local",
                          value = c(threats$minimum[1], threats$maximum[1]))
        
        
        updateSliderInput(inputId = "p_spatial",
                          value = c(threats$minimum[2], threats$maximum[2]))
        
        
      })
      
      
      
  #=======================
  # Plot surveys vs. threats
      
      gg_pe<-reactive({
    
    # ensure pxt exits
    req(pxt())
    
    # make plot data
    survey_dat<-pxt() %>%
          slice_tail(n=1) %>%
          mutate(PE="records") %>%
          select(PE,minimum=PXt.max,maximum=PXt.min, best=PXt) %>%
          mutate(across(where(is.numeric), ~ 1-.x))
        
        
      threats_dat<-user_data()$threats
      
      # update threats data  from sliders
      threats_dat$minimum<-c(input$p_local[1],input$p_spatial[1])
      threats_dat$maximum<-c(input$p_local[2],input$p_spatial[2])
      threats_dat$best<-(threats_dat$minimum+threats_dat$maximum)/2 # currently takes the mean.. not ideal
      

    # make plotting data  
        plot_dat<-tibble(
          x=survey_dat$best,
          xmin=survey_dat$minimum,
          xmax=survey_dat$maximum,
          y=prod(threats_dat$best),
          ymin=prod(threats_dat$minimum),
          ymax=prod(threats_dat$maximum)
        )
        
        
    # make plot
    
    ## make colour gradient
        grid_fill <- expand.grid(x=seq(0, 1, length.out = 100),
                          y=seq(0, 1, length.out = 100))     # dataframe for all combinations
        
    gg<-plot_dat %>%
      ggplot(aes(x=x,y=y)) +
      geom_tile(data=grid_fill, aes(x, y, fill=x+y), alpha = 0.75) +
      geom_rect(aes(xmin = 0.9, xmax = 1, ymin = 0.9, ymax = 1),color="red",fill = NA) +
      geom_rect(aes(xmin = 0.5, xmax = 1, ymin = 0.5, ymax = 1),color="red",fill = NA) +
      geom_text(aes(x=1, y=0.5, label = "Critically Endangered"), hjust = 1.1, vjust=-1,
                color="red") +
      geom_text(aes(x=1, y=0.9, label = "Ex"), hjust = 1.2, vjust=-1,
                color="red") +
      geom_abline(aes(intercept=0, slope=1), linetype=2) +
      geom_point(size=3) + 
      geom_errorbar(aes(ymin = ymin,ymax = ymax),width = 0.01) + 
      geom_errorbarh(aes(xmin = xmin,xmax = xmax),height = 0.01) +
      labs(y="P(E) from Threats Model", x="P(E) from Records and Survey Model") +
      scale_fill_gradient(low='#e6ee9c', high='#f44336')  +
      theme_classic() +
      theme(legend.position="none",
            aspect.ratio=1)
    
    
    gg
  })
   ## # plotly output
   ##   output$pe_ply<-renderPlotly({
   ##     plotly::ggplotly(gg_pe())
   ##   })
  
  # plot output
      output$pe_gg<-renderPlot({
             gg_pe()
           })
      
  #=======================
  # Plot table
 # output$tbl<-renderTable(pxt())
    
  
}

