# Metric module with summary

import("shiny")
import("dplyr")
import("htmltools")
import("glue")

export("ui")
export("init_server")

expose("constants.R")
expose("utilities/getMetricsChoices.R")
expose("utilities/getTimeFilterChoices.R")
expose("utilities/getDataByTimeRange.R")
expose("utilities/getPercentChangeSpan.R")

ui <- function(id) {
  ns <- NS(id)
  choices <- getMetricsChoicesByCategory(id)

  tagList(
    selectInput(
      ns("summary_metric"), "Metric",
      choices,
      width = NULL,
      selectize = TRUE,
      selected = choices[[1]]
    ),
    uiOutput(ns("summary"))
  )
}

init_server <- function(id, df, y, previous_time_range) {
  callModule(server, id, df, y, previous_time_range)
}

server <- function(input, output, session, df, y, previous_time_range) {
    metric <- reactive({ consts$metrics_list[[input$summary_metric]] })
    output$summary <- renderUI({
      selected_date1 <- paste(y(), "01", "01", "sep" = "-") %>% as.Date()
      selected_date2 <- paste(y(), "12", "31", "sep" = "-") %>% as.Date()

      row <- df %>%
        filter(order_date >= selected_date1) %>%
        filter(order_date <= selected_date2)

      metric_total_value <- sum(row[, metric()$id])
      
      invert_colors <- consts$metrics_list[[metric()$id]]$invert_colors

      selected_date1 <- 
        paste(previous_time_range(), "01", "01", "sep" = "-") %>% as.Date()
      selected_date2 <- 
        paste(previous_time_range(), "12", "31", "sep" = "-") %>% as.Date()

      row <- df %>%
        filter(order_date >= selected_date1) %>%
        filter(order_date <= selected_date2)

      metric_change_span <- (100 - round(sum(row[, metric()$id]) / metric_total_value * 100, digits = 2)) %>% 
        getPercentChangeSpan(invert_colors)
      
      valuePrefix <-
        ifelse(!is.null(metric()$currency),
          paste0(metric()$currency, " "),
          ""
        )

      # SVG graphics selected from SVG sprite map based on specified id
      glue::glue('
        <svg class="icon">
          <use href="assets/icons/icons-sprite-map.svg#{input$summary_metric}"></use>
        </svg>
        <span class="metric">{valuePrefix}{metric_total_value}</span>
        {metric_change_span}
      ') %>% HTML()
    })
  }