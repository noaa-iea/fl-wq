# watermon-app
Florida Commercial Watermen's Conservation (FCWC) citizen science water quality monitoring application

## process

- drop at least 3 casts (csv ea)
- only want downward casts, not return or noise in beginning

## next steps

1. reorganize data to go from wide to long:

    - data.csv: datetime | value | variable | units | sensor_sn | sensor_model
    - by default pull from `sensor_model == "Aqua TROLL 600 Vented"`

1. which temperature? want in water "Aqua TROLL 600 Vented" vs air temp from "In-Situ Bluetooth Device"

    - Instrument Properties
      Device Model = Aqua TROLL 600 Vented
      Device SN = 676038
    - Instrument Properties
      Device Model = In-Situ Bluetooth Device 
      Device SN = 674484

1. oxygen_mgL = RDO Concentration (mg/L)
1. Enable [shiny with flexdashboard](https://rmarkdown.rstudio.com/flexdashboard/shiny.html)
1. 3 panes: 1) map, 2) 2 vars. 3) 2 more vars per `9-1-19_Venice.jpg`
1. Add Dropdown to select date
1. Host on iea-demo.us, while exploring other long-term hosting options.
1. Allow user login.
1. Operationalize processing of data:
    - setup cron to run every 5 min to check for new data in googledrive, fetch and process
    - Use [googledrive](https://googledrive.tidyverse.org/) with a service account token (see [drive_auth() • googledrive](https://googledrive.tidyverse.org/reference/drive_auth.html))
    - When encountering any errors, send email with error log to user list using [blastula](https://github.com/rich-iannone/blastula) for html-formatted emails; or even possibility of sending text messages via email through mobile phone provider: "Thanks for the data, but we're missing lon/lat. Can you help us tracking down these locations?"
    - Alternatively, the user could submit an email with attachment, then this cron job script processes the email attachments, adds to google drive, runs QA/QC and processes the file, a la robolimpet thermal sensor fetch of email (https://marinebon.org/thermal-data).
1. Read rest of data from Google Drive (see below).
1. Update color ramps (see 9-1-19_Venice.jpg): 
  - Temp: blue-red
  - Oxygen: 
    decreasing white to black; 
    <= 2 mg/L
    red scale below
  - Salinity:
  - Chlorophyll: white to green
1. Plot all tracks and allow user to select bounding box and date slider? similar to [Crosstalk](https://rstudio.github.io/crosstalk/)
1. Smooth CTD cast along depth difference (ie dtime)
1. Update data live by [reading Google Drive](https://googledrive.tidyverse.org)
1. Iterate based on user feedback.
1. theme: [nik01010/dashboardthemes: BETA: custom theme support for R Shinydashboard applications.](https://github.com/nik01010/dashboardthemes)

Most common device to use (smartphone vs desktop)?

## protocol

See [VuSitu Operating Instruction.docx]()

## done

1. Avg lon/lat per csv (drop into yml), profile along multiple csv's.
1. Download [US Coastal Relief Model - Floria and Eastern Gulf of Mexico](https://www.ngdc.noaa.gov/mgg/coastal/grddas03/grddas03.htm) for given area and just use that.


## to explore

- Interpolation scheme?
  - [`PlotSvalbard::section_plot(interp_method = "mba")`](https://mikkovihtakari.github.io/PlotSvalbard/reference/section_plot.html)
  - "mba" for multilevel B-spline interpolation using the [mba.surf](https://www.rdocumentation.org/packages/MBA/versions/0.0-8/topics/mba.surf) function. Appears to produce the best looking results. Recommended.
  
## data

Here is the google drive link:
[FCWC](https://drive.google.com/drive/folders/1I9gg1DJnbPZR0NTxqAOfvrnYLRsebOGn?usp=sharing)

BB local: `/Volumes/GoogleDrive/My Drive/projects/iea-auto/regions/gm/fisher-monitoring/data/FCWC`

The folder labeled 'raw data' is the one you want. This is the historical data. 

Joe Bishop, the engineer working on this project and has setup the field units has another set of folders that the newly collected data go into. The following links are the newer data:

- [Fort Myers](https://drive.google.com/drive/folders/1-8BYZbWJqE8XlPXaQzhCwD5DXKUtoYOa?usp=sharing)
- [Matlacha 2](https://drive.google.com/drive/folders/1-H5J6ktivA0TfURfP4mbrtHQo4_sOG7-?usp=sharing)
- [Naples](https://drive.google.com/drive/folders/1-3oGgdSbKNZHIMlJklb3pVDBvu0TTDAH?usp=sharing)
- [BG (Matlacha)](https://drive.google.com/drive/folders/1-Al-wvKzerdF2O4fnzBq2pJu_ZcKSEXa?usp=sharing)
- [Venice](https://drive.google.com/drive/folders/1--PhfoQpfCoyzM9sdYlMdmtIghODrq1Z?usp=sharing)
- [Matlacha-2](https://drive.google.com/drive/folders/1--B18LYocy3g-PX6RK7pO4TWS7KhQzXn?usp=sharing)

### data processing

- [imaginaryfish/FCWC-data-processing](https://github.com/imaginaryfish/FCWC-data-processing) 

## questions

1. Which SN for Temperature?
1. Where to maintain long-term? Want on NOAA site. Where to host Shiny server?


## rmarkdown awesomeness

- [What is R Markdown? on Vimeo](https://vimeo.com/178485416)
- https://rstudio.com/resources/cheatsheets/
- [RStudio Webinars](https://resources.rstudio.com/webinars)
    - [The Essentials of Data Science](https://resources.rstudio.com/the-essentials-of-data-science)