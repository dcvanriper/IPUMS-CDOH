## -------------------------------------------------------
#
# female_legislative_prop_proc.R
#
# Process the legislative counts by sex of elected 
# representatives in state legislatures, 2015 - 2023.   
# 
## -------------------------------------------------------
## ---- Establish location of current script ----
here::i_am("measures/sexism-state-proportion-state-legislators-identifying-as-female/R/female_legislative_prop_proc.R")

## ---- load require libraries ----
require(tidyverse)
#require(purrr)
#require(vroom)
require(janitor)

## ---- Set topic for the dataset ----
topic <- "sexism-state-proportion-state-legislators-identifying-as-female"

## ---- Import state fips code ----
state_fips = read_csv(here::here("measures", "reference_datasets", "state_fips.csv"))

# Set path to input data
data_dir <- glue::glue("/pkg/popgis/labpcs/data_projects/nchat/measures/{table_label}/input-data/")

## ---- Load data ----
# Generate a list of the spreadsheets in the input directory
file_list <- list.files(path = here::here("measures", topic, "data", "input"), pattern = "Data")

# Load CSVs using map_dfr
#df <- map_dfr(file_list, ~ read_csv(here("measures", topic, "data", "input", .), col_types = "ccccccccc"))

#df_list <- map(file_list, ~ read_csv(here("measures", topic, "data", "input", .), col_types = "ccccccccc"))

# Function to read in each data file, compute ratio and return output
read_data <- function(file_name){
  x <- read_csv(here::here("measures", topic, "data", "input", file_name), col_types = "ccccccccc") |> 
    clean_names() |> 
    mutate(year = as.numeric(str_extract(file_name, pattern = "(\\d)+")))
  
  return(x)
}

# Map over files in file_list
df_list <- map(file_list, ~read_data(.x))

# Bind data frames in df_list into one data frame and fix up the discrepancy between
# total_women_total_legis and total_women_total_legislators
t <- bind_rows(df_list) |> 
  mutate(total_women_legislators = case_when(is.na(total_women_total_legis) ~ total_women_total_legislators,
                                             !is.na(total_women_total_legis) ~ total_women_total_legis)) |> 
  select(-c(total_women_total_legis, total_women_total_legislators))

# Drop records for US territories and records that have no value in the state field
t <- t[!(t$state== "PR" | t$state== "<i>AS</i>" | t$state== "<i>GU</i>" | t$state== "<i>PR</i>" | t$state== "<i>MP</i>" 
         | t$state== "<i>VI</i>" | t$state== "AS" | t$state== "GU" | t$state== "PR" | t$state== "MP" 
         | t$state== "VI" | t$state== "Totals" | is.na(t$state)) ,]

# remove the word unicameral (in all it's various spellings) from the total_women_total_house variable
t$total_women_total_house <- str_remove_all(t$total_women_total_house, "-unicameral-")
t$total_women_total_house <- str_remove_all(t$total_women_total_house, "- - unicameral - -")
t$total_women_total_house <- str_remove_all(t$total_women_total_house, "unicameral")

# get rid of weird characters in D.C. rows  -----
t$state <- str_remove_all(t$state, "[<i/>]")
t$state_rank<- str_remove_all(t$state_rank, "[<i/>]")
t$senate <- str_remove_all(t$senate, "[<i/>]")
t$house<- str_remove_all(t$house, "[<i/>]")
t$percent_women_overall <- str_remove_all(t$percent_women_overall, "[<i/>]")
# Don't remove the "/" from the following varialbes since it funtamentally changes the values
#t$total_women_total_senate <- str_remove_all(t$total_women_total_senate, "[<i/>]")
#t$total_women_total_house <- str_remove_all(t$total_women_total_house, "[<i/>]")
#t$total_women_legislators <- str_remove_all(t$total_women_legislators, "[<i/>]")

# Clean state of extraneous asterisks  =
t$state <- str_remove_all(t$state, "[*]")

## ---- Fix Senate and House variables ----

# separate out the different values in senate and house columns - - - - -
# This code chunk will split apart the strings in senate and house by pattern matching. 
# The "\\d+D" will return any numeric value plus the letter "D" in a string.
t <- t %>%
  mutate(senate_democrats_women = as.numeric(str_remove(str_match(senate, "\\d+D"), "D")),
         senate_republicans_women = as.numeric(str_remove(str_match(senate, "\\d+R"), "R")),
         senate_independents_women = as.numeric(str_remove(str_match(senate, "\\d+Ind"), "Ind")),
         house_democrats_women = as.numeric(str_remove(str_match(house, "\\d+D"), "D")),
         house_republicans_women = as.numeric(str_remove(str_match(house, "\\d+R"), "R")), 
         house_independents_women = as.numeric(str_remove(str_match(house, "\\d+Ind"), "Ind")))


# Clean the totals columns 
t <- t %>%
  mutate(total_women_total_senate = str_replace_all(total_women_total_senate, c("Jan" = "1", "Feb" = "2", "Mar" = "3", "Apr" = "4", "May" = "5", "Jun"="6", 
                                                                                "Jul"="7", "Aug"="8", "Sep"="9", "Oct"="10", "Nov"="11", "Dec"="12")),
         total_women_total_house = str_replace_all(total_women_total_house, c("Jan" = "1", "Feb" = "2", "Mar" = "3", "Apr" = "4", "May" = "5", "Jun"="6", 
                                                                              "Jul"="7", "Aug"="8", "Sep"="9", "Oct"="10", "Nov"="11", "Dec"="12")),
         total_women_legislators = str_replace_all(total_women_legislators, c("Jan" = "1", "Feb" = "2", "Mar" = "3", "Apr" = "4", "May" = "5", "Jun"="6", 
                                                                              "Jul"="7", "Aug"="8", "Sep"="9", "Oct"="10", "Nov"="11", "Dec"="12")))


# Separate out total senate(house)(legis) from total_women_total_senate(house)(legis)

## The second mutate function is required to remove extraneous characters from the DC cases
t <- t %>%
  mutate(total_women_total_senate = str_remove_all(total_women_total_senate, " ")) %>%
  separate(total_women_total_senate, into = c("total_women_senate", "tot_senate"), sep = "([-/])" , 
           remove = FALSE)

t <- t %>%
  mutate(total_women_total_house = str_remove_all(total_women_total_house, " ")) %>%
  separate(total_women_total_house, into = c("total_women_house", "tot_house"), sep = "([-/])", remove = FALSE)

t <- t %>%
  mutate(total_women_legislators = str_remove_all(total_women_legislators, " ")) %>%
  separate(total_women_legislators, into = c("total_women", "tot_legis"), sep = "([-/])", remove = FALSE)

#convert to numeric -   ##change n/a to zero??
t <- t %>% 
  mutate_at(c("total_women_house", "tot_house"), as.numeric)

# run this after separating values b/c you don't want to mess with the delimiter "/" ---- OR replace the DC names 
t$total_women_senate <- str_remove_all(t$total_women_senate, "[<i>]")
t$tot_senate<- str_remove_all(t$tot_senate, "[<i>]")

# run this to eliminate the two spaces in record 310 - I can't figure out how to remove them!
t$total_women_senate <- str_remove_all(t$total_women_senate, "[^a-zA-Z0-9]")
t$tot_senate<- str_remove_all(t$tot_senate, "[^a-zA-Z0-9]")

# convert senate field to numeric type
t <- t %>% 
  mutate_at(c("total_women_senate", "tot_senate"), as.numeric)

# create house_total and senate_total columns based on largest value in tot_senate(house) or total_women_senate(house)
t$total_senate <- pmax(t$tot_senate, t$total_women_senate)
t$total_house <- pmax(t$tot_house, t$total_women_house)

# change NA to zero
t <- t %>% 
  mutate_at(c("senate_democrats_women", "senate_republicans_women", "senate_independents_women","house_democrats_women", "house_republicans_women", "house_independents_women","total_senate","total_house"),
            ~replace_na(.,0))

## ---- Create final data frame for dissemination ----
# Join state_fips df
df_final <- t |> 
  left_join(state_fips, by = c("state" = "postal")) |> 
  select(-state, state = state.y)

# Keep required variables for dissemination
df_final <- df_final |> 
  select(year, statefips, state, senate_democrats_women:total_house)

# Create final summary counts for totals and compute proportions
df_final <- df_final |> 
  mutate(total_senate_women = senate_democrats_women + senate_republicans_women + senate_independents_women,
         total_house_women = house_democrats_women + house_republicans_women + house_independents_women,
         total_legis = total_house + total_senate,
         total_women = total_senate_women + total_house_women,
         prop_female_legis = total_women/total_legis,
         prop_female_house = total_house_women / total_house,
         prop_female_senate = total_senate_women / total_senate)

## ---- Write out data frames to CSV ----------
if(!dir.exists(here::here("measures", topic, "data", "output"))){
  dir.create(here::here("measures", topic, "data", "output"))
  
  df |> 
    write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
} else{
  df |> 
    write_csv(here::here("measures", topic, "data", "output", glue::glue("{topic}.csv")), na='')
}

