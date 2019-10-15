#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(easyalluvial)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Parcats"),


        # Show a plot of the generated distribution
        mainPanel(
            easyalluvial::alluvial_as_plotlyOutput('parcats')
        )
))
