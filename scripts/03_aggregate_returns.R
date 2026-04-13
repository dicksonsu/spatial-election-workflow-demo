# 03_aggregate_returns.R
# Purpose: Aggregate precinct-level election returns to the ZIP/ZCTA level
# Author: Dickson Su
# Project: spatial-election-workflow-demo

# -----------------------------
# 1. Load packages
# -----------------------------
library(dplyr)
library(readr)

# -----------------------------
# 2. Define paths
# -----------------------------
data_dir <- "data"
derived_dir <- file.path(data_dir, "derived")

# -----------------------------
# 3. Load linked precinct-to-ZIP table
# -----------------------------
precinct_zip_table <- read.csv(
  file.path(derived_dir, "precinct_zip_table.csv"),
  stringsAsFactors = FALSE
)

# -----------------------------
# 4. Inspect available columns
# -----------------------------
message("Available columns:")
print(names(precinct_zip_table))

# -----------------------------
# 5. Select key variables
# -----------------------------
# Adjust these names if your sample precinct data uses different field names.
# For this demo, we assume:
# - ZCTA5CE10 = ZIP/ZCTA identifier
# - STATEFP10 = state FIPS code
# - pred = Democratic presidential votes
# - prer = Republican presidential votes

precinct_returns <- precinct_zip_table %>%
  select(ZCTA5CE10, STATEFP10, G20PREDBID, G20PRERTRU) %>%
  rename(
    pred = G20PREDBID,
    prer = G20PRERTRU
  )

# -----------------------------
# 6. Clean variable types
# -----------------------------
precinct_returns <- precinct_returns %>%
  mutate(
    ZCTA5CE10 = as.character(ZCTA5CE10),
    STATEFP10 = as.character(STATEFP10),
    pred = as.numeric(pred),
    prer = as.numeric(prer)
  )

# -----------------------------
# 7. Drop unmatched ZIPs
# -----------------------------
precinct_returns <- precinct_returns %>%
  filter(!is.na(ZCTA5CE10))

message("Rows after dropping unmatched ZIPs:")
print(nrow(precinct_returns))

# -----------------------------
# 8. Aggregate precinct returns to ZIP level
# -----------------------------
zipcode_returns <- precinct_returns %>%
  group_by(STATEFP10, ZCTA5CE10) %>%
  summarise(
    pred = sum(pred, na.rm = TRUE),
    prer = sum(prer, na.rm = TRUE),
    total_two_party = pred + prer,
    dem_share = ifelse(total_two_party > 0, pred / total_two_party, NA_real_),
    .groups = "drop"
  )

message("Summary of Democratic vote share:")
print(summary(zipcode_returns$dem_share))

# -----------------------------
# 9. Basic validation checks
# -----------------------------
message("Number of ZIP-level rows:")
print(nrow(zipcode_returns))

message("Total Democratic votes in aggregated file:")
print(sum(zipcode_returns$pred, na.rm = TRUE))

message("Total Republican votes in aggregated file:")
print(sum(zipcode_returns$prer, na.rm = TRUE))

# -----------------------------
# 10. Save outputs
# -----------------------------
write.csv(
  zipcode_returns,
  file.path(derived_dir, "zipcode_returns.csv"),
  row.names = FALSE
)

message("Saved ZIP-level aggregated returns to data/derived/zipcode_returns.csv")
