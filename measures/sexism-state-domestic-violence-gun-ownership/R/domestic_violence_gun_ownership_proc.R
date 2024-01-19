## -------------------------------------------------------
#
# domestic_violence_gun_ownership_proc.R
#
# Process the measure for domestic violence gun ownership laws
# 1991 - 2020 
# 
## -------------------------------------------------------

## ---- Establish location of current script ----
here::i_am("measures/sexism-state-domestic-violence-gun-ownership/R/domestic_violence_gun_ownership_proc.R")

## ---- Load libraries ---- 
require(tidyverse)
require(readxl)
require(glue)

## ---- Set topic for the dataset ----
topic <- "sexism-state-domestic-violence-gun-ownership"

## ---- Import state fips code ----
state_fips = read_csv(here::here("measures", "reference_datasets", "state_fips.csv"))

## ---- Load the data ----
df <- read_xlsx(here::here("measures", topic, "data", "input", "DATABASE_0.xlsx"))

## ---- Retain variables of interest ----
df <- df |> 
  select(year, state, mcdvdating:stalking)

## ---- Create indicator variable ----
# If a state-year combination has any law related to domestic violence and gun ownership,
# the state-year combination receives a 1 in the indicator variable. Otherwise, it
# receives a 0.

df <- df %>%
  mutate(total_laws = rowSums(across(mcdvdating:stalking), na.rm = T)) %>%
  mutate(indicator_dv = case_when(total_laws > 0 ~ 1,
                                  total_laws == 0 ~ 0))

## ---- Merge with state_fips data to add standard state identifiers ----
df <- df |> 
  left_join(state_fips, by = "state") |> 
  select(year, statefips, state, indicator_dv)

## ---- Write out data frames to CSV ----------
if(!dir.exists(here::here("measures", topic, "data", "output"))){
  dir.create(here::here("measures", topic, "data", "output"))
  
  df |> 
    write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
} else{
  df |> 
    write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
}
