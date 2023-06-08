import("lubridate")

getYearChoices <- function(data_start_date, data_last_day) {
  c(year(data_last_day):year(data_start_date))
}