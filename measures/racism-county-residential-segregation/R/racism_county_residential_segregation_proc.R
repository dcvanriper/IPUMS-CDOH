## -------------------------------------------------------
#
# racism_county_residential_segregation_proc.R
#
# Process the race data, compute dissimilarity values
# for each county-year combination, and create an output CSV file.
#
## -------------------------------------------------------

source(here::here("measures", "fun", "nhgis_funs.R"))

## ---- Establish location of current script ----
here::i_am("measures/racism-county-residential-segregation/R/racism_county_residential_segregation_proc.R")

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
    meta[[i]]$variables <<- segd_modify_nhgis_code(meta[[i]]$variables, meta[[i]]$name)
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

## ---- Compute the educational inequality measures for each county-year combination ----
# 1. Select required fields for analysis
df <- df |> 
  select(GISJOIN, YEAR, STATEA, STATE, COUNTYA, COUNTY, TRACTA, B02001_white_alone, B02001_black_or_african_american_alone, B02001_asian_alone,
         B03002_not_hispanic_or_latino_white_alone, B03002_hispanic_or_latino)

# 2. Compute the county-year race count
df_cty <- df |> 
  group_by(YEAR, STATEA, COUNTYA, COUNTY) |> 
  summarize(cty_B02001_white_alone = sum(B02001_white_alone),
            cty_B02001_black_or_african_american_alone = sum(B02001_black_or_african_american_alone),
            cty_B02001_asian_alone = sum(B02001_asian_alone),
            cty_B03002_not_hispanic_or_latino_white_alone = sum(B03002_not_hispanic_or_latino_white_alone),
            cty_B03002_hispanic_or_latino = sum(B03002_hispanic_or_latino))

# 3. Join the county county to the tract counts
df <- df |> 
  left_join(df_cty)

# 4. Compute the index of dissimilarity values 
df <- df |> 
  mutate(d_ba = 0.5 * (abs((B02001_white_alone / cty_B02001_white_alone ) - (B02001_black_or_african_american_alone / cty_B02001_black_or_african_american_alone))),
         d_aa = 0.5 * (abs((B02001_white_alone / cty_B02001_white_alone ) - (B02001_asian_alone / cty_B02001_asian_alone))),
         d_h = 0.5 * (abs((B03002_not_hispanic_or_latino_white_alone / cty_B03002_not_hispanic_or_latino_white_alone ) - (B03002_hispanic_or_latino / cty_B03002_hispanic_or_latino))))

df_d <- df |> 
  group_by(YEAR, STATEA, STATE, COUNTYA, COUNTY) |> 
  summarise(d_wa_ba = sum(d_ba),
            d_wanh_h = sum(d_h), 
            d_wa_aa = sum(d_aa)) |> 
  select(year = YEAR, statefips = STATEA, state = STATE, countyfips = COUNTYA, county = COUNTY, d_wa_ba:d_wa_aa)

# 5. Replace NaNs with NAs
df_d <- df_d |> 
  mutate(d_wa_ba = ifelse(is.finite(d_wa_ba), d_wa_ba, NA),
         d_wanh_h = ifelse(is.finite(d_wanh_h), d_wanh_h, NA),
         d_wa_aa = ifelse(is.finite(d_wa_aa), d_wa_aa, NA))

## ---- Write out the data frame to CSV  ---- 
df_d |> 
  write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
