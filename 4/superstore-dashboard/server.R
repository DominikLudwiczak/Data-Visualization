# Load variables
variables <- use("variables.R")

daily_stats <- variables$daily_stats

server <- function(input, output, session) {  
  selected_year <- reactive({ input$selected_year })
  previous_time_range <- reactive({ input$previous_time_range })
  state <- reactiveVal()
  state("All")

  # Inititalize all modules
  metric_summary$init_server("sales",
                             df = daily_stats,
                             y = selected_year,
                             previous_time_range = previous_time_range,
                             state = state)
  metric_summary$init_server("profit",
                             df = daily_stats,
                             y = selected_year,
                             previous_time_range = previous_time_range,
                             state = state)
  metric_summary$init_server("counts",
                             df = daily_stats,
                             y = selected_year,
                             previous_time_range = previous_time_range,
                             state = state)
  pie_chart$init_server("pie_chart",
                        df = daily_stats,
                        y = selected_year,
                        state = state)
  breakdown_chart$init_server("breakdown_chart",
                              df = daily_stats,
                              y = selected_year,
                              state = state)
  shipping_chart$init_server("shipping_chart",
                              df = daily_stats,
                              y = selected_year,
                              state = state)
  map_chart$init_server("map_chart", state = state)
  datatable$init_server("datatable",
                              df = daily_stats,
                              y = selected_year,
                              state = state)
}