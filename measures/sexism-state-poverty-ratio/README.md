# Sexism - state - poverty ratio
## Data acquisition
Data for this measure come from [IPUMS CPS](https://cps.ipums.org/cps). To acquire the input data, run the script in the `/R` directory with `_extract.R` in its file name. The `_extract.R` script will generate the appropriate directories in the `/data` folder if they do not already exist. 

Our data extract script uses the `ipumsr` package to interface with IPUMS CPS through the IPUMS Application Programming Interface (API). Using the API requires a key, which is available through the IPUMS user management system. If you do not have an IPUMS API key, we recommend following the instructions provided in the [Introduction to the IPUMS API for R Users](https://tech.popdata.org/ipumsr/articles/ipums-api.html) article.

## Data processing
Immediately after you have run the `_extract.R` script, you should run the script in the `/R` directory with `_proc.R` in its file name. This script will load the IPUMS CPS data into R and create the state-level ratio of the proportion of females living in poverty to the proportion of males living in poverty. It will then write out a CSV file to the `/data/output` directory. 

## Documentation
To generate the PDF documentation for the measure, you should knit the script in the `/R` directory with the `.Rmd` file extension. Knit will convert the R markdown file to a PDF in the `/R` directory. 

The information that populates the `Variables` and `Data Summary` sections of the documentation comes from two CSV files found in the `/data/input` directory. The `table_code_label.csv` file lists the variable names and descriptions that are extracted from IPUMS CPS and used to generate the output CSV. The `variable_descriptions.csv` file lists the variable names, descriptions, and data types for each column in the output CSV. 