import("shiny")
import("DT")
import("plotly")
import("modules")
import("stats")
import("utils")
import("shinydashboard")
import("dplyr")
import("echarts4r")
import("shiny")
import("htmlwidgets")
import("ggplot2")
import("stringr")

export("ui")
export("init_server")

ui <- function(id) {
  ns <- NS(id)

  tagList(
    div(
      class = "panel-header breakdown-header",
      div(class = "item", "U.S. Map with States"),
    ),
    div(
      class = "chart-container",
      plotlyOutput(ns("us_map"))
    )
  )
}

init_server <- function(id, state) {
  callModule(server, id, state)
}

server <- function(input, output, session, state) {
  output$us_map <- renderPlotly({
    us <- map_data("state")
    p <- ggplot(us, aes(x = long, y = lat, group = region, key = region, text = region, fill = region == tolower(state()))) + 
      geom_polygon(color = "white") +
      scale_fill_manual(values = c("TRUE" = "#005073", "FALSE" = "#71c7ec"), guide = "none") +
      theme_void() +
      coord_fixed(1.3) + 
      theme(
        legend.position = "none",
        axis.line = element_blank(),
        axis.ticks = element_blank())
    ggplotly(p, tooltip = "text")
  })

  # Event handler for clicking on a point
  observeEvent(event_data("plotly_click"), {
    selected = str_to_title(event_data("plotly_click")$key[[1]])
    if(selected == state()) {
      state("All")
    } else {
      state(selected)
    }
  })
}