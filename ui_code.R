####################################################
# Data Portal User Interface (the 'Data Access' tab)
####################################################

# Note: All of this code generates HTML from R

div(class="outer",
    
    # This includes a CSS stylesheet 'style.css' setting the appearance of the app. This sheet can be edited separately.
    includeCSS("style.css"), 
    
    # This is the sidebar panel (left-panel) of the application. 
    sidebarLayout(               # These appearance controls were outsourced to style sheet:
      absolutePanel(id = "side", # width = "20%", height = "auto", top = NULL, left = NULL, bottom = NULL, right = "auto", #94.5%

                    
                    # These are the main controls for selecting, filtering and aggregating data.  
                    conditionalPanel(condition = "input.tabs=='Table' || input.tabs=='BoxPlot'",
                                     # Enter Data Sources:
                                     selectInput("measurement", "Select Measurement",
                                                 choices = c("Number of Days Reported", 
                                                             "Average per 1,000 people")),
                                     # This is for selecting a dataset from a source. It will be updated once the source was selected.
                                     selectInput("timeframe", "Select Timeframe",
                                                 choices = c("Monthly", 
                                                             "Quarterly")),
                                     # Special cases: For some datasets we could present different versions or sub-datasets, available through additional controls visible only if the dataset is selected. 
                                     selectizeInput("country", label = "Select Country (up to a maximum of 6)"
                                       #####Dynamically populated multiselect
                                       ,choices = unique(ReportedMonthly$Country)
                                       ,multiple = TRUE
                                       ,options = list(maxItems = 6)
                                       ,selected = "Afghanistan")###Make into first item on the list
                                     )
                    ,conditionalPanel(condition = "input.tabs=='BoxPlot'",
                                    ### Enter Which metric you want to plot:
                                    selectInput("metric", "Select Metric for BoxPlot",
                                                choices = c("Testing", 
                                                            "Cases",
                                                            "Deaths")
                                                ,selected = "Testing"))
                    ),tags$hr() # horizontal rule
                    ),
                    
      # This generates the main (right) panel with the data table and statistical output                                               
      absolutePanel(id= "main" , # width = "80%", height = "100%", top = NULL, left = "20%", bottom = NULL, right = NULL,
                    tabsetPanel(type = "tabs",
                                tabPanel('Table',
                                         p(" "),
                                         div(class = "indicatortable",
                                         DT::dataTableOutput("DATAtable")))
                                ,tabPanel('BoxPlot',
                                         p(" "),
                                         plotOutput("boxplot1", width = "90%", height = "80%")
                                         )
                                , id = "tabs")
                    )
)
