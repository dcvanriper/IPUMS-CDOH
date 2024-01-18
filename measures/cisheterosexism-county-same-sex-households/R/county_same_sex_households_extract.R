## -------------------------------------------------------
#
# county_same_sex_households_extract.R
#
# Generate request and download data table for coupled households
# by type from the 2020 decennial census. 
#
## -------------------------------------------------------

## ---- Establish location of current script ----
here::i_am("measures/cisheterosexism-county-same-sex-households/R/county_same_sex_households_extract.R")

## ---- Load libraries ---- 
library(tidyverse)
library(ipumsr)

## ---- Create extract request inputs ----
topic <- "cisheterosexism-county-same-sex-households"

# Data tables
tables = c("PCT15")

# Geographic level
geolvl <- c("county")

# Dataset - the coupled households by type table is in the 2020_DHCa dataset in IPUMS NHGIS
ds <- "2020_DHCb"

## ---- Create data directories if they don't already exist ----
if(!dir.exists(here::here("measures", topic, "data"))){
  dir.create(here::here("measures", topic, "data"))
  dir.create(here::here("measures", topic, "data", "input"))
  dir.create(here::here("measures", topic, "data", "output"))
}

## ---- Create output data directory if it doesn't exist ---- 
if(!dir.exists(here::here("measures", topic, "data", "output"))){
  dir.create(here::here("measures", topic, "data", "output"))
}

## ---- Create NHGIS extract request ---- 
# 1. Create a dataset spec for the extract request
datasets <- ds_spec(
  name = ds,
  data_tables = tables,
  geog_levels = geolvl
)

# 2. Create an extract request that includes all 5-year datasets
extract <- define_extract_nhgis(
  description = "Coupled households by type from 2020 decennial census",
  datasets = datasets
)

# 3. Submit the extract to NHGIS
submitted_extract <- submit_extract(extract)

# 4. Wait for the extract to be finished
downloadable_extract <- wait_for_extract(submitted_extract)

# 5. Download it to a local folder in the topic directory
download_extract(downloadable_extract, here::here("measures", topic, "data", "input"))