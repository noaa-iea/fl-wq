library(here)
library(tibble)
library(readr)
library(dplyr)
library(purrr)
library(fs)
library(stringr)
library(tidyr)
library(yaml)
library(rvest)

#library(webdriver)
#install.packages("wdman")
library(wdman)

dir_data <- here("data")

files <- tibble(
  htm = list.files(dir_data, ".*htm$", full.names = T),
  csv = map_chr(htm, path_ext_set, "csv"))
# View(files)

i = 1
htm <- files$htm[i]
csv <- files$csv[i]

html <- read_html(htm)
h <- html_nodes(html, "#isi-report")
for (i in 1:length(html_children(h))){
  ln <- 
}
lns <- map_chr(, html_text)
cat(lns)
html_text(c1)
length(tbl)

var rows = dataTable.rows;
for (var rowIndex=0; rowIndex < rows.length; rowIndex++) {
  var row = rows[rowIndex];
  var cells = row.cells;
  for (var cellIndex=0; cellIndex < cells.length; cellIndex ++) {
    var cell = cells[cellIndex];
    if (cell.previousElementSibling != null)
      csv += delimiter;
      
      csv += quote + sanitize(cell.innerText) + quote;
  }
  csv += newLine
}

rvest

# pjs <- run_phantomjs(debugLevel = "DEBUG")
# ses <- Session$new(port = pjs$port)
# 
# ses$go(htm)
# ses$getUrl()
# ses$executeScript("exportButton();")
# #search2 <- ses$executeScript("return document.getElementById('cran-input');")
# search2 <- ses$executeScript("return document.getElementById('cran-input');")
# 
# search2 <- ses$executeScript("Export a CSV")
# 
# file:///Users/bbest/github/fl-watermon-app/data/VuSitu_2020-01-24_15-05-14_Device%20Location_LiveReadings.htm#
# file:///Users/bbest/github/fl-watermon-app/data/VuSitu_2020-01-24_15-05-14_Device%20Location_LiveReadings.htm#


selServ <- selenium(verbose = TRUE)

# https://docs.ropensci.org/wdman/articles/basics.html
# https://github.com/rstudio/webdriver
# https://www.r-bloggers.com/scraping-dynamic-websites-with-phantomjs/
# https://www.datacamp.com/community/tutorials/scraping-javascript-generated-data-with-r
# https://blog.rstudio.com/2014/11/24/rvest-easy-web-scraping-with-r/


files <- tibble(
  csv = list.files(dir_data, ".*csv$", full.names = T),
  htm = map_chr(htm, path_ext_set, "htm"))

csv <- files$csv[1]


# get number of lines for metadata
n_m <- readLines(csv) %>% 
  str_which('^"Date Time.*') - 1

# get metadata
m <- tibble(
  ln = readLines(csv)[1:n_m] %>% 
    str_subset("=") %>% 
    str_replace_all('"', '')) %>% 
  separate(ln, c("key", "val"), sep = " = ")

# read data, after metadata
d <- read_csv(csv, skip = n_m)

# serial numbers in metadata
#   eg VuSitu_2020-01-24_15-05-14_Device Location_LiveReadings.csv:
#     Aqua TROLL 600 Vented, Device SN: 676038                  
#     In-Situ Bluetooth,     Device SN: 674484
#
# what are these extra serial numbers?
names(d) %>%
  str_subset(" \\([0-9]+\\)") %>% 
  str_replace("(.*)\\(([0-9]+)\\)(.*)", "\\2") %>% 
  table()
# 671053? 671693? 672340? 673392? 674484k 676038k 
#      2      2      3      6      2      4 

# remove extraneous serial numbers from field names
names(d) <- names(d) %>%
  str_replace(" \\([0-9]+\\)", "")

# View(problems(d))
