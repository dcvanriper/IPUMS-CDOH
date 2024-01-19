## -------------------------------------------------------
#
# sexism_state_poverty_ratio_proc.R
#
# Process the poverty data by sex and state, and
# create an output CSV file.
#
## -------------------------------------------------------

## ---- Establish location of current script ----
here::i_am("measures/sexism-state-poverty-ratio/R/sexism_state_poverty_ratio_proc.R")

## ---- Load libraries ---- 
library(tidyverse)
library(ipumsr)
library(srvyr)

## ---- Import state fips code ----
state_fips = read_csv(here("measures", "reference_datasets", "state_fips.csv"))

## ---- Create a numeric version of statefip in the state_fips df to facilitate joining to CPS data ----
state_fips <- state_fips |> 
  mutate(STATEFIP = as.numeric(statefips))

## ---- Load in the CPS extract ----
pov <- read_ipums_micro(ddi = here::here("measures", topic, "data", "input", glue::glue("cps_000{downloadable_extract$number}", ".xml"))) 

## ---- Recode POVERTY variable into a binary (below poverty and above poverty) ----
## pov_recode == 1 is below poverty
## pov_recode == 0 is above poverty
## pov_record == NA is NIU (not in universe) for poverty research (starts in 2020)
pov <- pov |> 
  mutate(pov_recode = case_when(POVERTY == 10 ~ 1,
                                POVERTY > 10 ~ 0,
                                TRUE ~ NA))

## ---- Create a survey object from the pov data frame using srvyr's as_survey() function ----
svy <- as_survey(pov, weights = ASECWT)

## ---- Calculate weighted counts by year, state, poverty, and sex ----
state_sex_poverty <- svy |> 
  group_by(YEAR, STATEFIP,  SEX, pov_recode) |> 
  survey_tally() |> 
  ungroup()

## ---- Restructure state_sex_poverty data frame to calculate sex-specific poverty ratios by year and state ----
## There are some counts in the NA category for poverty. I'm not including them in the sex-specific poverty
## ratio.
state_sex_poverty_wide <- state_sex_poverty |> 
  select(-n_se) |> 
  pivot_wider(names_from = c("SEX", "pov_recode"), names_prefix = "pov_", values_from = "n") |> 
  mutate(pov_ratio_male = pov_1_1 / (pov_1_0 + pov_1_1),
         pov_ratio_female = pov_2_1 / (pov_2_0 + pov_2_1),
         ratio_weighted_poverty = pov_ratio_female / pov_ratio_male) 

## ---- Join the state names to the dataset ----
state_sex_poverty_wide <- state_sex_poverty_wide |> 
  left_join(state_fips, by = "STATEFIP")

## ---- Create final data frame and write out to CSV ----
state_sex_poverty_wide |> 
  select(year = YEAR, statefips, state, ratio_weighted_poverty) |> 
  write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')

## ---- Write out data frames to CSV ----------
if(!dir.exists(here::here("measures", topic, "data", "output"))){
  dir.create(here::here("measures", topic, "data", "output"))
  
  state_sex_poverty_wide |> 
    select(year = YEAR, statefips, state, ratio_weighted_poverty) |> 
    write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
} else{
  state_sex_poverty_wide |> 
    select(year = YEAR, statefips, state, ratio_weighted_poverty) |> 
    write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
}
