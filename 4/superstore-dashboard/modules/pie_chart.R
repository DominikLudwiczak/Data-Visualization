# Dygraphs vertical bar chart module

import("shiny")
import("dygraphs")
import("glue")
import("tidyselect")
import("lubridate")
import("xts")
import("dplyr")
import("ggplot2")

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
      div(class = "item", "Sold products by category"),
    ),
    tags$div(
        class = "pie-chart-container",
        plotOutput(ns("chart"))
    )
  )
}

init_server <- function(id, df, y, state) {
    callModule(server, id, df, y, state)
}

server <- function(input, output, session, df, y, state) {
    output$chart <- renderPlot({
        if(state() != "All") {
          df <- df %>%
            filter(state == state())
        }

        df_pie <- df %>%
            filter(year(order_date) == y()) %>%
            group_by(category) %>%
            summarise(count = n()) %>%
            mutate(percentage = count/sum(count) * 100)

        ggplot(df_pie, aes(x="", y=count, fill=category)) + 
            geom_col(width=1) + 
            coord_polar(theta = "y") +
            theme_void() +
            geom_text(aes(label = paste0(round(percentage), "%")), 
                        position = position_stack(vjust = 0.5),
                        color = "white",
                        size = 6) +
            scale_fill_manual(values = c("#005073", "#189ad3", "#71c7ec")) +
            theme(
              legend.title = element_text(size=14),
              legend.text = element_text(size=12))
    })
}