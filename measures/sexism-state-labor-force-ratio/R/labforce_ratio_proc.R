## -------------------------------------------------------
#
# labforce_ratio_proc.R
#
# Process the male and female labor force participation rate of full-time
# wage and salary workers to compute the 1) labor force ratio between
# males and females for each year from 2015 to 2021 by state
#
## -------------------------------------------------------

## ---- Establish location of current script ----
here::i_am("measures/sexism-state-labor-force-ratio/R/labforce_ratio_proc.R")

## ---- Load libraries ---- 
require(tidyverse)
require(readxl)
require(glue)

## ---- Set topic for the dataset ----
topic <- "sexism-state-labor-force-ratio"

## ---- Load data and compute ratios ----

# Import state fips code
state_fips = read_csv(here::here("measures", "reference_datasets", "state_fips.csv"))

# Generate a list of the spreadsheets in the input directory
file_list <- list.files(path = here::here("measures", topic, "data", "input"), pattern = "xls")

# Function to read in each data file, compute ratio and return output
read_compute_ratios <- function(file_name){
  year = as.numeric(str_extract(file_name, pattern = "(\\d)+"))
  
  if(year != 2018){
    x <- read_xlsx(here::here("measures", topic, "data", "input", file_name), 
                   sheet = "Table 3", 
                   col_names = c("state", "num_workers", "median_earnings", "se_median_earnings","female_workers", "female_median_earnings", "se_female_median_earnings",
                                 "male_workers", "male_median_earnings", "se_male_median_earnings", "women_earnings_perc_males"), 
                   skip = 6,
                   n_max = 52) |> 
      mutate(year = as.numeric(str_extract(file_name, pattern = "(\\d)+")),
             male_labforce_fraction = male_workers / num_workers,
             female_labforce_fraction = female_workers / num_workers,
             ratio_lab_force = male_labforce_fraction / female_labforce_fraction) |> 
      select(year, state, ratio_lab_force)
  }else{
    x <- read_xlsx(here::here("measures", topic, "data", "input", file_name), 
                   sheet = "Table 3", 
                   col_names = c("state", "num_workers", "median_earnings", "se_median_earnings","female_workers", "female_median_earnings", "se_female_median_earnings",
                                 "male_workers", "male_median_earnings", "se_male_median_earnings", "women_earnings_perc_males"), 
                   skip = 7,
                   n_max = 52) |> 
      mutate(year = as.numeric(str_extract(file_name, pattern = "(\\d)+")),
             male_labforce_fraction = male_workers / num_workers,
             female_labforce_fraction = female_workers / num_workers,
             ratio_lab_force = male_labforce_fraction / female_labforce_fraction) |> 
      select(year, state, ratio_lab_force)
  }
  
  return(x)
}

# Map over files in file_list
df_list <- map(file_list, ~read_compute_ratios(.x))

# Bind data frames in df_list into one data frame
df <- bind_rows(df_list) 

# Join state fips codes on df and sort in correct order
df <- df |> 
  left_join(state_fips, by = "state") |> 
  select(year, statefips, state, ratio_lab_force, -postal) |> 
  arrange(year, statefips)

## ---- Write out data frames to CSV ----------
if(!dir.exists(here::here("measures", topic, "data", "output"))){
  dir.create(here::here("measures", topic, "data", "output"))
  
  df |> 
    write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
} else{
  df |> 
    write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
}
