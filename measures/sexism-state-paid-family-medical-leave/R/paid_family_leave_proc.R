## -------------------------------------------------------
#
# paid_family_leave_proc.R
#
# Process the paid family leave data for each state- effective year 
# combination and create an output CSV file.
#
## -------------------------------------------------------

## ---- Establish location of current script ----
here::i_am("measures/sexism-state-paid-family-medical-leave/R/paid_family_leave_proc.R")

## ---- Load libraries ---- 
library(tidyverse)
library(here)

## ---- Set topic for the dataset ----
topic <- "sexism-state-paid-family-medical-leave"

## ---- Load the input data ----"
df <- read_csv(here("measures", topic, "data", "input", "state-fml-effective-year.csv"))

## ---- Identify the earliest and latest years in the state-fml-effective-year dataset ----
first_year <- min(df$effective_fml, na.rm = TRUE)
latest_year <- max(df$effective_fml, na.rm = TRUE)

## ---- Create an expanded data frame with a state-year combination from first_year to latest_year ----
state_years <- df |> 
  group_by(state, statefips) |> 
  expand(year = first_year:latest_year)

## ---- Subset the df for only states with effective FML laws ----
## Expand data frame to include one record for each year a state has an 
## effective FML policy in place.
df_effective <- df |> 
  filter(!is.na(effective_fml)) |> 
  mutate(end_year = latest_year) |> 
  group_by(state, statefips) |> 
  expand(effective_fml = effective_fml:end_year) |> 
  mutate(indicator_paid_fam_leave = 1) |> 
  ungroup()

## ---- Join the original dataset onto the epxanded data frame ----
state_years <- state_years |> 
  left_join(df_effective, by = c("state" = "state", "statefips" = "statefips", "year" = "effective_fml"))

## ---- Replace NAs in state_years with zeroes so it's a true binary variable ----
state_years <- state_years |> 
  mutate(indicator_paid_fam_leave = replace_na(indicator_paid_fam_leave, 0)) |> 
  select(year, statefips, state, indicator_paid_fam_leave)

## ---- Write out data frames to CSV ----------
if(!dir.exists(here::here("measures", topic, "data", "output"))){
  dir.create(here::here("measures", topic, "data", "output"))
  
  state_years |> 
    write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
} else{
  state_years |> 
    write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
}
