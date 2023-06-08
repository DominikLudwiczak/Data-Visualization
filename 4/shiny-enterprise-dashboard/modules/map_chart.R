import("shiny")
import("htmlwidgets")
import("dplyr")
import("ggplot2")
# import("plotly")

export("ui")
export("init_server")

expose("utilities/getMetricsChoices.R")
expose("utilities/getTimeFilterChoices.R")
expose("utilities/getDataByTimeRange.R")
expose("utilities/getPercentChangeSpan.R")

consts <- use("constants.R")

ui <- function(id) {
  ns <- NS(id)

  # select only those metrics that are available per country
  choices <- getMetricsChoices(consts$map_metrics, consts$metrics_list, suffix = "by country")

  tagList(
    tags$div(
      class = "panel-header",
      selectInput(
        ns("metric"), "",
        choices,
        width = NULL,
        selectize = TRUE,
        selected = consts$map_metrics[1]
      )
    ),
    # plotlyOutput("us_map")
  )
}

init_server <- function(id, df, y) {
  callModule(server, id, df, y)
}

server <- function(input, output, session, df, y) {
  metric <- reactive({ consts$metrics_list[[input$metric]] })

  # Create the plot
  # output$us_map <- renderPlotly({
  #   us <- map_data("state")
  #   p <- ggplot(us, aes(x = long, y = lat, group = region, key = region, text = region)) + 
  #     geom_polygon(aes(fill = "#71c7ec"), color = "white") +
  #     scale_fill_manual(values = "#71c7ec", guide = "none") +
  #     theme_void() +
  #     ggtitle('U.S. Map with States') +
  #     coord_fixed(1.3) + 
  #     theme(legend.position = "none")
  #   ggplotly(p, tooltip = "text")
  # })
  
  # # Event handler for clicking on a point
  # observeEvent(event_data("plotly_click"), {
  #   #print(event_data("plotly_click")$key)
  #   print(paste("Clicked State:", event_data("plotly_click")$key[[1]]))
  # })
}