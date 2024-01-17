## -------------------------------------------------------
#
# county_same_sex_households_proc.R
#
# Process the race data, compute dissimilarity values
# for each county-year combination, and create an output CSV file.
#
## -------------------------------------------------------

source(here::here("measures", "fun", "nhgis_funs.R"))

## ---- Establish location of current script ----
here::i_am("measures/cisheterosexism-county-same-sex-households/R/county_same_sex_households_proc.R")

## ---- Load libraries ---- 
library(tidyverse)
library(ipumsr)

## ---- Get metadata information for the tables and datasets ----
# 1. Function to get the income data table metadata
# Get the NHGIS metadata for PCT15 in 2020_DHCb dataset 
meta <- get_metadata_nhgis(
  dataset = ds,
  data_table = tables
)

# 2. Update all descriptions and nhgis_codes in meta$variables table
meta$variables <- lgbtqhh_modify_nhgis_code(meta$variables)

## ---- Read in data files from NHGIS extract ----
df <- read_nhgis(here::here("measures", topic, "data", "input", glue::glue("nhgis{downloadable_extract$number}_csv.zip")))

## ---- Update the column headers in each data frame in the df_list ----
# 1. Create recode_keys
column_list <- meta$variables

recode_key <- set_names(c(column_list$description), c(column_list$nhgis_code))

# 2. Apply the recode_key to each dataframe in the df_list
df <- df |> 
  rename_with(~recode(colnames(df), !!!recode_key))

## ---- Compute the LGBTQ household measures for each county-year combination ----
# 1. Select the required fields
df <- df |> 
  select(GISJOIN, YEAR, STATEA, STATE, COUNTYA, COUNTY, total:all_other_households)

# 2. Compute the LGBTQ proportions 
df <- df |> 
  mutate( tot_ss_unions = married_couple_household_same_sex_married_couple_household + unmarried_partner_household_same_sex_unmarried_partner_households,
          tot_unions = married_couple_household + unmarried_partner_household,
          
          prop_same_sex_unions = tot_ss_unions / tot_unions,
          prop_same_sex_married_all_marriages = married_couple_household_same_sex_married_couple_household / married_couple_household,
          prop_same_sex_married_all_same_sex_unions = married_couple_household_same_sex_married_couple_household / tot_ss_unions,
          prop_same_sex_households = tot_ss_unions / total, 
          
        ) |> 
  select(year = YEAR, statefips = STATEA, state = STATE, countyfips = COUNTYA, county = COUNTY, prop_same_sex_unions:prop_same_sex_households)

# We observe counties with prop_* values equal to NaN. The NaN values are counties with a numerator and denominator equal to zero.
#  
# Replace both the NaN's  with NA's for Proportions

df <- df |> 
  mutate(prop_same_sex_unions = ifelse(is.finite(prop_same_sex_unions), prop_same_sex_unions, NA),
         prop_same_sex_households = ifelse(is.finite(prop_same_sex_households), prop_same_sex_households, NA),
         prop_same_sex_married_all_same_sex_unions = ifelse(is.finite(prop_same_sex_married_all_same_sex_unions), prop_same_sex_married_all_same_sex_unions, NA),
         prop_same_sex_married_all_marriages = ifelse(is.finite(prop_same_sex_married_all_marriages), prop_same_sex_married_all_marriages, NA)) 

## ---- Write out data frame to a CSV ----
df |> 
  write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')