# watermon-app
Florida Commercial Watermen's Conservation (FCWC) citizen science water quality monitoring application

## process

- drop at least 3 casts (csv ea)
- only want downward casts, not return or noise in beginning

## next steps

- [x] Avg lon/lat per csv (drop into yml), profile along multiple csv's.
- [x] Download [US Coastal Relief Model - Floria and Eastern Gulf of Mexico](https://www.ngdc.noaa.gov/mgg/coastal/grddas03/grddas03.htm) for given area and just use that.

1. Enable [shiny with flexdashboard](https://rmarkdown.rstudio.com/flexdashboard/shiny.html)
1. Host on iea-demo.us, while exploring other long-term hosting options.
1. Read rest of data from Google Drive (see below).
1. Plot all tracks and allow user to select bounding box and date slider? similar to [Crosstalk](https://rstudio.github.io/crosstalk/)
1. Update data live.
1. Iterate based on user feedback.

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
