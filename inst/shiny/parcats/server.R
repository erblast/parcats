#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(easyalluvial)
library(parcats)
library(tidyverse)
library(plotly)




# Define server logic required to draw a histogram
shinyServer(function(input, output) {


    output$parcats <- parcats::render_parcats({
        
        p = alluvial_wide(mtcars2, max_variables = 5)
        
        parcats(p, marginal_histograms = TRUE, data_input = mtcars2 )
        
    })
    
})
