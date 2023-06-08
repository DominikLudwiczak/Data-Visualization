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
  choices <- c("Test")

  tagList(
    tags$div(
        class="panel-metric",
        selectInput(
            ns("metric"), "",
            choices,
            width = NULL,
            selectize = TRUE,
            selected = choices[[1]]
        )
    ),
    tags$div(
        class = "pie-chart-container",
        plotOutput(ns("chart"))
    )
  )
}

init_server <- function(id, df, y) {
    callModule(server, id, df, y)
}

server <- function(input, output, session, df, y) {
    output$chart <- renderPlot({
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
                        size = 4) +
            scale_fill_manual(values = c("#005073", "#189ad3", "#71c7ec"))
    })
}