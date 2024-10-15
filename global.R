# Load required packages -------------------------------
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(readxl)
library(tidyverse)
library(plotly)
library(reactable)
library(DT)
library(shinyalert)
library(lubridate)
library(crosstalk)

# ============================================
# Set themes  

# global themes
theme_set(theme_classic()+
            theme(
              # grid and axes
              axis.line=element_blank(),
              panel.grid.major.y = element_line(color = "grey95",size = 0.5),
              # facet strips
              strip.background = element_rect(color=NA, fill=NA),
              strip.text = element_text(hjust = 0, size=12))
)

# run colors
run_colors <- c(
  "1"   = "#727cf5",
  "2"    = "#0acf97",
  "3" = "#fa5c7c",
  "4"  = "#ffbc00",
  "5"   = "#2e4057",
  "6"   = "#8d96a3"
)

# ============================================
# load thompson et al. function for estimating extinction probabilities
source("functions/px_mid.R")

# ============================================
# load function that reads IUCN extinction template
source("functions/read_extinct_excel.R")

# ============================================
# load run_extinct function to execute code on button-click
source("functions/run_extinct.R")

# ============================================
# load file check function
source("functions/check_files.R")

