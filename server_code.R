##############################
# Data Portal Server-Side Code
##############################

####### TABLE

### This fetches the right dataset for the table, based on the selected filters.
TableInput <- reactive({
    switch(input$measurement,
         "Number of Days Reported" = switch(input$timeframe, Monthly = ReportedMonthly, Quarterly = ReportedQuarterly),
         "Average per 1,000 people" = switch(input$timeframe, Monthly = MeanMonthly, Quarterly = MeanQuarterly))
    })

### This generates the Table Data 
TableData <- reactive({  
    ### Apply Country Filter
    out <- TableInput() %>% filter(Country %in% c(input$country))
    
    ### Return the result
    out
    })

### This generates the main data table, based on the TableData, opens by default when the app starts
output$DATAtable <- DT::renderDataTable(TableData(),
                                ### column filter on the top
                                filter = 'top', server = TRUE, escape = FALSE,
                                style = 'bootstrap',
                                options = list(pageLength = 15, autoWidth = TRUE, scrollX = TRUE)) 


#######PLOT

### This fetches the right dataset for the plot, based on the selected filters.
PlotInput <- reactive({
  switch(input$measurement,
         "Number of Days Reported" = switch(input$timeframe
            , Monthly = switch(input$metric, Testing = ReportedMonthly <- ReportedMonthly %>% select(ISO3,Country,"Monthly count of days tests reported") 
                                            ,Cases = ReportedMonthly <- ReportedMonthly %>% select(ISO3,Country,"Monthly count of days cases reported")
                                            ,Deaths = ReportedMonthly <- ReportedMonthly %>% select(ISO3,Country,"Monthly count of days deaths reported"))
            , Quarterly = switch(input$metric,  Testing = ReportedQuarterly < -ReportedQuarterly %>% select(ISO3,Country,"Quarterly count of days tests reported") 
                                               ,Cases = ReportedQuarterly <- ReportedQuarterly %>% select(ISO3,Country,"Quarterly count of days cases reported")
                                               ,Deaths = ReportedQuarterly <- ReportedQuarterly %>% select(ISO3,Country,"Quarterly count of days deaths reported"))),
         "Average per 1,000 people" = switch(input$timeframe
           , Monthly = switch(input$metric, Testing = MeanMonthly <- MeanMonthly %>% select(ISO3,Country,"Monthly tests per 1,000 population") 
                              ,Cases = MeanMonthly <- MeanMonthly %>% select(ISO3,Country,"Monthly cases per 1,000 population")
                              ,Deaths = MeanMonthly <- MeanMonthly %>% select(ISO3,Country,"Monthly deaths per 1,000 population"))
           , Quarterly = switch(input$metric,  Testing = MeanQuarterly <- MeanQuarterly %>% select(ISO3,Country,"Quarterly tests per 1,000 population") 
                                ,Cases = MeanQuarterly <- MeanQuarterly %>% select(ISO3,Country,"Quarterly cases per 1,000 population")
                                ,Deaths = MeanQuarterly <- MeanQuarterly %>% select(ISO3,Country,"Quarterly deaths per 1,000 population"))))
})

### This generates the BoxPlot data 
PlotData <- reactive({  
  ### Apply Country Filter
  out <- PlotInput() %>% filter(Country %in% c(input$country))
  
  ### Return the result
  out
})

### This generates up to six reactive boxplots, depending on how many countries are selected
output$boxplot1 <- renderPlot({
                    p1 <- ggplot(PlotData()
                                , aes(x = PlotData()[[2]],
                                      y = PlotData()[[3]],
                                      fill=PlotData()[[2]])) +
                         geom_boxplot(alpha=0.3,
                                      outlier.colour="black", outlier.shape=16,
                                      outlier.size=2,
                                      notch=FALSE) +
                         xlab("County") +
                         ylab(colnames(PlotData())[[3]]) +
                         theme(axis.text=element_text(size=12),
                               axis.title=element_text(size=14,face="bold"),
                               panel.background = element_blank(),
                               panel.grid.major = element_blank(),
                               panel.grid.minor = element_blank(),
                               legend.position="none")+
                         stat_boxplot(geom = 'errorbar')
                         scale_fill_brewer(palette="BuPu")
                    print(p1)
                              }, height = 600)
