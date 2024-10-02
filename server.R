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
  
  # create a conditional rule to show/hide panels depending on data being uploaded 
  output$fileUploaded <- reactive({
    return(!is.null(input$data_input) | input$run_btn == 1)
  })
  outputOptions(output, "fileUploaded", suspendWhenHidden = FALSE)
  #=======================
  # Load demo data on button press
  
  
  observeEvent(input$run_btn,{
      demo_file <- "./t_rufolavatus/Tachybaptus rufolavatus.xlsx"
      demo_data<-read_extinct_excel(x=demo_file)
      # return list as reactive "user_data()" output
      user_data(demo_data)
  })
 
  
  #=======================
  # Load user-specified input data
  
  observeEvent(input$data_input, {
    upload<-read_extinct_excel(x=input$data_input$datapath)
    # return list as reactive "user_data()" output
    user_data(upload)
  })
  
  #=======================
  # check integrity of user-specified input data
  
  observeEvent(input$data_input, {
    run_check<-check_files(file=input$data_input$datapath, user_data = user_data())
    # if errors are found, show pop-up notifications
    if(length(run_check)>1){
      shinyalert(title="There were some issues loading your file",
                 text=paste0(
                   paste0(run_check, collapse="</br></br>"),
                   "</br></br>This may cause the app to crash or unexpected behaviour",
                   collapse="</br></br>"),
                 html=T,
                 type="error")
    }
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
  # Defined reactive extinct code

  
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
  # Make input table (editable)
  
  output$records_tbl <- renderDT({
    datatable(user_data()$records,
              editable = TRUE,
              filter = "none",
              rownames= FALSE,
              options = list(dom = 't',
                             scrollX = TRUE,
                             ordering=F))
  })
  
  output$surveys_tbl <- renderDT({
    datatable(user_data()$surveys,
              editable = TRUE,
              filter = "none",
              rownames= FALSE,
              options = list(dom = 't',
                             scrollX = TRUE,
                             ordering=F))
  })
  
  #=======================
  # Observe user input for records and survey tables
  
  # Observe changes to the DataTable and update the reactive data frame
  observeEvent(input$records_tbl_cell_edit, {
    info <- input$records_tbl_cell_edit
    str(info)  # Print edited info (for debugging)
    
    # Update the reactive data frame with the new value
    new_data <- user_data()
    new_data$records[info$row, info$col+1] <- as.numeric(info$value)
    user_data(new_data)
  })
  
  # Observe changes to the DataTable and update the reactive data frame
  observeEvent(input$surveys_tbl_cell_edit, {
    info <- input$surveys_tbl_cell_edit
    str(info)  # Print edited info (for debugging)
    
    # Update the reactive data frame with the new value
    new_data <- user_data()
    new_data$surveys[info$row, info$col+1] <- as.numeric(info$value)
    user_data(new_data)
  })
  
  
  #=======================
  # Plot extinction plot
  
  gg_ext<-reactive({
    
    # ensure pxt exits
    req(pxt())
    
    # make plot
    
    gg<-pxt() %>% 
      mutate(Observation=case_when(
        year %in% (user_data()$surveys %>% pull(year)) ~ "No Sighting",
        year %in% (user_data()$records %>% pull(year)) ~ "Confirmed Sighting"
      )) %>%
      ggplot(aes(x=year, y=PXt)) +
      geom_hline(aes(yintercept=0.5), linetype="dashed") +
      geom_hline(aes(yintercept=0.0), color="red") +
      geom_ribbon(aes(ymin=PXt.min, ymax=PXt.max), fill="grey70") +
      geom_ribbon(aes(ymin=MC_lower, ymax=MC_upper), fill="grey50") +
      geom_line() +
      geom_point(aes(color=Observation)) +  
      scale_color_manual(values = c("Confirmed Sighting"="deepskyblue3","No Sighting"="black"), na.value = NA)  +
      scale_x_continuous(n.breaks=10) +
      theme_classic() +
      theme(legend.position="none") +
      ggtitle(user_data()$species)
    
    
  })
  
      output$ext_ply<-renderPlotly({
        ggplotly(gg_ext(),
                 height=600)
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
            aspect.ratio=1)+
      ggtitle(user_data()$species)
    
    
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
  # Export table and plots
      
      # Downloadable csv of pxt dataset ----
      output$pxt_tbl_download <- downloadHandler(
        filename = function() {
          paste("pxt_",user_data()$species, ".csv", sep = "")
        },
        content = function(file) {
          write.csv(pxt(), file, row.names = FALSE)
        }
      )
    
      # Downloadable pdf of extinction plot ----
      output$pxt_plot_download <- downloadHandler(
        filename = function() {
          paste("pxt_",user_data()$species, ".pdf", sep = "")
        },
        content = function(file) {
          pdf(file, width=7, height=5)  # Open a PDF device to write the plot
          print(
            gg_ext()
          )
          dev.off()
        }
      )  
      
      # Downloadable pdf of threats plot ----
      output$threats_plot_download <- downloadHandler(
        filename = function() {
          paste("threats_",user_data()$species, ".pdf", sep = "")
        },
        content = function(file) {
          pdf(file, width=5, height=5)  # Open a PDF device to write the plot
          print(
            gg_pe()
          )
          dev.off()
        }
      )
      
  
}

