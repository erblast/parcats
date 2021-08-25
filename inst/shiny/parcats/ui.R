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
shinyUI(fluidPage(verticalLayout(

    # Application title
    titlePanel("easyalluvial"),
    inputPanel(
        shiny::checkboxGroupInput(
            "check_group_bin_numerics",
            "manip_bin_numerics()",
            c(
                center = "center",
                scale = "scale",
                transform = "transform"
            ),
            c(
                "center",
                "scale",
                "transform"
            ) 
        ),
        shiny::radioButtons(
            "select_fill_by",
            "fill_by",
            c(
                "first_variable",
                "last_variable",
                "all_flows",
                "values"
            )
        ),
        shiny::checkboxGroupInput(
            "check_group_col_filters",
            "palette_filter()",
            c(
                greys = "greys",
                # similar = "similar",
                reds = "reds",
                greens = "greens",
                blues = "blues",
                dark = "dark",
                medium = "medium",
                bright = "bright"
            ),
            c(
               "reds",
               "greens",
               "blues",
               "dark",
               "medium"
            ) 
        ),
        # shiny::numericInput(
        #     "select_num_tresh_similar",
        #     "thresh_similar",
        #     25,
        #     1,
        #     1000,
        #     1
        # ),
        shiny::radioButtons(
            "select_bin_labels",
            "bin_labels",
            c(
                'c("LL", "ML", "M", "MH", "HH")',
                "median",
                "mean",
                "min_max",
                "cuts"
            )
        ),
        shiny::checkboxInput(
            "check_marginal_histograms_easyalluvial",
            "add_marginal_histograms()",
            TRUE
        )
    ),
    
    mainPanel(
        shiny::plotOutput('easyalluvial', width = "800px", height = "600px")
    ),

    titlePanel("parcats"),

    inputPanel(
        shiny::checkboxInput(
            "check_marginal_histograms",
            "marginal_histograms",
            TRUE
        ),
        shiny::radioButtons(
            "select_hoveron",
            "hoveron",
            c(
                "color",
                "category",
                "dimension"
            )
        ),
        shiny::radioButtons(
            "select_hoverinfo",
            "hoverinfo",
            c(
                "count",
                "probability",
                "count+probability"
            )
        ),
        shiny::radioButtons(
            "select_arrangement",
            "arrangement",
            c(
                "perpendicular",
                "freeform",
                "fixed"
            )
        ),
        shiny::checkboxInput(
            "check_bundle_colors",
            "bundlecolors",
            TRUE
        ),
        shiny::radioButtons(
            "select_sortpaths",
            "sortpaths",
            c(
                "forward",
                "backward"
            )
        ),
        shiny::textInput(
            "select_label_font_colour",
            "label_font_colour",
            "black"
        ),
        shiny::numericInput(
            "select_num_label_font_size",
            "label_font_size",
            24,
            0,
            100,
            1
        ),
        shiny::textInput(
            "select_tick_font_colour",
            "tick_font_colour",
            "black"
        ),
        shiny::numericInput(
            "select_num_tick_font_size",
            "tick_font_size",
            value = 12,
            min = 0,
            max = 100,
            step = 1
        ),
        shiny::numericInput(
            "select_num_offset_marginal_histograms",
            "offset_marginal_histograms",
            value = 0.7,
            min = 0,
            max = 1,
            step = 0.05
        )
    ),


    # Show a plot of the generated distribution
    mainPanel(
        parcats::parcatsOutput('parcats', width = "800px", height = "600px")
    )
)))
