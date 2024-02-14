ui <- fluidPage(style='padding:100px;',
                # app title
                title = "Extinct",
                ## 
                
                titlePanel(title=div(img(src="extinct_logo.png", height="50%", width="50%"), align="center")),
                
                ## Intro
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(h3("Welcome to Extinct!")),
                         div(p("This is a shiny app to model extinction probability based on successful and unsucessful sightings of
                               a species from field work. It is based on the models of",
                               tags$a(
                                 "Thompson et al. 2017.",
                                 target = "_blank",
                                 href = "https://doi.org/10.1016/j.biocon.2017.07.029"))
                         ),
                         div(p("The required input for this app to run, is a table of years with confirmed sightings of the target species,
                               and a table of years in which surveys have been conducted, but the target species was not detected. Each table
                               also requires lower and upper probability limites for the likelihoods that a species could be directly identified,
                               surveys were conducted in an exhaustive manner, and how easily detectable the species is. More information on how
                               these tables should be structured can be found in the original publication and in the example dataset",
                               tags$a(
                                 "here.",
                                 target = "_blank",
                                 href = "https://github.com/hcliedtke/extinct/c_maridadi")))
                         ),
                
                ## Input
                
                
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(h3("Survey and Records Input"),
                             p("To get started, load your records and survey files, then hit Run!
                               Hitting Run! without uploading files, will use demo data on Churamiti maridadi 
                               from Liedtke et al. 2023")),

                          ## Load demo data button
                         actionBttn("help_btn", "Get help with input format", syle = "pill", color="warning"),
                          ## File inputs
                         
                         column(width=12,
                                fileInput("records_input", "Choose records input",multiple = F),
                                fileInput("surveys_input", "Choose unsuccessful survey input",multiple = F),
                                ),

                         ## Run button
                         
                         column(width=12,
                                actionBttn("run_btn", "Run!",style="jelly", color = "success")
                                )
                          
                ),
                
                ## Output
                fluidRow(style='padding:30px;margin:10px;background-color:#f7f6f2;border-radius:10px',
                         div(h3("Extinction Probability Over Time")),
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
                                            value = c(0.01, 0.05)),
                                p("The proportion of the taxon's habitat within its likely entire range that was surveyed"),
                                sliderInput(inputId="pi",
                                            label="p(i):",
                                            min = 0, max = 1, step=0.01,
                                            value = c(0.7, 0.95)),
                         p("The probability that the taxon, or recent evidence of it, could have been reliably identified in 
                           the survey if it had been recorded."),
                                sliderInput(inputId="pr",
                                            label="p(r):",
                                            min = 0, max = 1, step=0.01,
                                            value = c(0.7, 0.95)),
                p("The probability that the taxon, or recent evidence of it, would have been recorded in the survey."),
                
                ### UPDATE BUTTON
                
                #actionBttn("reset_btn", "Reset Sliders",style="jelly", color = "warning"),
                actionBttn("update_btn", "Update Plot",style="jelly", color = "success")
                
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

