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

    p <- reactive({
        alluvial_wide(
            mtcars2,
            max_variables = 5,
            fill_by = input$select_fill_by,
            col_vector_flow = palette_filter(
                palette_qualitative(),
                greys = "greys" %in% input$check_group_col_filters,
                # similar = "similar" %in% input$check_group_col_filters,
                reds = "reds" %in% input$check_group_col_filters,
                greens = "greens" %in% input$check_group_col_filters,
                blues = "blues" %in% input$check_group_col_filters,
                dark = "dark" %in% input$check_group_col_filters,
                medium = "medium" %in% input$check_group_col_filters,
                bright = "bright" %in% input$check_group_col_filters
                # thresh_similar = input$select_num_tresh_similar
            ),
            bin_labels = 
                if (input$select_bin_labels == 'c("LL", "ML", "M", "MH", "HH")') 
                    c("LL", "ML", "M", "MH", "HH") 
            else input$select_bin_labels,
            scale = "scale" %in% input$check_group_bin_numerics,
            center = "center" %in% input$check_group_bin_numerics,
            transform = "transform" %in% input$check_group_bin_numerics
        )
    })

    output$easyalluvial <- shiny::renderPlot({
        if (! input$check_marginal_histograms_easyalluvial) {
            p()
        } else {
            p() %>%
                add_marginal_histograms(mtcars2)
        }
    })
    
    output$parcats <- parcats::render_parcats({
        
        parcats(
            p(),
            marginal_histograms = input$check_marginal_histograms,
            data_input = mtcars2,
            hoveron = input$select_hoveron,
            hoverinfo = input$select_hoverinfo,
            arrangement = input$select_arrangement,
            bundlecolors = input$check_bundle_colors,
            sortpaths = input$select_sortpaths,
            labelfont = list(
                size = input$select_num_label_font_size,
                color = input$select_label_font_colour
            ),
            tickfont = list(
                size = input$select_num_tick_font_size,
                color = input$select_tick_font_colour
            ),
            offset_marginal_histograms = input$select_num_offset_marginal_histograms,
            width = 1024,
            height = 768
        )
        
    })
    
})
