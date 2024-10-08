ui <- fluidPage(style='padding:100px;',
                # app title
                title = "Extinct",
                ## 
                titlePanel(title=div(img(src="extinct_logo.png", height="50%", width="50%"), align="center")),
                
                ########################---------------------------
                ## Intro panel

                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(h3("Welcome to Extinct!")),
                         div(p("This is a web application to model extinction probability based on successful and unsucessful sightings of
                               a species from field surveys, based on the models of ",
                               tags$a(
                                 "Thompson et al. 2017",
                                 target = "_blank",
                                 href = "https://doi.org/10.1016/j.biocon.2017.07.029"),
                             "combined with extinction probabilities based on threats, following ",
                             tags$a(
                                 "Kieth et al. 2017",
                                 target = "_blank",
                                 href = "https://doi.org/10.1016/j.biocon.2017.07.026")))
                         ),
                
                ########################---------------------------
                ## Input panel
                
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(h3("Data Input"),
                             p("The required input for this app, is the template provided by the IUCN Red List, for the Extinction assessment tool. More information on how this file should be structured can be found ",
                                   tags$a(
                                     "here.",
                                     target = "_blank",
                                     href = "https://www.iucnredlist.org/resources/ex-probability"),
                                   " and the read me file ",
                                   tags$a(
                                     "here.",
                                     target = "_blank",
                                     href = "https://github.com/hcliedtke/extinct")),
                             p("Once you have prepared this excel file, upload the file here and the app will calculate the output."),

                        ## File input button
                         fileInput("data_input", "Choose input",multiple = F),
                        
                        ## Demo button
                        p("Alternatively, hit 'Run Demo Data' below to get started with the ", em("Alaotra grebe"),  " data from ",
                               tags$a(
                                 "Thompson et al. 2017",
                                 target = "_blank",
                                 href = "https://doi.org/10.1016/j.biocon.2017.07.029")),
                        
                          actionBttn("run_btn", "Run Demo Data",
                                           style="bordered", color = "success")
                         )),
                
                ########################---------------------------
                ## Start of conditional output panels
                
                conditionalPanel(
                  condition = "output.fileUploaded == true",
                  
                  ########################---------------------------
                  ## Extinction probability panel
                  
                ### Sliders and plots
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         fluidRow(
                           div(h3("Inferring Extinction based on Records and Surveys")),
                           column(width=4,
                                  div(h4("Passive Survey Years"),
                                      p("In years with no confirmed sightings or dedicated surveys there may still have been some probability 
                                      that the taxon was spotted by an undocumented observer. How these 'passive survey years' influence the model 
                                      can be explored by adjusting the upper and lower limits for the three probability parameters (proportion 
                                      of total area surveyed, probability of reliable identification, probability of recordings - see help above 
                                      for more details).")
                                  ),
                                  sliderInput(inputId="eps",
                                              label="ε:",
                                              min = 0, max = 1, step=0.01,
                                              value = c(0, 1),
                                              dragRange = T),
                                  p("The proportion of the taxon's habitat within its likely entire range that was surveyed."),
                                  sliderInput(inputId="pi",
                                              label="p'(i):",
                                              min = 0, max = 1, step=0.01,
                                              value = c(0, 1),
                                              dragRange = T),
                                  p("The probability that the taxon, or recent evidence of it, could have been reliably identified in 
                           the survey if it had been recorded."),
                                  sliderInput(inputId="pr",
                                              label="p'(r):",
                                              min = 0, max = 1, step=0.01,
                                              value = c(0, 1),
                                              dragRange = T),
                                  p("The probability that the taxon, or recent evidence of it, would have been recorded in the survey."),
                                  
                                  ### RESET BUTTON
                                  
                                  actionBttn("reset_ext_btn", "Reset Sliders",style="bordered", color = "success")
                                  
                           ),
                           
                             
                           ### PLOTTING AREA
                           column(width=8,
                                  # Render plot
                                  div(h4("Extant Probability Through Time")),
                                  plotlyOutput("ext_ply", height = "auto"),
                                  div(p( 
                                    "This plot shows the probability that the focal species is extant at any given year. 
                                  The boundaries of the light shaded region are upper and lower bounds on P(Xt) derived from interval arithmetic. 
                                  The boundaries of the dark shaded region are 5% and 95% intervals derived from a Monte Carlo projection of the associated density functions, assuming normality and independence.")),
                         )),
                         
                
                fluidRow(
                  div(h4("Records and Dedicated Surveys Parameters"),
                      p("Below are the input parameters for records (confirmed sighting) and surveys (unsucessful sightings) that were used to generate the plot above. The tables are editable and to allow manipulating how these parameter values influence the final plot.")),
                  # Render the records table
                  column(width=4,
                         div(h4("Records")),
                         DTOutput("records_tbl")),
                  column(width=8,
                         # Render the records table
                         div(h4("Surveys")),
                         DTOutput("surveys_tbl"))
                  ),         
                
              
),

      ########################---------------------------
      ## Threats panel

      ## Inferring Extinction based on Threats
      fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
               div(h3("Inferring Extinction based on Threats")),
               column(width=4,
                      div(h4("Threats Probabilities"),
                          p("Assessing threats needs to be done at both a local and species range-wide level. The probability of extinction at these two scales based on the severety of threats is subjective and Keith et al. 2017 provide a argument map for deriving upper and lower bounds for certainities of these estimate. This tool allows for the visualization of how these bounds impact the overall extinction probabilities.")
                      ),
                      sliderInput(inputId="p_local",
                                  label="P(local)",
                                  min = 0, max = 1, step=0.01,
                                  value = c(0, 1),
                                  dragRange = T),
                      p("The probability of all combined threats having caused local extinction"),
                      sliderInput(inputId="p_spatial",
                                  label="P(spatial):",
                                  min = 0, max = 1, step=0.01,
                                  value = c(0, 1),
                                  dragRange = T),
                      p("The probability of all combined threats having caused extinction across the entire species' range"),
                      ### RESET BUTTON
                      
                      actionBttn("reset_threats_btn", "Reset Sliders",style="bordered", color = "success")
                      
               ),
               
               
               ### PLOTTING AREA
               
               column(width=8,
                      div(h4("Extinction Probabilities Based on Threats and Survey Data")),
                      plotOutput("pe_gg"),
                      #plotlyOutput("pe_ply"),
                      div(p( 
                        "This plot shows the extinction probabilities as estimated from the 'Surveys and Records' model of Thompson et al. and the 'Threats' model of Keith et al. Indicated are bounds for the IUCN Red List classifications for 'Critically Endangered' and 'Extinct' as defined by ",
                        tags$a(
                          "Akçakaya et al. 2017",
                          target = "_blank",
                          href = "https://doi.org/10.1016/j.biocon.2017.07.027"))
                      ))
),

  

                
              ########################---------------------------
              ## Downloads panel

                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px;text-align:center',
                         div(h3("Export Results"),
                             p("Downloading the resulting extant probability data and plots."),
                       column(width=4,
                              downloadButton("pxt_tbl_download", "Download extinction table", class="btn-info")),
                      column(width=4,
                              downloadButton("pxt_plot_download", "Download extinction plot", class="btn-info")),
                      column(width=4,
                             downloadButton("threats_plot_download", "Download threats plot", class="btn-info")))
                )


),# end of conditional panels

########################---------------------------
## Footer panel         
              ## footer
                fluidRow(
                  div(style="text-align:center",
                    p("Copyright (c) 2024 H. Christoph Liedtke. All rights reserved.This work is licensed under the terms of the ",tags$a(
                        "MIT license",
                        target = "_blank",
                        href = "https://opensource.org/licenses/MIT")),
                    p("For more information and to post bugs, use the ",
                      tags$a(
                        "GitHub Reposiotry",
                        target = "_blank",
                        href = "https://github.com/hcliedtke/extinct"))
                  )
                )
                      
                         
)

