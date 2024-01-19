## -------------------------------------------------------
#
# sexism_state_abortion_access_proc.R
#
# Acquire Caitlin Myer's Abortion Access by County and Month
# data from Open Science Framework (OSF). The main URL
# for Myer's data is https://osf.io/pfxq3/
# 
## -------------------------------------------------------

## ---- Establish location of current script ----
here::i_am("measures/sexism-state-abortion-access/R/sexism_state_abortion_access_proc.R")

## ---- Load libraries ---- 
library(tidyverse)

## ---- Import state fips code ----
state_fips = read_csv(here::here("measures", "reference_datasets", "state_fips.csv")) 

## ---- Get path to abortion access data ----
file_name <- list.files(path = here::here("measures", topic, "data", "input"), pattern = "abortion")

## ---- Load abortion access data ----
df <- read_csv(here::here("measures", topic, "data", "input", file_name))

## ---- Update the origin_population values for Alaska and Hawaii ----
# The county-level abortion access data from Caitlin Myer's has no origin_population data for
# Alaska and Hawaii; therefore, we need to access county-level population estimates for those states
# and update the origin_population values.

## ---- Prepare the 2000-2009 population estimates ----
# Load data, specifying the record layout
# Alaska has a record with "X" in them, which converts all the pop estimates to characters from
# numeric values. 
ak_2009 <- read_csv(here::here("measures", topic, "data", "input", "ak_2000_2009.csv"), col_type = "cccccnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn") 
hi_2009 <- read_csv(here::here("measures", topic, "data", "input", "hi_2000_2009.csv"), col_type = "cccccnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn") 

# Change Wade-Hampton Census Area to Kusilvak Census Area name and origin_fips code
# because the Abortion Access dataset uses Kusilvak Census area for all its records.
# Wade-Hampton Census Area had it's name changed to Kusilvak on July 1, 2015, according
# to the US Census Bureau - https://www.census.gov/programs-surveys/geography/technical-documentation/county-changes.2010.html#list-tab-957819518
ak_2009 <- ak_2009 |> 
  mutate(CTYNAME = case_when(CTYNAME == "Wade Hampton Census Area" ~ "Kusilvak Census Area",
                             TRUE ~ CTYNAME),
         COUNTY = case_when(COUNTY == "270" ~ "158",
                            TRUE ~ COUNTY))

# Bind data frames
pop_2009 <- bind_rows(ak_2009, hi_2009)

# Select out the required year and variables
pop_2009 <- pop_2009 |> 
  filter(YEAR == 12) |> 
  mutate(year = 2009,
         origin_fips_code = paste0(STATE, COUNTY)) |> 
  select(year, origin_fips_code, AGE1544_FEM)

## ---- Prepare the 2010-2019 population estimates ----
# create col_type vector - 5 c and 75 n values to read in the 80 column wide CSV files
char_col_types_2010_2019 <- paste0(rep(c("c"), times = 5), collapse = "")
num_col_types_2010_2019 <- paste0(rep(c("n"), times = 55), collapse = "")
col_types_2010_2019 <- paste0(char_col_types_2010_2019, num_col_types_2010_2019)

# Load data, specifying the record layout
ak_2010_2019 <- read_csv(here::here("measures", topic, "data", "input", "ak_2010_2019.csv"), col_types = col_types_2010_2019)
hi_2010_2019 <- read_csv(here::here("measures", topic, "data", "input", "hi_2010_2019.csv"), col_types = col_types_2010_2019)

# Bind data frames 
pop_2010_2019 <- bind_rows(ak_2010_2019, hi_2010_2019)

# Select out the required years and variables
pop_2010_2019 <- pop_2010_2019 |> 
  filter(YEAR > 2) |> 
  mutate(year = case_when(YEAR == 3 ~ 2010,
                          YEAR == 4 ~ 2011,
                          YEAR == 5 ~ 2012,
                          YEAR == 6 ~ 2013,
                          YEAR == 7 ~ 2014,
                          YEAR == 8 ~ 2015,
                          YEAR == 9 ~ 2016,
                          YEAR == 10 ~ 2017,
                          YEAR == 11 ~ 2018,
                          YEAR == 12 ~ 2019),
         origin_fips_code = paste0(STATE, COUNTY)) |> 
  select(year, origin_fips_code, AGE1544_FEM)

## ---- Prepare the 2020-2022 population estimates ----
# create col_type vector - 5 c and 75 n values to read in the 80 column wide CSV files
# create col_type vector - 5 c and 75 n values to read in the 80 column wide CSV files
char_col_types_2020_2022 <- paste0(rep(c("c"), times = 5), collapse = "")
num_col_types_2020_2022 <- paste0(rep(c("n"), times = 91), collapse = "")
col_types_2020_2022 <- paste0(char_col_types_2020_2022, num_col_types_2020_2022)

# Load data, specifying the record layout
ak_2020_2022 <- read_csv(here::here("measures", topic, "data", "input", "ak_2020_2022.csv"), col_types = col_types_2020_2022)
hi_2020_2022 <- read_csv(here::here("measures", topic, "data", "input", "hi_2020_2022.csv"), col_types = col_types_2020_2022)

# Change Chugach Census Area and Copper River Census Area to Valdez-Cordova
# Census Area, and update their COUNTY codes to "261". Valdez-Cordova Census Area was
# subdivided into Chugach and Copper River in 2019. The Abortion Access dataset
# uses Valdez-Cordova for all of its measurements. Thus, I need to create a record
# for Valdez-Cordova to match with the Abortion dataset. 
# https://www.census.gov/programs-surveys/geography/technical-documentation/county-changes.2010.html#list-tab-957819518
ak_2020_2022 <- ak_2020_2022 |> 
  mutate(CTYNAME = case_when(CTYNAME %in% c("Chugach Census Area", "Copper River Census Area") ~ "Valdez-Cordova Census Area",
                             TRUE ~ CTYNAME),
         COUNTY = case_when(COUNTY %in% c("063", "066") ~ "261",
                            TRUE ~ COUNTY))

# Bind data frames 
pop_2020_2022 <- bind_rows(ak_2020_2022, hi_2020_2022)

# Select out the required years and variables
pop_2020_2022 <- pop_2020_2022 |> 
  filter(YEAR > 1) |> 
  mutate(year = case_when(YEAR == 2 ~ 2020,
                          YEAR == 3 ~ 2021,
                          YEAR == 4 ~ 2022),
         origin_fips_code = paste0(STATE, COUNTY)) |> 
  select(year, origin_fips_code, AGE1544_FEM)

# Collapse the data frame to create a new record for Valdez-Cordova Census Area
pop_2020_2022 <- pop_2020_2022 |> 
  group_by(year, origin_fips_code) |> 
  summarise(AGE1544_FEM = sum(AGE1544_FEM)) |> 
  ungroup()

## ---- Create a data frame of AK and HI county-level female age 15-44 from 2009-2022 ----
pop_2009_2022 <- bind_rows(list(pop_2009, pop_2010_2019, pop_2020_2022))


## ---- Creating a variable to identify whether there is an abortion provider in a county ----
df <- df %>%
  mutate(abortion_provider = case_when(origin_fips_code == dest_fips_code ~ 1,
                                       origin_fips_code != dest_fips_code ~ 0))

## ---- Removing observations with year = 2023 because all of them have missing values in origin_population ----
df <- df  |> 
  filter(year != 2023)

## ---- Update the origin_population values for Alaska and Hawaii in the abortion dataset ----
df <- df |> 
  left_join(pop_2009_2022, by = c("origin_fips_code", "year"))  |> 
  mutate(origin_population = case_when(!is.na(AGE1544_FEM) ~ AGE1544_FEM,
                                       TRUE ~ origin_population)) |> 
  select(-AGE1544_FEM)

## ---- Calculate the total popoulation of women ages 15-44 in a state-year combination ----
# I need to select out one year by origin_fips code first and then summarise by origin_state and
# year. There are multiple records per county in the dataset.  
df_state_year_fem1544_pop <- df |> 
  select(origin_fips_code, origin_state, year, origin_population) |> 
  group_by(origin_fips_code, year) |> 
  distinct() |> 
  group_by(origin_state, year) |> 
  summarise(state_fem1544_pop = sum(origin_population)) |> 
  ungroup()

## ---- Calculate the proportion of females, age 15-44, living in a county with a clinic by state, year, and month ----
df_final <- df |> 
  filter(abortion_provider == 1) |> 
  group_by(origin_state, year, month) |> 
  summarise(abortion_provider_population = sum(origin_population)) |> 
  left_join(df_state_year_fem1544_pop, by = c("origin_state", "year")) |> 
  mutate(prop_abortion = abortion_provider_population / state_fem1544_pop) |> 
  left_join(state_fips, by = c("origin_state" = "postal")) |> 
  ungroup() |> 
  select(year, month, statefips, prop_abortion)

## ---- Insert year-month-state combinations for states with abortion bans in place ----
# The Dobbs decision has resulted in states banning abortions; therefore, those states
# don't currently show up in the df_final data frame. They should be there and they 
# should have a prop_abortion value of zero. 
df_final_expanded <- df_final |> 
  expand(year, month, statefips) |> 
  left_join(df_final, by = c("year", "month", "statefips")) |> 
  mutate(prop_abortion = replace_na(prop_abortion, 0)) |> 
  left_join(state_fips, by = "statefips") |> 
  select(year, month, statefips, state, prop_abortion, -postal)

## ---- Write out data frames to CSV ----------
if(!dir.exists(here::here("measures", topic, "data", "output"))){
  dir.create(here::here("measures", topic, "data", "output"))
  
  df_final_expanded |> 
    write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
} else{
  df_final_expanded |> 
    write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
}
