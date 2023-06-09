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

init_server <- function(id, df, y, previous_time_range, state) {
  callModule(server, id, df, y, previous_time_range, state)
}

server <- function(input, output, session, df, y, previous_time_range, state) {
    metric <- reactive({ consts$metrics_list[[input$summary_metric]] })
    output$summary <- renderUI({
      selected_date1 <- paste(y(), "01", "01", "sep" = "-") %>% as.Date()
      selected_date2 <- paste(y(), "12", "31", "sep" = "-") %>% as.Date()

      row <- df %>%
        filter(order_date >= selected_date1) %>%
        filter(order_date <= selected_date2)

      if(state() != "All") {
        row <- row %>%
          filter(state == state())
      }

      if(is.element(metric()$category, c("counts"))) {
        metric_total_value <- nrow(unique(row[, metric()$id]))
      } else {
        metric_total_value <- sum(row[, metric()$id])
      }
      
      invert_colors <- consts$metrics_list[[metric()$id]]$invert_colors

      selected_date1 <- 
        paste(previous_time_range(), "01", "01", "sep" = "-") %>% as.Date()
      selected_date2 <- 
        paste(previous_time_range(), "12", "31", "sep" = "-") %>% as.Date()

      row <- df %>%
        filter(order_date >= selected_date1) %>%
        filter(order_date <= selected_date2)

      if(state() != "All") {
        row <- row %>%
          filter(state == state())
      }

      if(is.element(metric()$category, c("counts"))) {
        comp_metric_total_values <- nrow(unique(row[, metric()$id]))
      } else {
        comp_metric_total_values <- sum(row[, metric()$id])
      }

      metric_change_span <- (round((metric_total_value - comp_metric_total_values) / abs(comp_metric_total_values) * 100, digits = 2)) %>% 
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
        <span class="metric">{valuePrefix}{round(metric_total_value, 2)}</span>
        {metric_change_span}
      ') %>% HTML()
    })
  }