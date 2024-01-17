## -------------------------------------------------------
#
# racism_county_income_inequity_proc.R
#
# Process the income data, compute ICE values for each
# county-year combination, and create an output CSV file.
#
## -------------------------------------------------------

source(here::here("measures", "fun", "nhgis_funs.R"))

## ---- Establish location of current script ----
here::i_am("measures/racism-county-income-inequity/R/racism_county_income_inequity_proc.R")

## ---- Load libraries ---- 
library(tidyverse)
library(ipumsr)

## ---- Get metadata information for the tables and datasets ----
# 1. Create all possible combinations of nhgis_ds_vectors and income tables
nhgis_combos <- expand_grid(nhgis_ds_vector, tables)

# 2. Function to get the income data table metadata
# set the rate_delay for the slowly() function
rate = rate_delay(1)

# iterate over nhgis_combos to get NHGIS metadata, forcing a 1 second delay between API calls
meta <- purrr::map2(
  nhgis_combos$nhgis_ds_vector, 
  nhgis_combos$tables,
  slowly(~ get_metadata_nhgis(
    dataset = .x,
    data_table = .y
  ), rate = rate)
)

# 3. Update all descriptions and nhgis_codes in meta list
purrr::walk(
  seq_along(meta), # Iterate through integers from 1 to length of meta
  function(i) {
    meta[[i]]$variables <<- inc_modify_nhgis_code(meta[[i]]$variables, meta[[i]]$universe)
    meta[[i]]
  }
)

## ---- Read in data files from NHGIS extract ----
df_list <- map(nhgis_ds_vector, ~read_nhgis(here::here("measures", topic, "data", "input", glue::glue("nhgis{downloadable_extract$number}_csv.zip")), 
                                            file_select = contains(str_sub(.x, 5, 9))))

## ---- Update the column headers in each data frame in the df_list ----
# 1. Create a list of recode_keys (one list item per ACS 5-year dataset)
recode_key_list <- map(nhgis_ds_vector, ~create_recode_key(.x, meta))

# 2. Apply the recode_key to each dataframe in the df_list
df_list_recode <- map2(df_list, recode_key_list, ~ recode_nhgis_columns(.x, .y))

# 4. Covert the df_list to a data frame for further processing
df <- bind_rows(df_list_recode)

## ---- Compute the income inequality measures for each county-year combination ----
# 1. Select the required fields
df <- df |> 
  select(GISJOIN, YEAR, STATEA, COUNTYA, COUNTY, white_alone_total:hispanic_or_latino_200000_or_more)

# 2. Compute ICE values for each county - year combination for the three Race/Ethnicity groups of interest - 
# Black alone : White Alone Not Hispanic
# Hispanic : White Alone Not Hispanic
# Asian alone : White Alone Not Hispanic
df <- df |> 
  mutate(tot_hh = white_alone_total + black_or_african_american_alone_total + american_indian_and_alaska_native_alone_total + 
           asian_alone_total + native_hawaiian_and_other_pacific_islander_alone_total + some_other_race_alone_total + 
           two_or_more_races_total,
         
         highi = rowSums(across(white_alone_not_hispanic_or_latino_100000_to_124999:white_alone_not_hispanic_or_latino_200000_or_more)),
         lowi_ba = rowSums(across(black_or_african_american_alone_less_than_10000:black_or_african_american_alone_20000_to_24999)),
         ice_wanh_ba = (highi - lowi_ba) / tot_hh,
         
         lowi_h = rowSums(across(hispanic_or_latino_less_than_10000:hispanic_or_latino_20000_to_24999)),
         ice_wanh_h = (highi - lowi_h) / tot_hh,
         
         lowi_aa = rowSums(across(asian_alone_less_than_10000:asian_alone_20000_to_24999)),
         ice_wanh_aa = (highi - lowi_aa) / tot_hh,
  ) |> 
  select(year = YEAR, statefips = STATEA, state = STATE, countyfips = COUNTYA, county = COUNTY, ice_wanh_ba, ice_wanh_h, ice_wanh_aa)

## ---- Write out the data frame to CSV  ---- 
df |> 
  write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
