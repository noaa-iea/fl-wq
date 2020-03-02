# load libraries
if (!require(librarian)) install.packages("librarian"); library(librarian)
shelf(
  fs, here, glue, 
  tibble, readr, dplyr, tidyr, purrr, stringr,
  yaml, rvest)

# set variables
dir_data <- here("data")

# define functions
process_htm <- function(htm, csv, yml, redo = F){
  
  # skip if already exists
  #browser()
  if (all(file.exists(csv, yml)) & !redo){
    message("Files csv & yml exist, so skipping:\n  ", basename(htm))
    return()
  }
  
  # read table from html
  D <- read_html(htm) %>% 
    html_table(fill = T) %>% 
    .[[1]]
  
  # get header row of data
  row_h <- which(D[,1] == "Date Time")
  
  # extract data
  d <- D[(row_h):nrow(D),]
  write_csv(d, csv, col_names = F, na = "", quote_escape = "none")
  d <- read_csv(csv)
  # update column namesremove extraneous serial numbers from headers
  names(d) <- names(d) %>% 
    str_replace(" \\([0-9]+\\)", "")
  write_csv(d, csv)
            
  # save metadata
  m <- tibble(
    txt = D[1:(row_h-1),1]) %>% 
    filter(str_detect(txt, "")) %>% 
    mutate(
      is_keyval = str_detect(txt, " = "),
      grp    = ifelse(!is_keyval, txt, NA),
      keyval    = ifelse(is_keyval, txt, NA),
      key       = ifelse(is_keyval, str_split(keyval, " = ", simplify=T)[,1], NA),
      val       = ifelse(is_keyval, str_split(keyval, " = ", simplify=T)[,2], NA),
      dat       = map2(key, val, function(k,v) setNames(list(v), k))) %>% 
    fill(grp) %>% 
    filter(!is.na(keyval)) %>% 
    select(grp, dat) %>% 
    group_by(grp) %>% 
    nest() 
  m_l <- m %>% as.list()
  map2(m_l$grp, m_l$data, function(g, d){
    setNames(list(unlist(d[['dat']]) %>% as.list()), g)
    }) %>% 
    write_yaml(yml)
}

# get files
files <- tibble(
  htm = list.files(dir_data, ".*htm$", full.names = T),
  csv = map_chr(htm, path_ext_set, "csv"),
  yml = map_chr(htm, path_ext_set, "yml"))

# process files
pwalk(files, process_htm)
