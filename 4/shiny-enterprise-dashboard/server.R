# Load variables
variables <- use("variables.R")

daily_stats <- variables$daily_stats

server <- function(input, output, session) {  
  observeEvent(c(input$selected_month), {
    if (input$selected_month == "0") {
      updateSelectInput(
        session,
        "previous_time_range",
        choices = consts$prev_time_range_choices["Previous Year"],
        selected = consts$prev_time_range_choices[["Previous Year"]]
      )
    } else {
      updateSelectInput(
        session,
        "previous_time_range",
        choices = consts$prev_time_range_choices,
        selected = input$previous_time_range
      )
    }
  })

  selected_year <- reactive({ input$selected_year })
  previous_time_range <- reactive({ input$previous_time_range })

  # Inititalize all modules
  metric_summary$init_server("sales",
                             df = daily_stats,
                             y = selected_year,
                             previous_time_range = previous_time_range)
  metric_summary$init_server("profit",
                             df = daily_stats,
                             y = selected_year,
                             previous_time_range = previous_time_range)
  pie_chart$init_server("pie_chart",
                        df = daily_stats,
                        y = selected_year)
  # time_chart$init_server("time_chart",
  #                        df = daily_stats,
  #                        y = selected_year,
  #                        previous_time_range = previous_time_range)
  # breakdown_chart$init_server("breakdown_chart",
  #                             df = daily_stats,
  #                             y = selected_year,
  #                             previous_time_range = previous_time_range)
  map_chart$init_server("map_chart",
                        df = daily_stats,
                        y = selected_year)
}