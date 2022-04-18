###############################
# FIND Covid-19 Data Portal App
###############################

# Required R Packages
suppressPackageStartupMessages({
library(shiny)      ###Shiny: The Web application framework we are working with
library(shinyBS)    ###Shiny Bootstrap: Bootstrap web themes and features for shiny
library(DT)         ###A wrapper for JavaScript library 'DataTables'
library(dplyr)      ###Data Frame manipulation package
library(tidyverse)  ###Keeping things Tidy
library(lubridate)  ###Date manipulation
library(ggplot2)    ###to make basic plots
library(rsconnect)  ###to connect R studio to Shiny
library(qtlcharts)  ###Interactive Charts
})

# Clear all
rm(list=ls())

# Some global options affecting appearance
options(digits = 3L, 
        width = 100L,
        htmlwidgets.TOJSON_ARGS = list(na = 'string', digits = 6L), 
        shiny.sanitize.errors = FALSE) # This makes sure shiny displays any error messages

# Load Data
load("load_all.RData")

####### This creates the website, integrating the code in ui_code.R, which creates the 'Data Access' tab.

### Set title and provide logo for application
title <- "FIND COVID-19 Data Portal"
logo <- "logo.PNG" ### placed in main project directory, and be png format.

###
ui <- bootstrapPage('',
            
            # This includes a CSS stylesheet 'style.css' setting the appearance of the app. This sheet can be edited separately.           
            includeCSS("style.css"),           
            
            # This compounds the title with the logo on the left    
            navbarPage(div(img(src = logo, height = 40, style = "position: absolute; top: 0; bottom:0; left: 0; right:0; 
                 margin-top: auto; margin-bottom: auto; margin-left: 5px; margin-right: 50px;"), 
                           title, style = "margin-left: 90px;"), 
                       
                       # This is for the browser tab
                       windowTitle = tags$head(tags$link(rel = "icon", type = "image/PNG", href = logo),
                                               tags$title(title)),
                       
                       # Select default tab when calling site
                       selected = "About",
                       
                       # Read code from ui_code.R
                       tabPanel("Dashboard",
                                source(file.path("ui_code.R"),  local = TRUE)$value
                       ),
                       
                     
                       
                       # About tab (can include more sections and useful links), see ?shiny::tags
                       tabPanel("About",
                                div(class = "AboutContent",
                                    h3("FIND COVID-19 Tracker"),
                                    p("Welcome to the FIND COVID-19 Tracker"),
                                    p("This is my first ever attempt at creating an interactive dashboard in R Shiny. Let me know what you think."),
                                    p("All the data shown in this dashboard is taken from the FINDCov19TrackerData (linked below)."),
                                    p("Please be mindful that that the Number of Days Reported measurment shows data for incomplete months/quarters,
                                      whereas the AVerage per 1,000 people measurements are cut off at the last complete month/quarter."),
                                    p("Special thanks to Seb Krantz, for his guide on how to build a Shiny App (https://github.com/SebKrantz/shiny-data-portal)."),
                                    p("Tom Meijer"),
                                    p(" "),
                                    a("TAFMeijer GitHub", href = "https://github.com/TAFMeijer/FIND_COVID19", target = "_blank"),
                                    p(" "),
                                    a("FINDCov19Tracker", href = "https://github.com/finddx/FINDCov19TrackerData", target = "_blank")
                                )
                      )
            )
)

# This reads the server side code in server.R and creates the server function.
server <- function(input, output, session) {

  source(file.path("server_code.R"), local = TRUE)$value

}

# This puts everything together and runs the application.
shinyApp(ui = ui, server = server)