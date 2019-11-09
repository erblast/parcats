#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(parcats)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("parcats")


    # Show a plot of the generated distribution
    , mainPanel(
        parcats::parcatsOutput('parcats')
        
        , plotly::plotlyOutput('plotly')
    )
))
