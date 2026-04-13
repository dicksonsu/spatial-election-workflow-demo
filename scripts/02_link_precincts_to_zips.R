# 02_link_precincts_to_zips.R
# Purpose: Convert precinct polygons to centroids and spatially join them to ZCTAs
# Author: Dickson Su
# Project: spatial-election-workflow-demo

# -----------------------------
# 1. Load packages
# -----------------------------
library(sf)
library(dplyr)

# -----------------------------
# 2. Define paths
# -----------------------------
data_dir <- "data"
derived_dir <- file.path(data_dir, "derived")

# -----------------------------
# 3. Load cleaned spatial objects
# -----------------------------
precincts <- readRDS(file.path(derived_dir, "precincts_clean.rds"))
zctas <- readRDS(file.path(derived_dir, "zctas_clean.rds"))

# -----------------------------
# 4. Convert precinct polygons to centroids
# -----------------------------
# This creates a point representation of each precinct
# for linking it to a ZIP/ZCTA geography.

precinct_points <- st_centroid(precincts)

# -----------------------------
# 5. Spatially join precinct points to ZCTAs
# -----------------------------
# Each precinct point is assigned the ZCTA polygon it falls within.

precinct_zip_linked <- st_join(
  precinct_points,
  zctas,
  left = TRUE
)

# -----------------------------
# 6. Basic checks
# -----------------------------
message("Number of precinct points:")
print(nrow(precinct_zip_linked))

message("Number of precincts matched to a ZCTA:")
print(sum(!is.na(precinct_zip_linked$ZCTA5CE10)))

message("Number of precincts not matched to a ZCTA:")
print(sum(is.na(precinct_zip_linked$ZCTA5CE10)))

# -----------------------------
# 7. Drop geometry for downstream analysis
# -----------------------------
precinct_zip_table <- precinct_zip_linked %>%
  st_drop_geometry()

# -----------------------------
# 8. Save outputs
# -----------------------------
saveRDS(
  precinct_zip_linked,
  file.path(derived_dir, "precinct_zip_linked_sf.rds")
)

write.csv(
  precinct_zip_table,
  file.path(derived_dir, "precinct_zip_table.csv"),
  row.names = FALSE
)

message("Saved linked spatial object and non-spatial table to data/derived/")
