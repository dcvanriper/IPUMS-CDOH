## -------------------------------------------------------
#
# racism_county_income_inequity_extract.R
#
# Generate request and download data tables for income by
# race for all ACS 5-year datasets. 
#
## -------------------------------------------------------

## ---- Establish location of current script ----
here::i_am("measures/racism-county-income-inequity/R/racism_county_income_inequity_extract.R")

## ---- Load libraries ---- 
library(tidyverse)
library(ipumsr)

## ---- Create extract request inputs ----
topic <- "racism-county-income-inequity"

# Data tables
tables <- c("B19001A", "B19001B", "B19001C", "B19001D", "B19001E", "B19001F", "B19001G", "B19001H", "B19001I")

# Geographic level
geolvl <- c("county")

## ---- Create data directories if they don't already exist ----
if(!dir.exists(here("measures", topic, "data"))){
  dir.create(here("measures", topic, "data"))
  dir.create(here("measures", topic, "data", "input"))
  dir.create(here("measures", topic, "data", "output"))
}

## ---- Create NHGIS extract request ---- 
# 1. Create a vector of ACS 5-year "b" dataset
nhgis_ds_vector <- get_metadata_nhgis(type = "datasets") |> 
  filter(str_detect(name, "ACS5b")) |> 
  pull(name)

# 2. Use purrr to create a dataset spec for all datasets in nhgis_ds_vector 
datasets <- purrr::map(
  nhgis_ds_vector,
  ~ ds_spec(
    name = .x,
    data_tables = tables,
    geog_levels = geolvl
  )
)

# 2. Create an extract request that includes all 5-year datasets
extract <- define_extract_nhgis(
  description = "Income inequity inputs, by county, for all ACS 5-year datasets",
  datasets = datasets
)

# 3. Submit the extract to NHGIS
submitted_extract <- submit_extract(extract)

# 4. Wait for the extract to be finished
downloadable_extract <- wait_for_extract(submitted_extract)

# 5. Download it to a local folder in the topic directory
download_extract(downloadable_extract, here::here("measures", topic, "data", "input"))

