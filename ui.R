ui <- fluidPage(style='padding:100px;',
                # app title
                title = "Extinct",
                ## 
                
                titlePanel(title=div(img(src="extinct_logo.png", height="50%", width="50%"), align="center")),
                
                ## Intro
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(h3("Welcome to Extinct!")),
                         div(p("This is a shiny app to model extinction probability based on successful and unsucessful sightings of
                               a species from field surveys, based on the models of ",
                               tags$a(
                                 "Thompson et al. 2017",
                                 target = "_blank",
                                 href = "https://doi.org/10.1016/j.biocon.2017.07.029"),
                             "combined with extinction probabilities based on threats, following ",
                             tags$a(
                                 "Kieth et al. 2017",
                                 target = "_blank",
                                 href = "https://doi.org/10.1016/j.biocon.2017.07.026"))
                         ),
                         div(p("The required input for this app to run, is an excel file of extinction probability that needs to be prepared for the IUCN Red List Essessment tool. More information on how
                               this file should be structured can be found ",
                               tags$a(
                                 "here.",
                                 target = "_blank",
                                 href = "https://www.iucnredlist.org/resources/ex-probability"))),
                         ## Load demo data button
                         actionBttn("help_btn", "Get help with input format", syle = "pill", color="warning"),
                         ),
                
                ## Input
                
                
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(h3("Data Input"),
                             p("To get started, just load your extinction probability data template file.
                             Hit 'Run Demo!' to get started with the Alaotra grebe  data from Thompson et al. 2013.")),

                         
                          ## File inputs
                        
                         column(width=12,
                                fileInput("data_input", "Choose input",multiple = F)
                         ),
                         

                         ## Demo button
                         
                         column(width=12,
                                actionBttn("run_btn", "Run Demo!",style="jelly", color = "success")
                                )
                          
                ),
                
                ## Extinction over time Output
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(h3("Inferring Extinction based on Records and Surveys")),
                         column(width=4,
                                div(h4("Adjust Passive Survey Years"),
                                    p("In years with no confirmed sightings or dedicated surveys there may still have been some probability 
                                      that the taxon was spotted by an undocumented observer. How these 'passive survey years' influence the model 
                                      can be explored by adjusting the upper and lower limits for the three probability parameters (proportion 
                                      of total area surveyed, probability of reliable identification, probability of recordings - see help above 
                                      for more details).")
                                    ),
                                sliderInput(inputId="eps",
                                            label="ε:",
                                            min = 0, max = 1, step=0.01,
                                            value = c(0.01, 0.05),
                                            dragRange = T),
                                p("The proportion of the taxon's habitat within its likely entire range that was surveyed"),
                                sliderInput(inputId="pi",
                                            label="p(i):",
                                            min = 0, max = 1, step=0.01,
                                            value = c(0.7, 0.95),
                                            dragRange = T),
                         p("The probability that the taxon, or recent evidence of it, could have been reliably identified in 
                           the survey if it had been recorded."),
                                sliderInput(inputId="pr",
                                            label="p(r):",
                                            min = 0, max = 1, step=0.01,
                                            value = c(0.7, 0.95),
                                            dragRange = T),
                p("The probability that the taxon, or recent evidence of it, would have been recorded in the survey."),
                
                ### RESET BUTTON
                
                actionBttn("reset_ext_btn", "Reset Sliders",style="pill", color = "warning")
                
                ),
                
                
                ### PLOTTING AREA
                
                         column(width=8,
                                div(h4("Extant Probability Through Time")),
                                plotlyOutput("ext_ply"),
                                div(p( 
                                  "This plot shows the probability that the focal species is extant at any given year. 
                                  The boundaries of the light shaded region are upper and lower bounds on P(Xt) derived from interval arithmetic. 
                                  The boundaries of the dark shaded region are 5% and 95% intervals derived from a Monte Carlo projection of the associated density functions, assuming normality and independence."))),
                
                
                
              
),



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
                            value = c(0.01, 0.05),
                            dragRange = T),
                p("The probability of all combined threats having caused local extinction"),
                sliderInput(inputId="p_spatial",
                            label="P(spatial):",
                            min = 0, max = 1, step=0.01,
                            value = c(0.7, 0.95),
                            dragRange = T),
                p("The probability of all combined threats having caused extinction across the entire species' range"),
                ### RESET BUTTON
                
                actionBttn("reset_threats_btn", "Reset Sliders",style="pill", color = "warning")
                
         ),
         
         
         ### PLOTTING AREA
         
         column(width=8,
                div(h4("Extinction Probabilities Based on Threats and Survey Data")),
                plotOutput("pe_gg"),
                #plotlyOutput("pe_ply"),
                div(p( 
                  "This plot shows the extinction probabilities as estimated from the 'Surveys and Records' model of Thompson et al. and the 'Threats' model of Keith et al. Indicated are bounds for the IUCN Red List classifications for 'Critically Endangered' and 'Extinct' as defined by ",
                  tags$a(
                    "Butchart et al. 2018",
                    target = "_blank",
                    href = "https://doi.org/10.1016/j.biocon.2018.08.014"))
                ))
),

  
                ## TEST ZONE
              #  fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
              #           div(h3("TEST ZONE")),
              #           textOutput("test")
              #           
              #  ),
                
                
                
                
                
                
                ## download
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(h3("Export Results"),
                             p("Work in progress. Downloading output data will be enabled soon ")),
                      # column(width=4,
                      #        div(h4("Check error log")),
                      #        textOutput("error")
                      # ),
                      # column(width=4,
                      #        downloadButton("tbl_download", "Download table", class="btn-info")
                      # ),
                      # column(width=4,
                      #        downloadButton("plot_download", "Download plot", class="btn-info")
                      # ),
                      # 
                ),
                
              ## footer
                fluidRow(
                  div(
                    p(style="text-align:center",
                      "Copyright (c) 2024 H. Christoph Liedtke. All rights reserved.This work is licensed under the terms of the ",tags$a(
                        "MIT license",
                        target = "_blank",
                        href = "https://opensource.org/licenses/MIT")),
                    p(style="text-align:center",
                      "For more information and to post bugs, use the ",
                      tags$a(
                        "GitHub Reposiotry",
                        target = "_blank",
                        href = "https://github.com/hcliedtke/extinct"))
                  )
                )
                      
                         
)

