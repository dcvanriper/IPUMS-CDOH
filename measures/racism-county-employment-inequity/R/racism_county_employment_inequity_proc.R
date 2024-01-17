## -------------------------------------------------------
#
# racism_county_employment_inequity_proc.R
#
# Process the employment  data, compute inequality ratios
# for each county-year combination, and create an output CSV file.
#
## -------------------------------------------------------

source(here::here("measures", "fun", "nhgis_funs.R"))

## ---- Establish location of current script ----
here::i_am("measures/racism-county-employment-inequity/R/racism_county_employment_inequity_proc.R")

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
    meta[[i]]$variables <<- emp_modify_nhgis_code(meta[[i]]$variables, meta[[i]]$universe)
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
# 1. Select the required fields
df <- df |> 
  select(GISJOIN, YEAR, STATEA, STATE, COUNTYA, COUNTY, black_total:hispanic_female_65_years_and_over_not_in_labor_force)

# 2. Compute the employment ratios
df <- df |> 
  mutate( tot_wanh = white_male_16_to_64_years_in_labor_force_civilian + white_female_16_to_64_years_in_labor_force_civilian,
          tot_ba = black_male_16_to_64_years_in_labor_force_civilian + black_female_16_to_64_years_in_labor_force_civilian,
          tot_h = hispanic_male_16_to_64_years_in_labor_force_civilian + hispanic_female_16_to_64_years_in_labor_force_civilian,
          tot_aa = asian_male_16_to_64_years_in_labor_force_civilian + asian_female_16_to_64_years_in_labor_force_civilian,
          
          emp_wanh = white_male_16_to_64_years_in_labor_force_civilian_employed + white_female_65_years_and_over_in_labor_force_employed,
          emp_ba = black_male_16_to_64_years_in_labor_force_civilian_employed + black_female_65_years_and_over_in_labor_force_employed, 
          emp_h = hispanic_male_16_to_64_years_in_labor_force_civilian_employed + hispanic_female_65_years_and_over_in_labor_force_employed,
          emp_aa = asian_male_16_to_64_years_in_labor_force_civilian_employed + asian_female_65_years_and_over_in_labor_force_employed,
          
          emp_prop_wanh = emp_wanh / tot_wanh,
          emp_prop_ba = emp_ba / tot_ba, 
          emp_prop_h = emp_h / tot_h,
          emp_prop_aa = emp_aa / tot_aa,
          
          emp_ratio_wanh_ba = emp_prop_wanh / emp_prop_ba,
          emp_ratio_wanh_h = emp_prop_wanh / emp_prop_h,
          emp_ratio_wanh_aa = emp_prop_wanh / emp_prop_aa) |> 
  select(year = YEAR, statefips = STATEA, state = STATE, countyfips = COUNTYA, county = COUNTY, emp_ratio_wanh_ba:emp_ratio_wanh_aa)

# We observe counties with emp_ratio values equal to NaN or Inf. The NaN values are counties with a total count in the 
# denominator of zero and numerator >0 (ie there are no Asians in a county but there are White non-Hispanics, making   
# emp_ratio_wanh_aa = NaN).
# The Inf values result when the denominator prop = 0, meaning the denominator group has 0 individuals 16-64 who are employed
# but has a total count >0. 
#  
# Replace both the NaN's and Inf's with NA's for Proportions and Ratios

df <- df |> 
  mutate(emp_ratio_wanh_ba = ifelse(is.finite(emp_ratio_wanh_ba), emp_ratio_wanh_ba, NA),
         emp_ratio_wanh_h = ifelse(is.finite(emp_ratio_wanh_h), emp_ratio_wanh_h, NA),
         emp_ratio_wanh_aa = ifelse(is.finite(emp_ratio_wanh_aa), emp_ratio_wanh_aa, NA)) 

## ---- Write out the data frame to CSV  ---- 
df |> 
  write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
