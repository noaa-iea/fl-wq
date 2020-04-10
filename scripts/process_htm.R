# functions:
# - process_htm(): convert htm file into data (*.csv) and metadat (*.yml)
# - process_date()
# flow:
# - process all htm files into csv files
# - process all dates by directories containing csv files
#   - for each csv, apply filters before combining into single date csv
# 

# load libraries ----
if (!require(librarian)) install.packages("librarian"); library(librarian)
shelf(
  fs, here, glue, units,
  tibble, readr, dplyr, tidyr, purrr, stringr,
  yaml, rvest,
  sf, raster)
select = dplyr::select

# set variables ----
dir_data  <- here("data/Raw Data")

# define functions ----
process_htm <- function(htm, csv, yml, redo = F){
  
  # skip if already exists
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

process_csv <- function(csv, redo = F){
  # csv = "/Users/bbest/github/watermon-app/data/Test Data/2020-01-24/VuSitu_2020-01-24_15-05-14_Device Location_LiveReadings.csv"
  # csv = "/Users/bbest/github/watermon-app/data/Raw Data - No Lon or Lat/2020-01-31/VuSitu_2020-01-31_13-13-07_Device Location_LiveReadings.csv"
  # csv = "/Users/bbest/github/watermon-app/data/Raw Data/2020-02-04/VuSitu_2020-02-04_16-22-59_Device Location_LiveReadings.csv"
  message(glue("process_csv csv: {csv}"))
  
  flds_req <- c("Date Time", "Depth (ft)", "Longitude (°)", "Latitude (°)", "Temperature (°C)", "Oxygen Partial Pressure (Torr)")
  
  d <- read_csv(csv)
  flds_miss <- setdiff(flds_req, names(d))
  if (length(flds_miss) > 0) stop(glue("\n\nMissing fields in csv: {paste(flds_miss, collapse=', ')}\nsv: {csv}\n\n"))
  
  d <- d %>%
    # TODO: check which temp to use based on sensor id (stripped out by process_htm)? 
    #   Warning message: Duplicated column names deduplicated: 'Temperature (°C)' => 'Temperature (°C)_1'
    rename(
      dtime       = "Date Time",
      depth_ft    = "Depth (ft)",
      lon_dd      = "Longitude (°)", 
      lat_dd      = "Latitude (°)",
      temp_c      = "Temperature (°C)",
      oxygen_torr = "Oxygen Partial Pressure (Torr)")

  # average lon & lat, before filtering
  lon_avg <- mean(d$lon_dd, na.rm = T)
  lat_avg <- mean(d$lat_dd, na.rm = T)
  
  # order by time
  d <- d %>% 
    arrange(dtime)
  
  # filter for downcast (not up)
  row_end <- which.max(d$depth_ft)
  d <- d[1:row_end,]

  # filter out surface entries (< 5 m), except row immediately before
  idx_lt5ft <- which(d$depth_ft < 5)
  if (length(idx_lt5ft) > 0){
    row_beg <- max(idx_lt5ft) - 1
    d <- d[row_beg:nrow(d),]
  }
  
  # average lon & lat, after filtering
  if (all(is.na(d$lon_dd) | is.na(d$lat_dd))){
    d$lon_dd <- lon_avg
    d$lat_dd <- lat_avg
  } else {
    d <- d %>% 
      mutate(
        lon_dd = mean(lon_dd, na.rm = T),
        lat_dd = mean(lat_dd, na.rm = T))
  }
  
  d
}

process_bathy <- function(date_csv, redo = F){
  # source: [US Coastal Relief Model - Floria and Eastern Gulf of Mexico](https://www.ngdc.noaa.gov/mgg/coastal/grddas03/grddas03.htm)

  # date_csv = "/Users/bbest/github/watermon-app/data/Test Data/processed_2020-01-24.csv"
  # date_csv = "/Users/bbest/github/watermon-app/data/Raw Data/processed_2020-01-24.csv"
  # date_csv = "/Users/bbest/github/watermon-app/data/Raw Data/2020-01-31.csv"
  
  message(glue("process_bathy date_csv: {date_csv}"))
  
  dir_bathy <- here("data/bathy")
  bathy_nc  <- glue("{dir_bathy}/fl_east_gom_crm_v1.nc")
  
  if (!file.exists(bathy_nc)){
    # source: [Bathymetric Data Viewer](https://maps.ngdc.noaa.gov/viewers/bathymetry/)
    #   Digital Elevation Model: Florida and East Gulf of Mexico (3 arc-second)
    bathy_url <- "https://www.ngdc.noaa.gov/mgg/coastal/crm/data/netcdf/fl_east_gom_crm_v1.nc.gz"
    bathy_gz  <- glue("{dir_bathy}/fl_east_gom_crm_v1.nc.gz")
    download.file(bathy_url, bathy_gz)
    unzip(bathy_gz, bathy_nc)
    unlink(bathy_gz)
  }
  
  r_bathy <- raster(bathy_nc)
  
  d <- read_csv(date_csv)
  
  pts <- d %>%
    group_by(csv, lon_dd, lat_dd) %>% 
    summarize(nrows = n()) %>% 
    ungroup() %>% 
    st_as_sf(
      coords = c("lon_dd", "lat_dd"), crs = 4326, remove = F)
  
  # OLD: bathymetry
  # get bounding box
  # bb <- pts %>% 
  #   st_buffer(0.1) %>% 
  #   st_bbox()
  # 
  # cache bathymetry given bounding box (using a hash)
  # bathy_tif <- glue("{dir_data}/bathy_{digest(bb)}.tif")
  # if (!file.exists(bathy_tif)){
  #   r_bathy <- getNOAA.bathy(bb$xmin, bb$xmax, bb$ymin, bb$ymax, resolution = 1) %>% 
  #     as.raster()
  #   writeRaster(r_bathy, bathy_tif)  
  # } else {
  #   r_bathy <- raster(bathy_tif)
  # }
  
  # extract bottom depth
  pts$bdepth_ft <- raster::extract(
    r_bathy, 
    pts %>% as("Spatial")) * -1 %>% 
    set_units(m) %>% 
    set_units(ft) %>% 
    as.vector()

  d <- d %>% 
    # drop bdepth_ft column if exists
    select(!contains("bdepth_ft")) %>% 
    left_join(
      pts %>% 
        select(csv, bdepth_ft) %>% 
        st_drop_geometry(),
      by = "csv") %>% 
    # increase bdepth_ft to max depth_ft
    group_by(csv) %>% 
    mutate(
      bdepth_ft = if_else(
        max(depth_ft) > max(bdepth_ft),
        max(depth_ft),
        max(bdepth_ft)))
  # d %>% 
  #   select(csv, dtime, lon_dd, lat_dd, depth_ft, bdepth_ft) %>% 
  #   View()
  
  write_csv(d, date_csv)
}

process_date <- function(dir, redo = F){
  # dir = "/Users/bbest/github/watermon-app/data/Test Data/2020-01-24"
  # dir = date_dirs[1]
  # dir = "/Users/bbest/github/watermon-app/data/Raw Data/2020-01-24"
  # dir = "/Users/bbest/github/watermon-app/data/Raw Data/2020-01-31"

  message(glue("process_date dir: {dir}"))
  
  date_csv <- glue("{dir_data}/processed_{basename(dir)}.csv")
  
  csvs <- list.files(dir, ".*csv$", recursive = T, full.names = T)
  
  d <- map_df(setNames(csvs, basename(csvs)), process_csv, .id = "csv")
  #names(d)
  
  write_csv(d, date_csv)
  
  process_bathy(date_csv)
  # TODO: process depth
}

# unzip files ---
zip_files <- tibble(
  zip     = list.files(dir_data, ".*zip$", full.names = T, recursive = T),
  dir     = dirname(zip),
  zip_dir = map_chr(zip, path_ext_remove),
  htm     = map_chr(zip, path_ext_set, "htm")) %>% 
  filter(
    !file_exists(htm),
    !dir_exists(zip_dir))

# unzip individual files ending in LiveReadings.zip
zip_files %>% 
  filter(!str_detect(zip, "LiveReadings.zip$")) %>% 
  select(zipfile = zip, exdir = dir) %>% 
  pwalk(unzip)

# unzip everything else presumed a directory
zip_files %>% 
  filter(!str_detect(zip, "LiveReadings.zip$")) %>% 
  select(zipfile = zip, exdir = zip_dir) %>% 
  pwalk(unzip)

# get htm files ----
htm_files <- tibble(
  htm = list.files(dir_data, ".*htm$", full.names = T, recursive = T),
  csv = map_chr(htm, path_ext_set, "csv"),
  yml = map_chr(htm, path_ext_set, "yml"))

# process htm files ----
pwalk(htm_files, process_htm, redo = T)

# get dates ----
date_dirs <- list.dirs(dir_data, recursive = F) %>% 
    str_subset(".*/[0-9]{4}-[0-9]{2}-[0-9]{2}$")

# process date directories ----
walk(date_dirs, process_date, redo = T)

