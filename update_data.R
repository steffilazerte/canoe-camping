library(sf)
library(dplyr)
library(httr2)
library(fs)
library(tmap)
library(rnaturalearth)


# Burned historical
burned_url <- "https://cwfis.cfs.nrcan.gc.ca/downloads/nbac/NBAC_1972to2024_20250506_shp.zip"
burned_pth <- path("Data", path_file(burned_url))

if(!file.exists(burned_pth)) {
  # Burned historical metadata
  request("https://cwfis.cfs.nrcan.gc.ca/downloads/nbac/NBAC_1972to2024_20250506_shp_metadata.pdf") |>
    req_perform(path = burned_pth)

  request(burned_url) |>
    req_perform(path = burned_pth)

  unzip(burned_pth, exdir = "Data")
}

# Hotspots - Perimeter

perimiters_url <- paste0("https://cwfis.cfs.nrcan.gc.ca/downloads/hotspots/perimeters.",
                         c("dbf", "prj", "shp", "shx"))
perimiters_pth <- path("Data",  path_file(perimiters_url))

purrr::map2(
  perimiters_url, perimiters_pth, \(x, y) request(x) |>
    req_perform(path = y)
)


# Hotspots - Points
hot_url <- "https://cwfis.cfs.nrcan.gc.ca/downloads/hotspots/hotspots.csv"
hot_pth <- path("Data", path_file(hot_url))
request(hot_url) |>
  req_perform(path = hot_pth)
