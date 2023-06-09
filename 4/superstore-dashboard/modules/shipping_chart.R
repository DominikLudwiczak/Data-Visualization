# Ggplot horizontal bar chart module

import("shiny")
import("tidyselect")
import("lubridate")
import("dplyr")
import("utils")
import("tidyr")
import("ggplot2")
import("forcats")

export("ui")
export("init_server")

expose("utilities/getMetricsChoices.R")
expose("utilities/getTimeFilterChoices.R")
expose("utilities/getDataByTimeRange.R")
expose("utilities/getPercentChangeSpan.R")

consts <- use("constants.R")

ui <- function(id) {
  ns <- NS(id)

  tagList(
    div(
      class = "panel-header breakdown-header",
      div(class = "item", "Distribution of shipping methods"),
    ),
    div(
      class = "chart-container",
      plotOutput(ns("ship_mode"), width = "100%", height = "200px")
    )
  )
}

init_server <- function(id, df, y, state) {
  callModule(server, id, df, y, state)
}

server <- function(input, output, session, df, y, state) {
  
  output$ship_mode <- renderPlot({
    if(state() != "All") {
      df <- df %>%
        filter(state == state())
    }

    df_bar <- df %>%
      filter(year(order_date) == y()) %>%
      group_by(ship_mode) %>%
      summarise(cnt = n()) %>%
      mutate(ship_mode = fct_reorder(ship_mode, cnt))
  
    bar <- ggplot(df_bar, aes(x = ship_mode,  y = cnt))
    bar +
      geom_bar(
        fill = "#005073",
        show.legend = FALSE,
        width = 0.3,
        stat="identity"
      ) +
      scale_y_continuous(expand = c(0.1, 0.5)) +
      labs(x = NULL, y = NULL) +
      theme_classic(
        base_size = 18
      ) +
      theme(
        axis.text.y = element_text(color = "#6E757B"),
        axis.line = element_blank(),
        axis.ticks = element_blank()
      )
  })
}