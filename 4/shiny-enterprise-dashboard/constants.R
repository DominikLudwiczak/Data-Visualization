# common variables for generating sample data and shiny app (ui & server)
import("dplyr")
import("htmltools")

app_title <- "Enterprise Dashboard"

metrics_list <- list(
  sales = list(
    id = "sales",
    title = "Sales Revenue",
    currency = "$",
    category = "sales",
    legend = "Revenue",
    invert_colors = TRUE
  ),
  profit = list(
    id = "profit",
    title = "Profit",
    currency = "$",
    category = "profit",
    legend = "Profit",
    invert_colors = TRUE
  )
)

map_metrics <- c(
  "revenue"
)

PPLogo <- HTML("
  <svg class='logo-svg' viewBox='0 0 453.543 74.366'>
    <use href='assets/icons/PP_logotyp_ANG_CMYK.svg#Warstwa_1'></use>
  </svg>
")

colors <- list(
  white = "#FFF",
  black = "#0a1e2b",
  primary = "#0099F9",
  secondary = "#15354A",
  ash = "#B3B8BA",
  ash_light = "#e3e7e9"
)