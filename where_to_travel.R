source("update_data.R")

# Prepare/Filter -----------------------------------------
prov <- c("NS", "PE", "NB", "NL")
recent <- "2025-08-20"

burned <- st_read("Data/NBAC_1972to2024_20250506.shp") |>
  filter(ADMIN_AREA %in% prov,
         YEAR >= 2020) |>
  mutate(last = NA) |>
  select(year = YEAR, last) |>
  st_simplify(dTolerance = 100)

locs <- ne_states(country = "Canada") |>
  filter(postal %in% prov) |>
  st_transform(st_crs(burned)) |>
  st_buffer(10000)

hot <- readr::read_csv(hot_pth) |>
  filter(rep_date > recent) |>
  st_as_sf(coords = c("lon", "lat"), crs = 4326) |>
  st_transform(st_crs(locs)) |>
  st_crop(st_bbox(locs))

perimiters <- st_read("Data/perimeters.shp") |>
  st_crop(st_bbox(locs)) |>
  mutate(year = 2025) |>
  select(year, last_recorded = LASTDATE) |>
  st_simplify(dTolerance = 100)

# Map ------------------------------------------
tmap_mode("view")

map <- tm_basemap(c("Esri.WorldTopoMap", "OpenStreetMap")) +
  tm_shape(hot, name = "August hotspots") +
  tm_symbols(fill = "red", size = 0.75, hover = "rep_date", popup.vars = FALSE) +
  tm_shape(burned, name = "Historical fires") +
  tm_polygons(fill = "year", fill.legend = tm_legend(title = "Historical fires"),
              fill.scale = tm_scale_discrete(values = "viridis", label.format = \(x) format(x, big.mark = "")),
              hover = "year", popup.vars = FALSE, fill_alpha = 0.5) +
  tm_shape(perimiters, name = "2025 Fires") +
  tm_polygons(fill = "orange", hover = "year", popup.vars = "last_recorded", fill_alpha = 0.5) +
  tm_add_legend(type = "polygons", labels = "2025", fill = "orange") +
  tm_layout(legend.format=list(fun=function(x) formatC(x, digits=0, format="d")))

tmap_save(map, "fires_atlantic.html")

