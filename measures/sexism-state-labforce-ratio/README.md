# Sexism - state - labor force ratio
## Data acquisition
Data for this measure come from the Bureau of Labor Statistic's annual [Highlights of Women's Earnings](https://www.bls.gov/cps/earnings.htm#demographics). To access the data, you must go to teh Highlights of Women's Earnings URL, and you should see a section called `Annual report: Highlights of Women's Earnings`. There will be a bulleted list of reports by year. For each list item, you must click on the hyperlink called `(tables in xlsx)`. This action will save an Excel file to your local computer, probably in your Downlaods folder. You must move the Excel files to the `/data/input/` directory for this measure. The `_proc.R` script expects the Excel files to be in that directory. 

The input data for the labor force ratio measure are the same as those for the earnings ratio measure. If you have already downloaded the data for the earnings ratio, you can copy the Excel spreadsheets into the `/data/input` directory. 

## Data processing
After you have acquired the data and placed them in the `/data/input/` directory, you should run the script in the `/R` directory with `_proc.R` in its file name. This script will load the data into R and create the state-level measure comparing the proportion of men in the labor force to the proportion of women in the labor force. It will then write out a CSV file to the `/data/output` directory. 

## Documentation
To generate the PDF documentation for the measure, you should knit the script in the `/R` directory with the `.Rmd` file extension. Knit will convert the R markdown file to a PDF in the `/R` directory. 

The information that populates the `Data Summary` section of the documentation comes from a CSV file found in the `/data/input` directory. The `variable_descriptions.csv` file lists the variable names, descriptions, and data types for each column in the output CSV. 
