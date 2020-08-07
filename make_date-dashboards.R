# load libraries
if (!require(librarian)) install.packages("librarian"); library(librarian)
shelf(rmarkdown, purrr, glue, here, fs)

#source("scripts/process_htm.R")
dir_data  <- here("data/Raw Data")
date_dirs <- get_date_dirs(dir_data)

# dates = c("2020-01-24", "2020-02-04") # example
dates = get_processed_dates(dir_data)

make_date <- function(date){
  # date = "2020-02-04" # "2020-01-24"
  out_html <- path(
    here("docs"),
    ifelse(
      date == max(dates), 
      "index",
      glue("date_{date}")) %>% 
      path_ext_set("html"))
  
  rmarkdown::render(
    input       = "date_template.Rmd",
    params      = list(
      dates         = dates,
      date_selected = date),
    output_file = out_html)
}

walk(dates, make_date)
