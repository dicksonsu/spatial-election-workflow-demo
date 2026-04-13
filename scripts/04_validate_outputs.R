# 04_validate_outputs.R
# Purpose: Validate aggregated ZIP-level returns against external benchmark data
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
raw_dir <- file.path(data_dir, "raw")

# -----------------------------
# 3. Load aggregated ZIP-level returns
# -----------------------------
zipcode_returns <- read.csv(
  file.path(derived_dir, "zipcode_returns.csv"),
  stringsAsFactors = FALSE
)

# -----------------------------
# 4. Aggregate ZIP-level returns back to state level
# -----------------------------
state_validation <- zipcode_returns %>%
  group_by(STATEFP10) %>%
  summarise(
    pred = sum(pred, na.rm = TRUE),
    prer = sum(prer, na.rm = TRUE),
    total_two_party = pred + prer,
    dem_share_derived = ifelse(total_two_party > 0, pred / total_two_party, NA_real_),
    .groups = "drop"
  )

message("Derived state-level vote shares:")
print(state_validation)

# -----------------------------
# 5. Load benchmark state-level results
# -----------------------------
# Expected columns in benchmark file:
# - STATEFP10
# - dem_share_benchmark
#
# Example file location:
# data/raw/state_presidential_benchmark.csv

benchmark <- read.csv(
  file.path(raw_dir, "state_presidential_benchmark.csv"),
  stringsAsFactors = FALSE
)

# -----------------------------
# 6. Clean benchmark fields
# -----------------------------
benchmark <- benchmark %>%
  mutate(
    STATEFP10 = as.character(STATEFP10),
    dem_share_benchmark = as.numeric(dem_share_benchmark)
  )

# -----------------------------
# 7. Merge derived and benchmark results
# -----------------------------
validation_comparison <- state_validation %>%
  left_join(benchmark, by = "STATEFP10") %>%
  mutate(
    abs_diff = abs(dem_share_derived - dem_share_benchmark)
  )

message("Validation comparison:")
print(validation_comparison)

# -----------------------------
# 8. Compute summary validation metrics
# -----------------------------
validation_correlation <- cor(
  validation_comparison$dem_share_derived,
  validation_comparison$dem_share_benchmark,
  use = "complete.obs"
)

mean_abs_diff <- mean(validation_comparison$abs_diff, na.rm = TRUE)

message("Correlation between derived and benchmark Democratic vote share:")
print(round(validation_correlation, 6))

message("Mean absolute difference:")
print(round(mean_abs_diff, 6))

# -----------------------------
# 8b. Validation quality check
# -----------------------------
if (!is.na(validation_correlation) && validation_correlation < 0.99) {
  warning("Validation correlation is lower than expected. Review aggregation logic or benchmark alignment.")
}

if (!is.na(mean_abs_diff) && mean_abs_diff > 0.01) {
  warning("Mean absolute difference exceeds 0.01. Check whether derived vote shares align with benchmark definitions.")
}

# -----------------------------
# 9. Save validation outputs
# -----------------------------
write.csv(
  validation_comparison,
  file.path(derived_dir, "validation_comparison.csv"),
  row.names = FALSE
)

validation_summary <- data.frame(
  metric = c("correlation", "mean_absolute_difference"),
  value = c(validation_correlation, mean_abs_diff)
)

write.csv(
  validation_summary,
  file.path(derived_dir, "validation_summary.csv"),
  row.names = FALSE
)

message("Saved validation outputs to data/derived/")
