# Politics - state - state presidential election results
## Data acquisition
Data for this measure come from the state-level election returns from 1976-2020 from the [MIT Election Data + Science Lab](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/42MVDX). To access the data, you must go the URL and click the `Access Dataset` button. You will be provided with the option to download the data in the "Original Format ZIP" or the "Archival Format (.tab) ZIP" format. You should select the "Original Format ZIP" from the drop-down list. You will then be prompted for your name, email address, institution, and position. You must provide this information in order to download the ZIP file.  This action will save a ZIP file to your local computer, probably in your Downloads folder. You should then unzip the file and move the three files to the `/data/input/` directory. The `_proc.R` script expects the three files to be in that directory.  

## Data processing
After you have acquired the data and placed them in the `/data/input/` directory, you should run the script in the `/R` directory with `_proc.R` in its file name. This script will load the data into R and create the state-level measure related to presidential results for the Democratic and Republican parties. It will then write out a CSV file to the `/data/output` directory. 

## Documentation
To generate the PDF documentation for the measure, you should knit the script in the `/R` directory with the `.Rmd` file extension. Knit will convert the R markdown file to a PDF in the `/R` directory. 

The information that populates the `Data Summary` section of the documentation comes from a CSV file found in the `/data/input` directory. The `variable_descriptions.csv` file lists the variable names, descriptions, and data types for each column in the output CSV. 
