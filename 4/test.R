library(dplyr)
library(ggplot2)
library(lubridate)
library("readxl")
library("janitor")

df <- read_excel("Sample - Superstore.xls")
df <- clean_names(df)

ui <- fluidPage(
  plotlyOutput("myPlot")
)

# Define server
server <- function(input, output) {
  
  # Create the plot
  output$myPlot <- renderPlotly({
    us <- map_data("state")
    p <- ggplot(us, aes(x = long, y = lat, group = region, key = region, text = region)) + 
      geom_polygon(aes(fill = "#71c7ec"), color = "white") +
      scale_fill_manual(values = "#71c7ec", guide = "none") +
      theme_void() +
      ggtitle('U.S. Map with States') +
      coord_fixed(1.3) + 
      theme(legend.position = "none")
    ggplotly(p, tooltip = "text")
  })
  
  # Event handler for clicking on a point
  observeEvent(event_data("plotly_click"), {
    #print(event_data("plotly_click")$key)
    print(paste("Clicked State:", event_data("plotly_click")$key[[1]]))
  })
}

# Run the Shiny app
shinyApp(ui, server)
