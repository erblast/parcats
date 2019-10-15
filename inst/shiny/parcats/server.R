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

# Define server logic required to draw a histogram
shinyServer(function(input, output) {


    output$parcats <- easyalluvial::render_alluvial_as_plotly({
        
        p = alluvial_wide(mtcars2, max_variables = 5)
        
        w = alluvial_as_plotly(p, marginal_histograms = F)
        
        w
    })
    

})
