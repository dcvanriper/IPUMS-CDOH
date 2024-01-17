# Turn off scientific notation
options(scipen = 999)

# This function creates a consistent set of variable names for the educational
# inequality measure.
edu_modify_nhgis_code <- function(x, category){
  # prepare category - make sure white_alone is white_alone_not_hispanic
  category_name <- tolower(str_split(category, " ")[[1]][1])
  
  x <- x |> 
    mutate(nhgis_code = case_when(str_length(nhgis_code) == 6 ~ paste0(str_sub(nhgis_code, 1, 3), "E", str_sub(nhgis_code, 4, 6)),
                                  TRUE ~ paste0(str_sub(nhgis_code, 1, 4), "E", str_sub(nhgis_code, 5, 8))),
           description = tolower(description),
           description = str_remove(description, ":"),
           description = str_remove(description, "'"),
           description = str_remove(description, ", ged, or alternative"),
           description = str_remove(description, " \\(includes equivalency\\)"),
           description = str_replace_all(description, "[,]", ""),
           description = str_replace_all(description, "[ ]", "_"),
           description = paste0(category_name, "_", description))
  
}

# This function creates a consistent set of variable names for the homeownership
# inequality measure.
hu_modify_nhgis_code <- function(x, category){
  # prepare category - make sure white_alone is white_alone_not_hispanic
  category_name <- tolower(str_split(category, " ")[[1]][9])
  
  x <- x |> 
    mutate(nhgis_code = case_when(str_length(nhgis_code) == 6 ~ paste0(str_sub(nhgis_code, 1, 3), "E", str_sub(nhgis_code, 4, 6)),
                                  TRUE ~ paste0(str_sub(nhgis_code, 1, 4), "E", str_sub(nhgis_code, 5, 8))),
           description = tolower(description),
           description = str_replace_all(description, "[ ]", "_"),
           description = paste0(category_name, "_", description))
  
}

# This function creates a consistent set of variable names for the employment
# inequality measure.
emp_modify_nhgis_code <- function(x, category){
  # prepare category - make sure white_alone is white_alone_not_hispanic
  category_name <- tolower(str_split(category, " ")[[1]][1])
  
  x <- x |> 
    mutate(nhgis_code = case_when(str_length(nhgis_code) == 6 ~ paste0(str_sub(nhgis_code, 1, 3), "E", str_sub(nhgis_code, 4, 6)),
                                  TRUE ~ paste0(str_sub(nhgis_code, 1, 4), "E", str_sub(nhgis_code, 5, 8))),
           description = tolower(description),
           description = str_remove_all(description, ":"),
           description = str_replace_all(description, "[ ]", "_"),
           description = paste0(category_name, "_", description))
  
}

# This function creates a consistent set of variable names for the income
# inequality measure.
inc_modify_nhgis_code <- function(x, category){
  # prepare category - make sure white_alone is white_alone_not_hispanic
  category_name <- tolower(category)
  category_name <- str_split(category_name, " ")
  category_name <- category_name[[1]][7:length(category_name[[1]])]
  category_name <- paste(category_name, collapse = "_")
  category_name <- str_remove_all(category_name, "[,]")
  
  x <- x |> 
    mutate(nhgis_code = case_when(str_length(nhgis_code) == 6 ~ paste0(str_sub(nhgis_code, 1, 3), "E", str_sub(nhgis_code, 4, 6)),
                                  TRUE ~ paste0(str_sub(nhgis_code, 1, 4), "E", str_sub(nhgis_code, 5, 8))),
           description = tolower(description),
           description = str_remove(description, ":"),
           description = str_remove_all(description, "[$]"),
           description = str_replace_all(description, "[ ]", "_"),
           description = str_replace_all(description, "[,]", ""),
           description = paste0(category_name, "_", description))
  
}

# This function creates a consistent set of variable names for the residential
# segregation (index of dissimilarity - d)
segd_modify_nhgis_code <- function(x, name){
  x <- x |> 
    mutate(nhgis_code = case_when(str_length(nhgis_code) == 6 ~ paste0(str_sub(nhgis_code, 1, 3), "E", str_sub(nhgis_code, 4, 6)),
                                  TRUE ~ paste0(str_sub(nhgis_code, 1, 4), "E", str_sub(nhgis_code, 5, 8))),
           description = tolower(description),
           description = str_remove_all(description, ":"),
           description = str_replace_all(description, "Not Hispanic or Latino", "nh"),
           description = str_replace_all(description, "Hispanic", "h"),
           description = str_replace_all(description, "[ ]", "_"),
           description = str_replace_all(description, "[,]", ""),
           description = paste0(name, "_", description))
  
}

# This function creates a consistent set of variable names for the LGBTQ households measure
lgbtqhh_modify_nhgis_code <- function(x){
  x <- x |> 
    mutate(description = tolower(description),
           description = str_remove_all(description, ":"),
           description = str_replace_all(description, "[ ]", "_"),
           description = str_replace_all(description, "[-]", "_"))
}

# This function takes in NHGIS metadata (metadata object and an NHGIS dataset name) 
# and creates a recode key.
create_recode_key <- function(ds, meta){
  subset_meta <- keep(meta, ~ .x$dataset_name == ds)
  
  # Create a single list from the variables dfs in subset_meta
  column_list <- map(subset_meta, ~ .x$variables)
  
  # Collapse the list into a data frame
  column_df <- bind_rows(column_list)
  
  # Create the recode key
  recode_key <- purrr::set_names(c(column_df$description), c(column_df$nhgis_code))
  
  recode_key
}


# This function takes in a data frame and a recode_key and renames columns
# in the dataframe. 
recode_nhgis_columns <- function(nhgis_df, recode_key){
  nhgis_df <- nhgis_df |> 
    rename_with(~recode(colnames(nhgis_df), !!!recode_key))
}
