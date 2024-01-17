## -------------------------------------------------------
#
# county_presidential_results_proc.R
#
# Process the county-level presidential results from 1976 to
# 2020. 
#
## -------------------------------------------------------

## ---- Establish location of current script ----
here::i_am("measures/politics-county-presidential-election-results/R/county_presidential_results_proc.R")

## ---- Load libraries ---- 
require(tidyverse)
require(glue)

## ---- Set topic for the dataset ----
topic <- "politics-county-presidential-election-results"

## ---- Import state fips code ----
state_fips = read_csv(here("measures", "reference_datasets", "state_fips.csv"))

## ---- Load the data ----
df <- read_csv(here("measures", topic, "data", "input", "countypres_2000-2020.csv"))

## ---- Clean up the data frame ----
df <- df |> 
  rename(votes = candidatevotes) |> 
  filter(party %in% c("DEMOCRAT", "REPUBLICAN")) 

## ---- Sum data by year, state, and party to eliminate "write-ins" records ----
df_collapse <- df |> 
  group_by(year, state, county_name, county_fips, party) |> 
  summarise(votes = sum(votes), 
            totalvotes = min(totalvotes)) |> 
  ungroup()

## ---- Compute vote proportions by party ----
df_collapse <- df_collapse |> 
  mutate(prop = votes / totalvotes)

## ---- Create a data frame with one row per year-state combination ----
df_wide <- df_collapse |> 
  select(year, state, county_name, county_fips, party, prop) |> 
  pivot_wider(names_from = party, values_from = prop) |> 
  rename(prop_dem_cty = DEMOCRAT,
         prop_gop_cty = REPUBLICAN,
         county = county_name)

## ---- Split county_fips code into state FIPs and county FIPs for each row ----
df_wide <- df_wide |> 
  mutate(statefips = str_sub(county_fips, 1, 2),
         countyfips = str_sub(county_fips, 3, 5)) |> 
  select(year, statefips, state, countyfips, county, prop_dem_cty, prop_gop_cty, -county_fips)

## ---- Write out data frames to CSV ----------
df_wide |> 
  write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
