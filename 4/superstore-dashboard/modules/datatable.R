# Ggplot horizontal bar chart module

import("shiny")
import("tidyselect")
import("lubridate")
import("dplyr")
import("utils")
import("tidyr")
import("ggplot2")
import("DT")

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
      div(class = "item", "Datatable"),
    ),
    div(
      class = "chart-container",
      DTOutput(ns("datatable"))
    )
  )
}

init_server <- function(id, df, y, state) {
  callModule(server, id, df, y, state)
}

server <- function(input, output, session, df, y, state) {
  output$datatable <- DT::renderDT({
    if(state() != "All") {
      df <- df %>%
        filter(state == state())
    }

    data <- df %>%
      filter(year(order_date) == y())

    datatable(
      data,
      style="auto", 
      filter = "top",
      rownames = FALSE, 
      extensions = "Buttons", 
      options = list(dom = 'Bfrtip', buttons = c('copy', 'csv', 'excel', 'pdf', 'print'), scrollX = TRUE)) %>%
        formatRound(unlist(lapply(data, is.numeric)), 2)
  })
}