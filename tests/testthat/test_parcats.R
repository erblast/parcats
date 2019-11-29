

context('parcats')

test_that('parcats_alluvial_wide'
  ,{
    
    p = alluvial_wide(mtcars2, max_variables = 5)
    
    parcats(p, marginal_histograms = FALSE)
    
    expect_error( parcats(p, marginal_histograms = TRUE) )
    
    parcats(p, marginal_histograms = TRUE, data_input = mtcars2)
    
    df = select(mtcars2, mpg, disp, wt, am, qsec)
    
    p = alluvial_wide(df)
    
    parcats(p, marginal_histograms = TRUE, data_input = df)

})


test_that('parcats_alluvial_wide_num_only'
          ,{
            
    df = mtcars2 %>%
      select_if(is.numeric)
            
    p = alluvial_wide(df, max_variables = 5)
    
    parcats(p, data_input = df)
    
})

test_that('parcats_params',{
  
  p = alluvial_wide(mtcars2, max_variables = 5)
  
  # hoveron
  parcats(p, hoveron = 'category', marginal_histograms = TRUE, data_input = mtcars2)
  parcats(p, hoveron = 'color', marginal_histograms = TRUE, data_input = mtcars2)
  parcats(p, hoveron = 'dimension', marginal_histograms = TRUE, data_input = mtcars2)
  
  #hoverinfo
  parcats(p, hoverinfo = 'count', marginal_histograms = FALSE)
  parcats(p, hoverinfo = 'probability', marginal_histograms = FALSE)
  parcats(p, hoveron = 'count+probability', marginal_histograms = FALSE)
  
  # hovertemplate probably needs some kind of format string, too complicated will drop this
  # parcats(p, hovertemplate = 'count', marginal_histograms = FALSE)
  # parcats(p, hovertemplate = 'probability', marginal_histograms = FALSE)
  # parcats(p, hovertemplate = 'category', marginal_histograms = FALSE)
  # parcats(p, hovertemplate = 'categorycount', marginal_histograms = FALSE)
  # parcats(p, hovertemplate = 'colorcount', marginal_histograms = FALSE)
  # parcats(p, hovertemplate = 'bandcolorcount', marginal_histograms = FALSE)
  
  # arrangement
  parcats(p, arrangement = 'fixed', marginal_histograms = FALSE)
  parcats(p, arrangement = 'perpendicular', marginal_histograms = FALSE)
  parcats(p, arrangement = 'freeform', marginal_histograms = FALSE)
  
  #bundlecolors
  parcats(p, bundlecolors = TRUE, marginal_histograms = FALSE)
  parcats(p, bundlecolors = FALSE, marginal_histograms = FALSE)
  
  #sortpaths
  parcats(p, sortpaths = 'forward', marginal_histograms = FALSE)
  parcats(p, sortpaths = 'backward', marginal_histograms = FALSE)
  
  #labelfont
  parcats(p, labelfont = list(size = 18, color = 'blue'), marginal_histograms = FALSE)
  
  #tickfont
  parcats(p, tickfont = list(size = 18, color = 'blue'), marginal_histograms = FALSE)
  
})

test_that('parcats_alluvial_long'
          ,{
            
    p = alluvial_long(quarterly_flights, key = qu, value = mean_arr_delay, id = tailnum)
    
    parcats(p, marginal_histograms = FALSE)
    
    p = alluvial_long(quarterly_flights, key = qu, value = mean_arr_delay, id = tailnum, fill = carrier)
    
    parcats(p, marginal_histograms = FALSE)
    
    p = alluvial_long(quarterly_sunspots, key = qu, value = spots, id = year)
    
    parcats(p, marginal_histograms = FALSE)
    
})

test_that('parcats_alluvial_model_response'
          ,{
            
    df = mtcars2[, ! names(mtcars2) %in% 'ids' ]
    m = randomForest::randomForest( disp ~ ., df)
    imp = m$importance
    dspace = get_data_space(df, imp, degree = 3)
    pred = predict(m, newdata = dspace)
    p = alluvial_model_response(pred, dspace, imp, degree = 3)
    
    parcats(p, marginal_histograms = FALSE, imp = FALSE)
    
    parcats(p, marginal_histograms = TRUE, imp = FALSE, data_input = df)
    
    parcats(p, marginal_histograms = TRUE, imp = TRUE, data_input = df)
    
    # grid = add_marginal_histograms(p, df)
    
    # pdb
    pred = get_pdp_predictions(df, imp, m, degree = 3)
    p = alluvial_model_response(pred, dspace, imp, degree = 3, method = 'pdp')
    parcats(p, marginal_histograms = TRUE, imp = TRUE, data_input = df)
    
    # categorical response ---------------------------
    
    df = titanic %>%
      select_if(is.factor)
    
    set.seed(0)
    m = randomForest::randomForest( Survived ~ ., df)
    imp = m$importance
    
    expect_warning( {dspace = get_data_space(df, imp, degree = 3, max_levels = 5)} )
    
    expect_true( nrow(dspace) == 30 )
    
    pred = predict(m, newdata = dspace,type = 'response')
    p = alluvial_model_response(pred, dspace, imp, degree = 3)
    
    parcats(p, marginal_histograms = FALSE, imp = FALSE)
    
    suppressWarnings({
      # warning is raised because number of factors is cut to 5
      parcats(p, marginal_histograms = TRUE, imp = FALSE, data_input = df)
      
      parcats(p, marginal_histograms = TRUE, imp = TRUE, data_input = df)
    })
    
    # grid = add_marginal_histograms(p, df)
    
})