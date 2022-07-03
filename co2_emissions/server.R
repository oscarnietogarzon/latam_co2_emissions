#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(leaflet)
library(data.table)
library(tidyverse)
library(maps)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    # Load and process the data
    
    df <- read.csv('https://raw.githubusercontent.com/owid/co2-data/master/owid-co2-data.csv')
    
    lac_countries <- c("Belize", "Costa Rica", "El Salvador", "Guatemala", "Honduras", "Mexico", "Nicaragua",
                       "Panama", "Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Ecuador",
                       "Guyana", "Paraguay", "Peru", "Suriname", "Uruguay", "Venezuela", "Cuba", "Dominican Republic",
                       "Haiti", "Puerto Rico")
    
    df %>% filter(year > 1990, country %in% lac_countries) %>%
        select(c("iso_code", "country", "year", "co2", "co2_per_capita")) -> df_lac30
    
    
    df_lac30 %>% group_by(country) %>% summarize(tot_co2 = sum(co2)) %>%
        arrange(desc(tot_co2)) -> tot_co2
    
    # Filter the data according to the input information from the sliders
    
    tempData <- reactive({
        
            df %>% filter(between(year, input$years[1], input$years[2]), 
                          country %in% lac_countries) %>%
                select(c("iso_code", "country", "year", "co2", "co2_per_capita")) -> data
            
        })
    
    # Create new dataset according to the input
    
    top_data <- reactive({
        
        tempData() %>% group_by(country) %>% summarize(tot_co2 = sum(co2),  mean_co2_per_capita = mean(co2_per_capita, na.rm = T)) %>%
            arrange(desc(tot_co2)) -> tot_co2
        
    })
    
    # Time series plot
    # Show the first "n" observations ----

    output$tsplot <- renderPlot({
        
        tot_co2 %>% dplyr::pull(country) -> countries_or
        top <-  countries_or[1:input$n]
        
        tempData() %>% filter(country %in% top) %>%
            ggplot( aes(x=year, y=co2, color=country)) +
            geom_line(size = 0.7) + 
            scale_color_brewer(palette = "Set2") +
            labs(x="", y="Millon Tonnes", title= bquote('Annual'~CO[2]~'Emissions' ) ) +
            theme_minimal() +
            theme(plot.title = element_text(hjust=0.5, size=20, face="bold")) 
        
    })
    
    # Show the first "n" observations ----
    # The output$view depends on both the databaseInput reactive
    output$view <- renderTable({
        top_data() %>% head(input$n)
    })
    
    
    output$mymap <- renderLeaflet({
        
        # Create a color palette for the map:
        mybins <- c(0,100,500,1000,5000,10000,50000)
        mypalette <- colorBin( palette="YlOrBr", domain=tot_co2$tot_co2, 
                               na.color="transparent", bins=mybins)
        bounds <- map("world", tot_co2$country, fill = TRUE, plot = FALSE)
        
        leaflet() %>%
            addProviderTiles(providers$Stamen.TonerLite,
                             options = providerTileOptions(noWrap = TRUE) ) %>%
            
            addPolygons(data = bounds, group = "country", 
                        fillColor =  ~mypalette(tot_co2$tot_co2),
                        stroke=TRUE, 
                        color = "white",
                        weight=0.3,
                        popup = paste("Country: ", bounds$names),
                        fillOpacity = 0.9,
            ) %>%
            addLegend(pal=mypalette, values=tot_co2, opacity=0.9, title = "Total Emissions (CO2)", position = "bottomleft" )
    })

})
