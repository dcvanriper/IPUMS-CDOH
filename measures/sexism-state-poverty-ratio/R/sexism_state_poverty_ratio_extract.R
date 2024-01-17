## -------------------------------------------------------
#
# sexism_state_poverty_ratio_extract.R
#
# Generate request and download IPUMS CPS extract so compute
# poverty ratios. 
# 
## -------------------------------------------------------

## ---- Establish location of current script ----
here::i_am("measures/sexism-state-poverty-ratio/R/sexism_state_poverty_ratio_extract.R")

## ---- Load libraries ---- 
library(tidyverse)
library(ipumsr)

## ---- Create extract request inputs ----
topic <- "sexism-state-poverty-ratio"

# Variables
cps_variables = c("ASECWT", "POVERTY", "SEX", "STATEFIP", "YEAR")

# Convert the vector of variable names to a var_spec() that can be submitted to the define_extract_cps() function
my_cps_vars <- purrr::map(
  cps_variables,
  ~ var_spec(.x)
)

# Years - set the years for which you want to calculate the sex-based poverty ratio
cps_years = c(seq(2015, 2023, 1))

## ---- Create data directories if they don't already exist ----
if(!dir.exists(here("measures", topic, "data"))){
  dir.create(here("measures", topic, "data"))
  dir.create(here("measures", topic, "data", "input"))
  dir.create(here("measures", topic, "data", "output"))
}

## ---- Create IPUMS CPS extract request ---- 
# 1. Generate a list of ASEC sample names for years in question. In IPUMS CPS,
# the ASEC sample name follows this pattern:
# 
# cps<YEAR>_03s
# 
# Thus, we just need to glue the correct text to the years for which we want
# CPS data.
cps_samples <- glue::glue("cps{cps_years}_03s")

# 2. Create an extract request that includes variables for all specified samples
extract <- define_extract_cps(
  description = "Poverty ratio inputs, by state, for all ASEC dataset for specified set of years",
  samples = cps_samples,
  variables = my_cps_vars,
  data_format = "csv",
)

# 3. Submit the extract to IPUMS
submitted_extract <- submit_extract(extract)

# 4. Wait for the extract to be finished
downloadable_extract <- wait_for_extract(submitted_extract)

# 5. Download it to a local folder in the topic directory
download_extract(downloadable_extract, here::here("measures", topic, "data", "input"))

