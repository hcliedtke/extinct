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
                               a species from field surveys, and threat probabilities, based on the models developed by ",
                               tags$a(
                                 "Kieth et al. 2017,",
                                 target = "_blank",
                                 href = "https://doi.org/10.1016/j.biocon.2017.07.026"),
                               tags$a(
                                 "Thompson et al. 2017",
                                 target = "_blank",
                                 href = "https://doi.org/10.1016/j.biocon.2017.07.029"),
                               " and ",
                               tags$a(
                                 "Akçakaya et al. 2017.",
                                 target = "_blank",
                                 href = "http://dx.doi.org/10.1016/j.biocon.2017.07.027"),
                             "These probabilities are then combined to inform whether a species should be considered ", em("Critically Endangered (Possibly Extinct)")," or ", em("Extinct"), " based on thresholds proposed in ",
                             tags$a(
                               "Butchart et al. 2018",
                               target = "_blank",
                               href = "https://doi.org/10.1016/j.biocon.2018.08.014"),
                             ", and adopted by the ",
                             tags$a(
                               "IUCN Red List Guidelines",
                               target = "_blank",
                               href = "https://www.iucnredlist.org/documents/RedListGuidelines.pdf"),
                               " prepared by the IUCN Standards and Petitions Committee."))),
                
                ########################---------------------------
                ## Input panel
                
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(h3("Data Input"),
                             p("The required input for this app is the species extinction assessment tool excel template provided by the IUCN Red List. This template, along with more information on how it should be structured can be found ",
                                   tags$a(
                                     "here",
                                     target = "_blank",
                                     href = "https://www.iucnredlist.org/resources/ex-probability"),
                                   " with additional information regarding the app found ",
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
                                 href = "https://doi.org/10.1016/j.biocon.2017.07.029"),
                          " and ",
                          tags$a(
                            "Kieth et al. 2017.",
                            target = "_blank",
                            href = "https://doi.org/10.1016/j.biocon.2017.07.026")),
                        
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
                           div(h3("Inferring Extinction Based on Records and Surveys")),
                           column(width=4,
                                  div(h4("Passive Survey Years"),
                                      p("In years with no confirmed sightings or dedicated surveys there may still have been some probability 
                                      that the taxon was spotted by an undocumented observer. How these 'passive survey years' influence the model 
                                      can be explored by adjusting the upper and lower limits, as well as the best estimates for the three probability
                                      parameters (proportion of total area surveyed, probability of reliable identification, probability of recordings -
                                        see detailed decriptions for each parameter in the 'definitions' tab of the template data file).")
                                  ),
                                  bscols(widths=c(8,4),
                                         sliderInput(inputId="eps",
                                                     label="ε min/max:",
                                                     min = 0, max = 1, step=0.01,
                                                     value = c(0, 1),
                                                     dragRange = T),
                                         sliderInput(inputId="eps_best",
                                                     label="ε best:",
                                                     min = 0, max = 1, step=0.01,
                                                     value = c(0))),
                                  p("The proportion of the taxon's habitat within its likely entire range that was surveyed."),
                                  bscols(widths=c(8,4),
                                         sliderInput(inputId="pi",
                                                     label="p'(i) min/max:",
                                                     min = 0, max = 1, step=0.01,
                                                     value = c(0, 1),
                                                     dragRange = T),
                                         sliderInput(inputId="pi_best",
                                                     label="p'(i) best:",
                                                     min = 0, max = 1, step=0.01,
                                                     value = c(0))),
                                  p("The probability that the taxon, or recent evidence of it, could have been reliably identified in 
                           the survey if it had been recorded."),
                                  bscols(widths=c(8,4),
                                         sliderInput(inputId="pr",
                                                     label="p'(r) min/max:",
                                                     min = 0, max = 1, step=0.01,
                                                     value = c(0, 1),
                                                     dragRange = T),
                                         sliderInput(inputId="pr_best",
                                                     label="p'(r) best:",
                                                     min = 0, max = 1, step=0.01,
                                                     value = c(0))),
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
                                    "This plot shows the probability that the focal taxon is extant at any given year.
                                    Blue dots indicate record years and black dots indicate survey years with no records.
                                  The boundaries of the light shaded region are upper and lower bounds on the extant probability 
                                  'P(Xt)' derived from the interval arithmetic. The boundaries of the dark shaded region are 5% 
                                    and 95% intervals derived from a Monte Carlo projection of the associated density functions, 
                                    assuming normality and independence."))
                                  )
                           ),
                         
                
                fluidRow(
                  div(h4("Records and Dedicated Surveys Parameters"),
                      p("Below are the input parameters for records (confirmed sighting) and surveys (unsucessful sightings) that were used to generate the plot above. Values in the tables can be edited to facilitate exploring how these parameter values influence the extinction probabilities.")),
                  # Render the records table
                  column(width=4,
                         div(h4("Records")),
                         DTOutput("records_tbl")),
                  column(width=8,
                         # Render the records table
                         div(h4("Surveys")),
                         DTOutput("surveys_tbl"))
                  )         
                
              
),

      ########################---------------------------
      ## Threats panel

      ## Inferring Extinction Based on Records, Surveys and Threats
      fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
               div(h3("Inferring Extinction Based on Records, Surveys and Threats")),
               column(width=4,
                      div(h4("Threats Probabilities"),
                          p("Assessing threats needs to be done at both a local and species range-wide level. The probability of extinction at these two scales based on the severety of threats is subjective. ",
                            tags$a(
                              "Kieth et al. 2017",
                              target = "_blank",
                              href = "https://doi.org/10.1016/j.biocon.2017.07.026"),
                          " provide an argument map for deriving best estimates, as well as upper and lower confidence/certainty bounds. The slides below, and the plot on the right, allow for the visualization of how these parameters impact the overall extinction probabilities, based on threats (y-axis). The plot combines the product of the local and spatial probabilities of extinction with the extinction estimates derived from the 'Records and Surveys' model in the panel above.")
                      ),
                      bscols(widths = c(8,4),
                        sliderInput(inputId="p_local",
                                    label="P(local) min/max:",
                                    min = 0, max = 1, step=0.01,
                                    value = c(0, 1),
                                    dragRange = T),
                        sliderInput(inputId="p_local_best",
                                    label="P(local) best",
                                    min = 0, max = 1, step=0.01,
                                    value = c(0))),
                      p("The probability of all combined threats having caused local extinction."),
                      bscols(widths = c(8,4),
                             sliderInput(inputId="p_spatial",
                                  label="P(spatial) min/max:",
                                  min = 0, max = 1, step=0.01,
                                  value = c(0, 1),
                                  dragRange = T),
                             sliderInput(inputId="p_spatial_best",
                                         label="P(spatial) best:",
                                         min = 0, max = 1, step=0.01,
                                         value = c(0))),
                      p("The probability of all combined threats having caused extinction across the entire species' range."),
                      ### RESET BUTTON
                      
                      actionBttn("reset_threats_btn", "Reset Sliders",style="bordered", color = "success")
                      
               ),
               
               
               ### PLOTTING AREA
               
               column(width=8,
                      div(h4("Extinction Probabilities Based on Threats and Records and Survey Data")),
                      #plotOutput("pe_gg"),
                      plotlyOutput("pe_ply", height="100%"),
                      div(p( 
                        "This plot shows the extinction probabilities as estimated from the 'Surveys and Records' model of Thompson et al. 2017 and the 'Threats' model of Keith et al. 2017. Indicated are threshold windows for the IUCN Red List classifications for ",em('Critically Endangered (Possibly Extinct)'), " (P=0.5) and ", em('Extinct'), " (P=0.9) as defined by the ",
                        tags$a(
                          "IUCN Red List guidelines.",
                          target = "_blank",
                          href = "https://cmsdocs.s3.amazonaws.com/RedListGuidelines.pdf"))
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
                             downloadButton("threats_plot_download", "Download Prob(Extinct) plot", class="btn-info")))
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

