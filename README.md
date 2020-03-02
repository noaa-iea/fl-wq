# watermon-app
Florida Commercial Watermen's Conservation (FCWC) citizen science water quality monitoring application

## process

- drop at least 3 casts (csv ea)
- only want downward casts, not return or noise in beginning

## next steps

1. Avg lon/lat per csv (drop into yml), profile along multiple csv's.
1. Download [US Coastal Relief Model - Floria and Eastern Gulf of Mexico](https://www.ngdc.noaa.gov/mgg/coastal/grddas03/grddas03.htm) for given area and just use that.
1. Enable [shiny with flexdashboard](https://rmarkdown.rstudio.com/flexdashboard/shiny.html)
1. Plot all tracks and allow user to select bounding box and date slider? similar to [Crosstalk](https://rstudio.github.io/crosstalk/)
1. ...

- Connect with Joe Bishop wrt standardized data.

## questions

1. Which SN for Temperature?
1. Where to maintain long-term? Want on NOAA site. Where to host Shiny server?
