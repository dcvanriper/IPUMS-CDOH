## -------------------------------------------------------
#
# educational_inequity_proc.R
#
# Process the edu attainment data, compute inequailty ratios
# for each county-year combination, and create an output CSV file.
#
## -------------------------------------------------------

source(here::here("measures", "fun", "nhgis_funs.R"))

## ---- Establish location of current script ----
here::i_am("measures/racism-county-educational-inequity/R/racism_county_educational_inequity_proc.R")

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
    meta[[i]]$variables <<- edu_modify_nhgis_code(meta[[i]]$variables, meta[[i]]$universe)
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
  select(GISJOIN, YEAR, STATEA, STATE, COUNTYA, COUNTY, black_total:hispanic_female_bachelors_degree_or_higher)

# 2. Compute the educational inequality ratios
df <- df |> 
  mutate(edu_wanh = white_male_bachelors_degree_or_higher + white_female_bachelors_degree_or_higher,
         edu_ba = black_male_bachelors_degree_or_higher + black_female_bachelors_degree_or_higher,
         edu_h = hispanic_male_bachelors_degree_or_higher + hispanic_female_bachelors_degree_or_higher,
         edu_aa = asian_male_bachelors_degree_or_higher + asian_female_bachelors_degree_or_higher,
         
         edu_prop_wanh = edu_wanh / white_total,
         edu_prop_ba = edu_ba / black_total,
         edu_prop_h = edu_h / hispanic_total,
         edu_prop_aa = edu_aa / asian_total,
         
         edu_ratio_wanh_ba = edu_prop_wanh / edu_prop_ba,
         edu_ratio_wanh_h = edu_prop_wanh / edu_prop_h,
         edu_ratio_wanh_aa = edu_prop_wanh / edu_prop_aa
  ) |> 
  select(year = YEAR, statefips = STATEA, state = STATE, countyfips = COUNTYA, county = COUNTY, edu_ratio_wanh_ba:edu_ratio_wanh_aa)

## We observe counties with EDU_RATIO values equal to NaN or Inf. The NaN values are counties with a total count in the 
## denominator of zero and numerator >0 (ie there are no Asians in a county but there are White non-Hispanics, making   
## edu_ratio_wanh_aa = NaN).
## The Inf values result when the denominator prop = 0, meaning the denominator group has 0 individuals with a bachelor's
## degree or higher, but has a total count >0. 
## 
## Replace both the NaN's and Inf's with NA's for Proportions and Ratios

df  <- df %>% 
  mutate(edu_ratio_wanh_ba = ifelse(is.finite(edu_ratio_wanh_ba), edu_ratio_wanh_ba, NA),
         edu_ratio_wanh_h = ifelse(is.finite(edu_ratio_wanh_h), edu_ratio_wanh_h, NA),
         edu_ratio_wanh_aa = ifelse(is.finite(edu_ratio_wanh_aa), edu_ratio_wanh_aa, NA)) 

## ---- Write out the data frame to CSV  ---- 
df |> 
  write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
