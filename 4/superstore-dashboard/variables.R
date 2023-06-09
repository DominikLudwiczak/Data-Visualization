import("readxl")
import("janitor")

daily_stats <- read_excel("data/superstore.xls")
daily_stats <- clean_names(daily_stats)

data_first_day <- as.Date(min(daily_stats$order_date))
data_last_day <- as.Date(max(daily_stats$order_date))