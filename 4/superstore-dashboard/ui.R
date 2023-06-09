# Load utility functions
source("utilities/getTimeFilterChoices.R")
source("utilities/getMetricsChoices.R")
source("utilities/getExternalLink.R")

# Load constant variables
consts <- use("constants.R")
# Load variables
variables <- use("variables.R")

years = getYearChoices(variables$data_first_day, variables$data_last_day)

# Html template used to render UI
htmlTemplate(
  "www/index.html",
  appTitle = consts$app_title,
  mainLogo = getExternalLink("assets/icons/egg.mp4", "main", consts$PPLogo),
  selectYear = selectInput(
    "selected_year", "Year",
    choices = years,
    selected = years[1],
    selectize = TRUE
  ),
  previousTimeRange = selectInput(
    "previous_time_range", "Compare to",
    choices = years,
    selected = years[2],
    selectize = TRUE
  ),
  salesSummary = metric_summary$ui("sales"),
  profitSummary = metric_summary$ui("profit"),
  countsSummary = metric_summary$ui("counts"),
  pieChart = pie_chart$ui("pie_chart"),
  breakdownChart = breakdown_chart$ui("breakdown_chart"),
  shippingChart = shipping_chart$ui("shipping_chart"),
  countryMap = map_chart$ui("map_chart"),
  datatable = datatable$ui("datatable")
)
