# Sexism - state - domestic violence and gun ownership
## Data acquisition
Data for this measure come from the [State Firearms Database](https://www.statefirearmlaws.org/) website. To access the data  broken down by year and state and the associated codebook, go to the [Resources](https://www.statefirearmlaws.org/resources) website. Then, click the `Download the Database` button to get the dataset and the `Downlaod the Codebook` to get the codebook. The two Excel files will be saved to your computer, probably in your Downloads folder. You must move the Excel files to the `/data/input/` directory for this measure. The `_proc.R` script expects the Excel files to be in that directory. 

## Data processing
After you have acquired the data and placed them in the `/data/input/` directory, you should run the script in the `/R` directory with `_proc.R` in its file name. This script will load the data into R and create the county-level measures of educational inequity. It will then write out a CSV file to the `/data/output` directory. 

## Documentation
To generate the PDF documentation for the measure, you should knit the scirpt in the `/R` directory with the `.Rmd` file extension. Knit will convert the R markdown file to a PDF in the `/R` directory. 

The information that populates the`Data Summary` section of the documentation comes from two CSV files found in the `/data/input` directory. The `variable_descriptions.csv` file lists the variable names, descriptions, and data types for each column in the output CSV. 