server <- function(input,output,session){
  #======================
  # global server settings
  options(shiny.maxRequestSize=30*1024^2) 
  
  
  #=======================
  # help button
  observeEvent(input$help_btn, {
    # Show a simple modal
    shinyalert(title="Loading Data", type="info",
    text = "To get started, you must upload two data tables (as comma separated values [.csv] files) that provide information on the years with sightings of the targe species (records) and years in which surveys were conducted, but no animals were sighted (i.e. unsuccessful surveys). These two files must also contain upper and lower probability limits. The format of the tables is as follows:
    
    1. Survey data - a table with seven columns with the following headers: year, eps_lower, eps_upper, pi_lower, pi_upper, pr_lower, pr_upper
    2. Record data - a table with tree columns with the following headers: year, pci_lower, pci_upper
    
    The lower and upper bounds refer to:
    
    eps: the proportion of the taxon's habitat within its likely entire range that was surveyed (0 to 1)
    pi: the probability that the taxon, or recent evidence of it, could have been reliably identified in the survey if it had been recorded (0 to 1)
    pr: the probability that the taxon, or recent evidence of it, would have been recorded in the survey (0 to 1)
    pci: the probability that the taxon is correctly identified as extant (0 to 1)
    
    IMPORTANT!! The first year MUST be a record year. i.e. there cannot be unsuccessful surveys prior to the first record.
    
    Check out the demo files or the original Thompson et al. 2013 publication for help, or for any problems, raise an issue in the github repository (link at bottom of page)"
    
    )
  })

  
  #=======================
  # Create user-specified survey input files
  
  surveys<-function(){
    file <- input$surveys_input
    ext <- tools::file_ext(file$datapath)
    
    req(file)
    validate(need(ext == "csv", "Please upload a csv file"))
    
    read_csv(file$datapath)
  }
  
  #=======================
  # Create user-specified records input files
  
  records<-function(){
    file <- input$records_input
    ext <- tools::file_ext(file$datapath)
    
    req(file)
    validate(need(ext == "csv", "Please upload a csv file"))
    
    read_csv(file$datapath)
  }
  
  #=======================
  # Run extinct code

  
  vals <- reactiveValues()
  
  observeEvent(ignoreInit = TRUE, list(input$run_btn,input$update_btn),{
  
    # modal
   # showModal(modalDialog("Calculating extinction...",
  #                        easyClose=TRUE))
    
    # if no input is provided, use demo data
    vals$surveys<-
      if(is.null(input$surveys_input)){
        read_csv("./c_maridadi/surveys.csv")
        } else {
          surveys()
          }
      
    vals$records<-
      if(is.null(input$records_input)){
        read_csv("./c_maridadi/records.csv")
        } else {
          records()
          }
    
    # get passive survey input from sliders
    vals$eps<-input$eps
    vals$pi<-input$pi
    vals$pr<-input$pr
    
    
    # run extinction calculations
    
    vals$pxt<-run_extinct(surveys=vals$surveys, records=vals$records,
                          eps=vals$eps,pi=vals$pi,pr=vals$pr)
    
    # make plot
    
    vals$gg<-vals$pxt %>%
      ggplot(aes(x=year)) +
      geom_hline(aes(yintercept=0.5), linetype="dashed") +
      geom_hline(aes(yintercept=0.0), color="red") +
      geom_ribbon(aes(ymin=PXt.min, ymax=PXt.max), fill="grey70") +
      geom_ribbon(aes(ymin=MC_lower, ymax=MC_upper), fill="grey50") +
      scale_x_continuous(n.breaks=10) +
      geom_line(aes(y=PXt)) +
      theme_classic()
    
  })
  
  
  #=======================
  # Plot extinction plot
  

  observeEvent(!is.null(vals$gg), {
      output$ext_ply<-renderPlotly({
        plotly::ggplotly(vals$gg)
      })
    })
    
    
    
  
  
  #=======================
  # Plot table
  output$tbl<-renderTable(vals$pxt)
    
  
}

