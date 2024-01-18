# Sexism - state - paid family medical leave
## Data acquisition
Data for this measure come from the National Partnership for Women & Families' [State Paid Family & Medical Leave Insurance Laws](https://www.nationalpartnership.org/our-work/resources/economic-justice/paid-leave/state-paid-family-leave-laws.pdf). This document lists the years when state-level paid family and/or medical leave laws were enacted and went into effect. The document has a _Status_ table, typically on page 2, that lists these years. For this measure, we want to capture the year when a state's initial law went into effect. 

We created a CSV file (`/data/input/state-fml-effective-year.csv`) with one row for every state, and we included a column called `effective_fml`. For states with a family and medical leave law, we entered the effective year into the `effective_fml` column. States without a family and medical leave law have no year entered into the `effective_fml` column. 

## Data processing
Since we have already created the input dataset for this measure, you can just run the script in teh `/R` directory with the `_proc.R` in its file name. This script will load the data into R and create the state-level measure related to the availability of a state paid family and medical leave law. It will then write out a CSV file to the `/data/output` directory. 

## Documentation
To generate the PDF documentation for the measure, you should knit the script in the `/R` directory with the `.Rmd` file extension. Knit will convert the R markdown file to a PDF in the `/R` directory. 

The information that populates the `Data Summary` section of the documentation comes from a CSV file found in the `/data/input` directory. The `variable_descriptions.csv` file lists the variable names, descriptions, and data types for each column in the output CSV. 

