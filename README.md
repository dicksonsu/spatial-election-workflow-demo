# Spatial Election Workflow Demo

This repository demonstrates a reproducible R workflow for linking precinct-level election geographies to ZIP Code Tabulation Areas (ZCTAs) and aggregating vote returns for downstream analysis.

## Project overview

In dissertation research on electoral geography, I worked with precinct shapefiles and administrative data to analyze how voting patterns varied across local geographies. This repository provides a simplified public-facing version of that workflow.

## What this repo demonstrates

- loading and cleaning spatial data in R with `sf`
- working with ZCTA geographies via `tigris`
- converting precinct polygons to centroids for spatial joining
- linking precinct-level election returns to ZIP-level geographies
- aggregating vote totals
- validating outputs against external benchmarks

## Repository structure

- `scripts/01_load_geographies.R` loads sample spatial data and harmonizes projections
- `scripts/02_link_precincts_to_zips.R` converts precinct polygons to centroid points and spatially joins them to ZIP Code Tabulation Areas (ZCTAs), creating a precinct-to-ZIP crosswalk for downstream aggregation.
- `scripts/03_aggregate_returns.R` aggregates precinct-level returns to the ZIP level
- `scripts/04_validate_outputs.R` compares ZIP-derived results to external benchmarks

## Note on data

This repository is a reconstructed and simplified example based on dissertation workflow. Some original data sources are not included here, so sample or public data are used in their place.

## Tools used

R, sf, dplyr, tidyr, tigris
