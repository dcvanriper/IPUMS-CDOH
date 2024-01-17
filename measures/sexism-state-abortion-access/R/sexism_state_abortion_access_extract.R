## -------------------------------------------------------
#
# sexism_state_abortion_access_extract.R
#
# Acquire Caitlin Myer's Abortion Access by County and Month
# data from Open Science Framework (OSF). The main URL
# for Myer's data is https://osf.io/pfxq3/
# 
## -------------------------------------------------------

## ---- Establish location of current script ----
here::i_am("measures/sexism-state-abortion-access/R/sexism_state_abortion_access_extract.R")

## ---- Load libraries ---- 
library(tidyverse)
library(osfr)

## ---- Create extract request inputs ----
topic <- "sexism-state-abortion-access"

## ---- Create data directories if they don't already exist ----
if(!dir.exists(here::here("measures", topic, "data"))){
  dir.create(here::here("measures", topic, "data"))
  dir.create(here::here("measures", topic, "data", "input"))
  dir.create(here::here("measures", topic, "data", "output"))
}

## ---- Get the list of files in Myer's Abortion Access project ----
# GUID for project is pfxq3
# Retrieve project information
abortion_proj <- osf_retrieve_node("pfxq3")

## ---- Retrieve CSV data file associated with project ----
# This downloads the most up-to-date file in the OSF project  
abortion_proj  |> 
  osf_ls_nodes()  |> 
  filter(name == "Data")  |> 
  osf_ls_files(pattern = "csv") |> 
  osf_download(path = here::here("measures", topic, "data", "input"))


