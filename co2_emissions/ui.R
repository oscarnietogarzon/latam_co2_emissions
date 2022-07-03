#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # App title ----
    titlePanel("Course project - CO2 emissions in Latin American countries"),
    
    # Sidebar Panel with input and output definitions ----
    sidebarPanel(
        
        # Text ----
        "You must select the number of countries to display",
        br(),
        width = 3,
        # Input: Number of countries to display ----
        numericInput(inputId = "n",
                     label = "Number of countries to view:",
                     value = 5),
        br(),
        # Input: Slider for the years of analysis ----
        sliderInput(inputId = "years",
                    label = "Select years to analyze",
                    min = 1990,
                    max = 2020,
                    value = c(1990, 2020),
                    width = "220px"),
    ),
    # Main Panel with outputs in each tab ----
    mainPanel(
        tabsetPanel(
            id = "tabs",
            
            # Tab Panel with time series plot ----
            tabPanel(
                # Title of the tab ----
                title = "Plot",
                # Title in the tab ----
                h3("Time series plot of  CO2 emissions by year"),
                # Output: Time Series Plot ----
                plotOutput(outputId = "tsplot")),
            
            # Tab Panel with the dataset ----
            tabPanel(
                # Title of the tab ----
                title = "Table",
                # Title in the tab ----
                h3("Total CO2 emissions by country"),
                tableOutput("view")),
            
            # Tab Panel with the Map ----
            tabPanel(
                # Title of the tab ----
                title = "Map",
                # Title in the tab ----
                h3("Map of total CO2 emissions by country"),
                leafletOutput("mymap"))
        ))
))
