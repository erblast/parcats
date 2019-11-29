# satisfy CMDcheck
# https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when


if(getRversion() >= "2.15.1"){
  utils::globalVariables( c('.', 'alluvial_id', 'color', 'color_line', 'color_marker', 'fill_flow', 'fill_value',
                            'label', 'line_at', 'perc', 'plotted', 'rwn', 'shape_index', 'trace_index', 'trace_number',
                            'type', 'value', 'value_str', 'var_key', 'variable', 'x', 'x_value') )
}




trace_hist_all = function(p, data_input){
  
  vars = p$data$x %>% levels()
  
  traces = list()
  
  for (var in vars) {
    
    is_pred = var == 'pred'
    
    if(! is_pred){
      is_num = is.numeric( data_input[[var]] )
    }else{
      var_pred = names(data_input)[! names(data_input) %in% names(p$alluvial_params$dspace) ]
      if(length(var_pred) > 1){
        stop( paste('\n"data_input" should only contain explanatory and response variables, so response variable can be inferred.
                  \nPotential response variables:', paste( var_pred, collapse = ', ')
                    , '\nPlease pass correct response variable as string using the "pred_var" parameter.' ) )
      }
      is_num = is.numeric( data_input[[var_pred]] )
    }
    
    if( is_num ){
      trace = trace_hist_num(p, data_input, var = var)
    }else{
      trace = trace_hist_cat(p, data_input, var = var)
    }
    
    traces = append(traces, trace)
  }
  
  return(traces)
}

trace_rug_all = function(p, data_input){
  vars = p$data$x %>% levels()
  
  traces = list()
  
  for (var in vars) {
    
    trace = trace_rug(p, data_input, var)

    traces = append(traces, trace)
  }
  
  return(traces)
}

trace_rug = function(p, data_input, var){
  
  vars = p$data$x %>% levels
  
  is_num = is.numeric(data_input[[var]])
  
  if(is_num){
    x = data_input[[var]]
    y = rep('rug', length(data_input[[var]]) )
    type = 'scatter'
  }else{
    x = c()
    y = c()
    type = 'bar'
  }
  
  trace = list( type = type
        , mode = 'markers'
        , x = x
        , y = y
        , marker = list(symbol = 'line-ns-open', color = 'black')
        , xaxis = paste0( 'x', which(vars == var) )
        , yaxis = paste0( 'y1', which(vars == var) ) 
        , name = paste0('rug_', var)
        , showlegend = FALSE
  )
  
  trace = list(trace)
  names(trace) <- paste0('rug_', var)
  
  return( trace )
}

trace_hist_mod = function(p, data_input, var){
  # creates densitiy histogram with line markers for model response
  
  p_hist = easyalluvial::plot_hist(var = var, p = p, data_input = data_input)
  
  df = p_hist$data
  
  vars = p$data$x %>% levels
  
  values = data_input[[var]]

  dens = density(values)
  x_var = dens$x
  y_var = dens$y
    
  trace_var = list( x = x_var
                    , y = y_var
                    , type = 'scatter'
                    , line = list( color = 'grey' )
                    , marker = list( size = 0
                                     , color = 'grey'
                                     , opacity = 0)
                    , showlegend = FALSE
                    , name = paste0( var, '_dens')
                    , xaxis = paste0( 'x', which(vars == var) )
                    , yaxis = paste0( 'y', which(vars == var) ) 

                    )
  
  trace_var = list(trace_var)
  names(trace_var) <- paste0( var, '_dens')
  
  lines_at = p$alluvial_params$dspace[[var]] %>%
    unique() %>%
    sort()
  
  # we have to rejoin with fill labels
  # labels need to be consistent {var}_{fill_label} so that we 
  # can track the traces
  
  fill_labels = p$data %>%
    filter( x == var) %>%
    select( value, fill_value) %>%
    distinct() %>%
    arrange( desc(value) ) %>%
    mutate( line_at = lines_at) %>%
    rename( label = value
            , color = fill_value )
  

  trace_vlines = fill_labels %>%
    mutate( trace = pmap(list(label, color, line_at)
                         , function(l, c, lin) list( x0 = lin
                                       , y0 = 0
                                       , x1 = lin
                                       , y1 = max(y_var)
                                       , type = 'line'
                                       , line = list( color = 'lightgrey')
                                       , showlegend = FALSE
                                       , name = paste0( var,'_' ,l )
                                       , xref = paste0( 'x', which(vars == var) )
                                       , yref = paste0( 'y', which(vars == var) ) ) )
      ) %>%
      .$trace
    

  names(trace_vlines) <- paste0( var,'_', fill_labels$label )
  
  traces = append(trace_var, trace_vlines)
  
}

trace_hist_num = function(p, data_input, var){
  
  
  p_hist = easyalluvial::plot_hist(var = var, p = p, data_input = data_input)
  
  df = p_hist$data
  
  vars = p$data$x %>% levels
  
  if(var == 'pred'){
    
    # we have to rejoin with fill labels
    # labels need to be consistent {var}_{fill_label} so that we 
    # can track the traces
    
    fill_labels = p$data %>%
      filter( x == 'pred') %>%
      select(fill, value, fill_value) %>%
      mutate( rwn = as.numeric(fill) ) %>%
      distinct() %>%
      arrange( desc(rwn) ) %>%
      mutate( rwn = row_number() )
    
    
    df = df %>%
      filter(variable == 'pred') %>%
      left_join( fill_labels, by = 'rwn')
  }
  
  if( p$alluvial_type == 'model_response' & var != 'pred'){
    return( trace_hist_mod(p, data_input, var) )
  }
  
  df = df %>%
    group_by(fill) %>%
    tidyr::nest() %>%
    mutate(trace = map2(data, fill, function(x,y) list( x = x$x
                                     , y = x$y
                                     , fillcolor = x$fill_value[1]
                                     , fill = 'tozeroy'
                                     , type = 'scatter'
                                     , line = list( color = x$fill_value[1] )
                                     , marker = list( size = 0
                                                      , color = x$fill_value[1]
                                                      , opacity = 0)
                                     , showlegend = FALSE
                                     #, text = y
                                     #, hoveron = 'points'
                                     , name = y
                                     , xaxis = paste0( 'x', which(vars == var) )
                                     , yaxis = paste0( 'y', which(vars == var) ) ) ) )
  traces = df$trace
  
  names(traces) <- paste0( var, '_', df$fill)
  
  return(traces)
}

trace_hist_cat = function(p, data_input, var){
  
  p_hist = easyalluvial::plot_hist(var = var, p = p, data_input = data_input)
  
  df_label = p$data %>%
    filter( x == var ) %>%
    mutate( value = fct_drop(value) ) %>%
    select( value ) %>%
    distinct() %>%
    arrange( desc(value) ) %>%
    mutate( rwn = row_number() )
  
  if( var %in% names(p_hist$data) ){
    # categorical variables from model response plots
    df = p_hist$data %>%
      mutate( rwn = as.integer( !! as.name(var) ) ) %>%
      left_join( df_label, by = 'rwn') %>%
      rename( var_key = !! as.name(var) )
  }else if( var == 'pred' ){
    df = p_hist$data %>%
      filter( variable == 'pred') %>%
      mutate( var_key = value
              , pred = value ) %>%
      ungroup() %>%
      select(var_key, fill_value, value, n) %>%
      uncount(n)
    
  }else{
    # categorical variables from regular alluvial plots
    df = p_hist$data %>%
      mutate( var_key = as.factor(var_key)
              , rwn = as.integer( var_key ) ) %>%
      left_join( df_label, by = 'rwn')
  }
  
  lvl = levels(df[[var]])
  
  vars = p$data$x %>% levels
  
  df = df %>%
    mutate( var_key = fct_relevel(var_key, lvl) ) %>%
    group_by(var_key, fill_value, value) %>%
    count() %>%
    arrange(var_key) %>%
    mutate(trace = list( list( x = list(var_key)
                        , y = list(n)
                        , type = 'bar'
                        , marker = list(color = as.character(fill_value) )
                        , showlegend = FALSE
                        # , width = 0.5
                        , name = paste0(var, '_', value)
                        , xaxis = paste0( 'x', which(vars == var) )
                        , yaxis = paste0( 'y', which(vars == var) ) ) ) )
  traces = df$trace
  
  names(traces) <- paste0( var, '_', df$value)
  
  return(traces)
}

trace_imp = function(p, data_input, truncate_at = 50, color = 'darkgrey'){
  
  p_imp = easyalluvial::plot_imp(p, data_input, truncate_at, color )
  
  df = p_imp$data
  
  if( ! 'const_values' %in% names(df) ){
    df$const_values = NA
  }
  
  df = df %>%
    mutate_if( is.factor, as.character ) %>%
    arrange( perc ) %>%
    mutate( fill = ifelse(plotted == 'n', 'lightgrey', color)
            , method = p$alluvial_params$method 
            , text = case_when( plotted == 'y' ~ 'alluvial'
                                , method == 'pdp' ~ 'pdp'
                                , TRUE ~ paste('fixed:', const_values) ) ) %>%
    group_by(vars, perc) %>%
    mutate( trace = list( list( y = list(vars)
                          , x = list(perc)
                          , type = 'bar'
                          , marker = list( color = fill  )
                          , showlegend = FALSE
                          , width = 0.5
                          , name = text
                          , xaxis = 'x99'
                          , yaxis = 'y99'
                          , orientation = 'h'
                          ) ) ) 
  
  traces = df$trace
  
  names(traces) <- paste0( 'imp_', df$vars)
  
  return(traces)
}


trace_parcats = function(p
                         , domain
                         , hoveron
                         , hoverinfo
                         # , hovertemplate
                         , arrangement
                         , bundlecolors
                         , sortpaths
                         , labelfont
                         , tickfont
                         ){
  
  if(p$alluvial_type == 'model_response'){
    df = p$data %>%
      arrange( desc(value) ) %>%
      mutate(value_str = as.character(value)
              , value_str = ifelse( x != 'pred', str_split(value_str, '\\\n'), value_str)
              , value_str = map_chr(value_str, 1)
              , value_str = as_factor(value_str)
              , value_str = fct_rev(value_str)
              , value = value_str) %>%
      select( - value_str)
  }else{
    df = p$data
  }
  
  df = df %>%
    select( - fill_value, - fill ) %>%
    spread(x, value) %>%
    arrange(alluvial_id)
  
  if( nrow(df) != ( df$alluvial_id %>% as.numeric %>% max() ) ){
    stop('data assumption violated')
  }
  
  dim_names = df %>%
    select(-n, - alluvial_id, - fill_flow) %>%
    names()
  
  for(name in dim_names){
    
    order_array = df[[name]] %>%
      fct_drop() %>%
      levels()
    
    l = list(label = name
             , values = df[[name]]
             , categoryorder = 'array'
             , categoryarray = order_array )
    
    if(name == dim_names[1]){
      dimensions = list( l )
    }else{
      dimensions[[length(dimensions) + 1]] = l
    }
  }
  
  parcats = list(
    type = 'parcats'
    , dimensions = dimensions
    , counts = df$n
    , line = list( shape = 'hspline'
                   , color = df$fill_flow)
    , hoveron = hoveron
    , hoverinfo = hoverinfo
    , labelfont = labelfont
    # , hovertemplate = hovertemplate
    , arrangement = arrangement
    , bundlecolors = bundlecolors
    , sortpaths = sortpaths
    , tickfont = tickfont
    , domain = domain )

}

create_layout_rug = function(trace_rugs, layout_hist, offset = 0.01){
  
  
  layout = layout_hist[ which( startsWith(names(layout_hist), 'yaxis' ) )]
  
  for( i in seq(1, length(layout) ) ){
    domain_old = layout[[i]]$domain
    domain_new = c(domain_old[1] - offset, domain_old[1] - 0.001 )
    layout[[i]]$domain <- domain_new
    layout[[i]]$anchor <- paste0('x', i)
    names(layout)
    
  }
  
  names(layout) <- paste0('yaxis1', seq(1, length(layout) ) )
  
  return(layout)
}

create_layout_hist = function(trace_hist
                              , lim_up = 0.9
                              , lim_right = 1
                              , space = 0.025
                              ){
  
  
  lim_right = ifelse( lim_right == 1, 1, lim_right - 0.05 )
  
  yaxis = map(trace_hist, 'yaxis') %>% unique() %>% unlist %>% sort()
  xaxis = map(trace_hist, 'xaxis') %>% unique() %>% unlist %>% sort()
  
  coord_x = seq(0,1, lim_right / length(yaxis) )
  
  spaces = map(coord_x, ~ c(.-space/2, .+space/2) ) %>% unlist() 
  
  coord_x = c(0, spaces[3:(length(spaces)-2) ], lim_right)
  
  layout = list()
  
  for( i in seq(1, length(xaxis), 1) ){
    
    
    layout_x = list( domain = coord_x[(i*2-1):(i*2)]
                     #, anchor = yaxis[i]
                     , anchor = paste0('y1', i)
                     , showgrid = FALSE
                     , showline = FALSE
                     , zeroline = FALSE )
    
    layout_x = list(layout_x)
    
    num = xaxis[i] %>% str_extract('[0-9]+')
    names(layout_x) <- paste0('xaxis', num)
    
    layout = append(layout, layout_x )
  }
  
  for( i in seq(1, length(yaxis), 1) ){
    layout_y = list( domain = c(lim_up, 1)
                     #, anchor = xaxis[i]
                     #, anchor = paste0('xaxis1', i)
                     , showgrid = FALSE
                     , showline = FALSE
                     , showticklabels = FALSE
                     , zeroline = FALSE )

    layout_y = list(layout_y)
    
    num = yaxis[i] %>% str_extract('[0-9]+')
    names(layout_y) <- paste0('yaxis', num)
    
    layout = append(layout, layout_y )
    
    
  }
  
  return(layout)
}

map_trace = function(p, trace_hist){
  
  df = p$data %>%
    mutate( x_value = map2_chr(x, value, function(x,y) paste0(x,'_' ,y) )
            , trace_number = map(x_value, ~ which(names(trace_hist) == . ) )
            , trace_number = map_int(trace_number, ~ ifelse( is_empty(.), NA, .)  ) ) %>%
    filter( ! is.na(trace_number) ) %>%
    mutate( type = map_chr(trace_number, ~ trace_hist[[.]][['type']] ) 
           , color_marker = map(trace_number, ~ trace_hist[[.]][['marker']][['color']] )
           , color_line = map(trace_number, ~ trace_hist[[.]][['line']][['color']] )
           , color = ifelse( type == 'line', color_line, color_marker)
           , color = map_chr(color, ~ . )
           ) %>%
    select(alluvial_id, trace_number, type, color) %>%
    group_by(alluvial_id) %>%
    tidyr::nest() %>%
    ungroup() %>%
    mutate(trace_number = map(data, 'trace_number')
           , type = map(data, 'type')
           , color = map(data, 'color')
           , alluvial_id = as.character(alluvial_id) )
  
  map_curve = df$trace_number
  names(map_curve) <- df$alluvial_id
  
  map_type = df$type
  names(map_type) <- df$alluvial_id
  
  map_color = df$color
  names(map_color) <- df$alluvial_id
  
  return( list( map_curve = map_curve
                , map_type = map_type
                , map_color = map_color) )
  
}

get_shapes = function(traces){
  
  types = map_chr(traces, ~ .$type) %>%
    unname()
  
  lines_index = which(types == 'line')
  
  shapes =  traces[lines_index] 
  
  map_trace_2_shape = tibble( trace_index = seq(1, length(traces) ) ) %>%
    mutate( shape_index = map( trace_index, ~ which(lines_index == .) ) 
            , shape_index = map_int( shape_index, ~ ifelse( is_empty(.), as.integer(0), .) )  
            )
  
  ls_shapes = list( map_trace_2_shape = map_trace_2_shape$shape_index
                    , shapes = shapes)
  
  return(ls_shapes)
}

#'@title create plotly parallel categories diagram from alluvial plot
#'@description creates an interactive parallel categories diagram from an 'easyalluvial'
#'  plot using the 'plotly.js' library
#'@param p alluvial plot
#'@param marginal_histograms logical, add marginal histograms, Default: TRUE
#'@param data_input dataframe, data used to create alluvial plot, Default: NULL
#'@param imp dataframe, with not more then two columns one of them numeric
#'  containing importance measures and one character or factor column containing
#'  corresponding variable names as found in training data.
#'@param width integer, htmlwidget width in pixels, Default: NULL
#'@param height integer, htmlwidget height in pixels, Default: NULL
#'@param elementId , htmlwidget elementid, Default: NULL
#'@param hoveron character, one of c('category', 'color', 'dimension'), Sets the
#'  hover interaction mode for the parcats diagram.', 'If `category`, hover
#'  interaction take place per category.', 'If `color`, hover interactions take
#'  place per color per category.', 'If `dimension`, hover interactions take
#'  place across all categories per dimension., Default: 'color'
#'@param hoverinfo character, one of c('count', 'probability',
#'  'count+probability') set info displayed on mouse hover Default:
#'  'count+probability'
#'@param arrangement, character, one of c('perpendicular', 'freeform', 'fixed')
#'  'Sets the drag interaction mode for categories and dimensions.', 'If
#'  `perpendicular`, the categories can only move along a line perpendicular to
#'  the paths.', 'If `freeform`, the categories can freely move on the plane.',
#'  'If `fixed`, the categories and dimensions are stationary.', Default:
#'  'perpendicular'
#'@param bundlecolors logical, 'Sort paths so that like colors are bundled
#'  together within each category.', Default: TRUE
#'@param sortpaths character, one of c('forward', 'backward'), 'Sets the path
#'  sorting algorithm.', 'If `forward`, sort paths based on dimension categories
#'  from left to right.', Default: 'forward' 'If `backward`, sort paths based on
#'  dimensions categories from right to left.'
#'@param labelfont list, 'Sets the font for the `dimension` labels.', Default:
#'  list(size = 24, color = 'black')
#'@param tickfont list, Sets the font for the `category` labels.', Default: NULL
#'@param offset_marginal_histograms double, height ratio reserved for parcats
#'  diagram, Default: 0.8
#'@param offset_imp double, width ratio reserved for parcats diagram, Default:
#'  0.9
#'@return htmlwidget
#'@details most parameters are best left at default values
#' @examples
#'
#'library(easyalluvial)
#'
#' # alluvial wide ---------------------------------
#' p = alluvial_wide(mtcars2, max_variables = 5)
#'
#' parcats(p, marginal_histograms = FALSE)
#'
#' parcats(p, marginal_histograms = TRUE, data_input = mtcars2)
#'
#' # alluvial for model response --------------------
#' df = mtcars2[, ! names(mtcars2) %in% 'ids' ]
#' m = randomForest::randomForest( disp ~ ., df)
#' imp = m$importance
#' dspace = get_data_space(df, imp, degree = 3)
#' pred = predict(m, newdata = dspace)
#' p = alluvial_model_response(pred, dspace, imp, degree = 3)
#'
#' parcats(p, marginal_histograms = TRUE, imp = TRUE, data_input = df)
#'
#'
#'@seealso \code{\link[easyalluvial]{alluvial_wide}}
#', \code{\link[easyalluvial]{alluvial_long}}
#', \code{\link[easyalluvial]{alluvial_model_response}}
#', \code{\link[easyalluvial]{alluvial_model_response_caret}}
#`
#'@rdname parcats
#'@export
#'@importFrom htmlwidgets createWidget
#'@importFrom tidyr nest uncount
#'@importFrom stringr str_extract str_split
#'@import dplyr
#'@import tidyr
#'@import forcats
#'@import purrr
#'@import easyalluvial
#'@importFrom graphics text
#'@importFrom stats density
#'@importFrom utils data  
parcats <- function(p, marginal_histograms = TRUE, data_input = NULL
                     , imp = TRUE
                     , width = NULL, height = NULL, elementId = NULL
                     , hoveron = 'color'
                     , hoverinfo = 'count+probability'
                     # , hovertemplate = NULL
                     , arrangement = 'perpendicular'
                     , bundlecolors = TRUE
                     , sortpaths = 'forward'
                     , labelfont = list( size = 24, color = 'black' )
                     , tickfont = NULL
                     , offset_marginal_histograms = 0.8
                     , offset_imp = 0.9
                     ) {

  if(marginal_histograms & is.null(data_input) ){
    stop('data_input required if marginal_histograms == TRUE')
  }
  
  if( imp == TRUE & is.null(data_input) & p$alluvial_type == 'model_response' ){
    stop('data_input required if imp == TRUE')
  }else if(p$alluvial_type != 'model_response' | ! imp ){
    imp = FALSE
    offset_imp = 1
  }
  
  if(marginal_histograms){
    domain = list(y = c(0, 0.7))
  }else{
    domain = list( y = c(0, 1) )
  }
  
  if( imp & p$alluvial_type == 'model_response' ){
    domain$x = c(0, offset_imp - 0.05 )
    traces_imp = trace_imp(p, data_input, truncate_at = 50, color = 'darkgrey')
  }else{
    traces_imp = list()
  }
  
  parcats = trace_parcats(p, domain = domain
                          , hoveron = hoveron
                          , hoverinfo = hoverinfo
                          # , hovertemplate = hovertemplate
                          , arrangement = arrangement
                          , bundlecolors = bundlecolors
                          , sortpaths = sortpaths
                          , labelfont = labelfont
                          , tickfont = tickfont
                          )
  
  if(marginal_histograms){
    trace_hist = trace_hist_all(p, data_input)
    trace_rugs = trace_rug_all(p, data_input)
    traces = append( list(parcats = parcats), trace_hist) 
    traces = append( traces, trace_rugs )
    layout_hist = create_layout_hist(trace_hist, lim_right = offset_imp)
    layout_rug = create_layout_rug(trace_rugs, layout_hist)
    layout = append(layout_hist, layout_rug)
    ls_shapes = get_shapes(trace_hist)
    shapes = ls_shapes$shapes
    map_trace_2_shape = ls_shapes$map_trace_2_shape
    ls_map = map_trace(p, trace_hist)
    map_curve = ls_map$map_curve
    map_type = ls_map$map_type
    map_color = ls_map$map_color

  }else{
    trace_hist = list()
    traces = list(parcats = parcats)
    layout = list()
    shapes = list()
    map_trace_2_shape = list()
    map_curve = list()
    map_type = list()
    map_color = list()
  }
  
  if(imp){
    traces = append(traces, traces_imp)
    layout_imp = list( yaxis99 = list( domain = c(0,1)
                                       , anchor = 'y99' 
                                       , showticklabels = FALSE
                                       )
                       , xaxis99 = list(domain = c(offset_imp,1)
                                        , anchor = 'x99' 
                                        , showticklabels = FALSE
                                        ) ) 
    layout = append(layout, layout_imp)
    
    # we cannot move the axis labels to display inside the plot
    # so we use annotations instead
    
    annotations = list()
    
    p_imp = easyalluvial::plot_imp(p, data_input)
    
    max_perc = p_imp$data$perc %>% max()
    
    for( i in seq(1, length(traces_imp) ) ){
      l = list( xref = 'x99'
            , yref = 'y99'
            , x = max_perc # traces_imp[[1]]$x[[1]]
            , y = traces_imp[[i]]$y[[1]]
            , showarrow = FALSE
            , text = traces_imp[[i]]$y[[1]]
            , align = 'right'
            )
      
      annotations[[i]] = l
    }
    
    layout$annotations = annotations
    
  }
  
  x = list( traces = traces
            , layout = layout
            , shapes = shapes
            # JS does not make copies of variables thus we pass one to
            # change and one to keep. 
            , shapes_original = shapes
            , map_curve = map_curve %>% unname()
            , map_trace_2_shape = map_trace_2_shape
            , map_type = map_type %>% unname()
            , map_color = map_color %>% unname()
            , parcats_cols = parcats$line$color
            , imp = imp
            )
  
  # create widget
  htmlwidgets::createWidget(
    name = 'parcats',
    x,
    width = width,
    height = height,
    package = 'parcats',
    elementId = elementId
  )
}

#' Shiny bindings for parcats
#'
#' Output and render functions for using parcats within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a parcats
#' @param env The environment in which to evaluate \code{expr}.
#' @param inline, logical, Default: FALSE
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name parcats-shiny
#'
#' @export
parcatsOutput <- function(outputId, width = '100%', height = '100%', inline = FALSE){
  htmlwidgets::shinyWidgetOutput(outputId
                                 , 'parcats'
                                 , width
                                 , height
                                 , package = 'parcats'
                                 , inline = inline
                                 , reportSize = TRUE)
}

#' @rdname parcats-shiny
#' @export
render_parcats <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, parcatsOutput, env, quoted = TRUE)
}
