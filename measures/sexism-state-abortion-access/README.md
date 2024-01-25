# Sexism - state - abortion access
## Data acquisition
Data for this measure come from a variety of sources. The abortion access data come from the [County-by-Month Distances to Nearest Abortion Provider](https://osf.io/pfxq3/), which is part of the [Myers Abortion Facility Database](https://osf.io/8dg7r/). To acquire the abortion access data data, run the `/R/sexism_state_abortion_access.R` script. The `/R/sexism_state_abortion_access.R` script will generate the appropriate directories in the `/data` folder if they do not already exist and then download the `County-by-Month Distances to Nearest Abortion Provider` dataset into the `/data/input` folder. 

The abortion access data are missing county population estimates for Alaska and Hawaii, so we obtain those from the U.S. Census Bureau's [Population Estimates Program](https://www.census.gov/programs-surveys/popest.html). To download the population estimates from 2009-2022, run the `/R/sexism_state_abortion_access_county_estimates_download.R` script. 

## Data processing
After you have run the scripts to download the abortion access data and the county population estimates, you should run the script in the `/R` directory with `_proc.R` in its file name. This script will load the abortion access and population estimates and create the state-level measures of abortion access. It will then write out a CSV file to the `/data/output` directory. 

## Documentation
To generate the PDF documentation for the measure, you should knit the script in the `/R` directory with the `.Rmd` file extension. Knit will convert the R markdown file to a PDF in the `/R` directory. 

The information that populates the `Data Summary` sections of the documentation comes from a CSV file found in the `/data/input` directory. The `variable_descriptions.csv` file lists the variable names, descriptions, and data types for each column in the output CSV. 