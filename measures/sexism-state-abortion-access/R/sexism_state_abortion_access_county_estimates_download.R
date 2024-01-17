## -------------------------------------------------------
#
# sexism_state_abortion_access_county_estimates_download.R
#
# Acquire county-level population estimates from the US 
# Census Bureau's Population Estimates program for 
# Alaska and Hawaii. These are needed to fill in some 
# gaps in Caitlin Myer's Abortion Access by County and
# Month data. 
# 
## -------------------------------------------------------

## ---- Establish location of current script ----
here::i_am("measures/sexism-state-abortion-access/R/sexism_state_abortion_access_county_estimates_download.R")

## ---- Load libraries ---- 
library(tidyverse)

## ---- Create extract request inputs ----
topic <- "sexism-state-abortion-access"

## ---- Create data directories if they don't already exist ----
if(!dir.exists(here::here("measures", topic, "data"))){
  dir.create(here::here("measures", topic, "data"))
  dir.create(here::here("measures", topic, "data", "input"))
  dir.create(here::here("measures", topic, "data", "output"))
}

## ---- Acquire 2000-2009 population estimates for AK and HI ----
download.file("https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/counties/asrh/cc-est2009-agesex-02.csv", here::here("measures", topic, "data", "input", "ak_2000_2009.csv"))
download.file("https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/counties/asrh/cc-est2009-agesex-15.csv", here::here("measures", topic, "data", "input", "hi_2000_2009.csv"))

## ---- Acquire 2010-2019 population estimates by characteristic for AK and HI ----
download.file("https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/asrh/cc-est2019-agesex-02.csv", here::here("measures", topic, "data", "input", "ak_2010_2019.csv"))
download.file("https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/asrh/cc-est2019-agesex-15.csv", here::here("measures", topic, "data", "input", "hi_2010_2019.csv"))                      

## ---- Acquire 2020-2022 population estimates by characteristic for AK and HI ----
download.file("https://www2.census.gov/programs-surveys/popest/datasets/2020-2022/counties/asrh/cc-est2022-agesex-02.csv", here::here("measures", topic, "data", "input", "ak_2020_2022.csv"))
download.file("https://www2.census.gov/programs-surveys/popest/datasets/2020-2022/counties/asrh/cc-est2022-agesex-15.csv", here::here("measures", topic, "data", "input", "hi_2020_2022.csv"))                      
