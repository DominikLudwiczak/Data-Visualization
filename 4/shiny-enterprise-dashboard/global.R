# Load all R packages
library(shiny)
library(modules)
library(dplyr)
library(tidyr)
library(lubridate)
library(dygraphs)
library(sass)
library(glue)
library(ggplot2)
library(RColorBrewer)
library(xts)
library(echarts4r)
library(htmltools)
library(readxl)
library(janitor)
library(plotly)

# Function compiling sass files to one css file
sass(
  sass_file("styles/main.scss"),
  output = "www/main.css",
  options = sass_options(output_style = "compressed"),
  cache = NULL
)

# Constants
consts <- use("constants.R")

# Modules
metric_summary <- use("modules/metric_summary.R")
pie_chart <- use("modules/pie_chart.R")
map_chart <- use("modules/map_chart.R")
# time_chart <- use("./modules/time_chart.R")
# breakdown_chart <- use("./modules/breakdown_chart.R")