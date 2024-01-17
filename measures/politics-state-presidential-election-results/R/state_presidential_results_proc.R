## -------------------------------------------------------
#
# state_presidential_results_proc.R
#
# Process the state-level presidential results from 1976 to
# 2020. 
#
## -------------------------------------------------------

## ---- Establish location of current script ----
here::i_am("measures/politics-state-presidential-election-results/R/state_presidential_results_proc.R")

## ---- Load libraries ---- 
require(tidyverse)
require(glue)

## ---- Set topic for the dataset ----
topic <- "politics-state-presidential-election-results"

## ---- Import state fips code ----
state_fips = read_csv(here("measures", "reference_datasets", "state_fips.csv"))

## ---- Load the data ----
df <- read_csv(here("measures", topic, "data", "input", "1976-2020-president.csv"))

## ---- Clean up the data frame ----
df <- df |> 
  rename(party = party_simplified, votes = candidatevotes) |> 
  filter(party %in% c("DEMOCRAT", "REPUBLICAN")) 

## ---- Sum data by year, state, and party to eliminate "write-ins" records ----
df_collapse <- df |> 
  group_by(year, state_po, party) |> 
  summarise(votes = sum(votes), 
            totalvotes = min(totalvotes)) |> 
  ungroup()

## ---- Compute vote proportions by party ----
df_collapse <- df_collapse |> 
  mutate(prop = votes / totalvotes)

## ---- Create a data frame with one row per year-state combination ----
df_wide <- df_collapse |> 
  select(year, state_po, party, prop) |> 
  pivot_wider(id_cols = c("year", "state_po"), names_from = party, values_from = prop) |> 
  rename(prop_dem_st = DEMOCRAT,
         prop_gop_st = REPUBLICAN)

## ---- Join state_fips data to add standard state identifiers to each row ----
df_wide <- df_wide |> 
  left_join(state_fips, by = c("state_po" = "postal")) |> 
  select(year, statefips, state, prop_dem_st, prop_gop_st, -state_po)

## ---- Write out data frames to CSV ----------
df_wide |> 
  write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
