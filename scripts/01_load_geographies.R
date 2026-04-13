# 01_load_geographies.R
# Purpose: Load and prepare sample precinct and ZIP/ZCTA geographies
# Author: Dickson Su
# Project: spatial-election-workflow-demo

# -----------------------------
# 1. Load packages
# -----------------------------
library(sf)
library(dplyr)
library(tigris)

# Use local cache for TIGER files
options(tigris_use_cache = TRUE)

# -----------------------------
# 2. Define paths
# -----------------------------
data_dir <- "data"
raw_dir <- file.path(data_dir, "raw")
derived_dir <- file.path(data_dir, "derived")

if (!dir.exists(derived_dir)) {
  dir.create(derived_dir, recursive = TRUE)
}

# -----------------------------
# 3. Set parameters
# -----------------------------
state_abbr <- "PA"   # Change this if using a different state
target_crs <- 4269   # NAD83, common for Census geographies

# -----------------------------
# 4. Load sample precinct shapefile
# -----------------------------
# check to ensure the raw shapefile exists before reading
shp_path <- file.path(raw_dir, "pa_precincts_sample.shp")

if (!file.exists(shp_path)) {
  stop("Sample precinct shapefile not found in data/raw/")
}

precincts <- st_read(
  dsn = raw_dir,
  layer = "pa_2020",
  quiet = TRUE
)

# -----------------------------
# 5. Inspect and standardize precinct geometry
# -----------------------------
message("Original precinct CRS:")
print(st_crs(precincts))

# Transform to target CRS if needed
if (is.na(st_crs(precincts))) {
  stop("Precinct shapefile has no CRS defined. Define it before proceeding.")
}

precincts <- st_transform(precincts, target_crs)

# Make invalid geometries valid
precincts <- st_make_valid(precincts)

# -----------------------------
# 6. Load ZIP Code Tabulation Areas (ZCTAs)
# -----------------------------
zctas <- tigris::zctas(
  cb = FALSE,
  year = 2010,
  state = state_abbr
) %>%
  select(ZCTA5CE10, STATEFP10)

# Harmonize CRS
zctas <- st_transform(zctas, target_crs)

# -----------------------------
# 7. Basic checks
# -----------------------------
message("Prepared precinct CRS:")
print(st_crs(precincts))

message("Prepared ZCTA CRS:")
print(st_crs(zctas))

message("Number of precinct features:")
print(nrow(precincts))

message("Number of ZCTA features:")
print(nrow(zctas))

message("Precinct geometry types:")
print(unique(st_geometry_type(precincts)))

message("ZCTA geometry types:")
print(unique(st_geometry_type(zctas)))

# -----------------------------
# 8. Save cleaned spatial objects
# -----------------------------
saveRDS(precincts, file.path(derived_dir, "precincts_clean.rds"))
saveRDS(zctas, file.path(derived_dir, "zctas_clean.rds"))

message("Saved cleaned geographies to data/derived/")

