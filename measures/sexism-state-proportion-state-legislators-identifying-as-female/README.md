# Sexism - state - proportion state legislators identifying as female
## Data acquisition
Data for this measure come from the [Center for American Women and Politics (CAWP)](https://cawp.rutgers.edu/), Eagleton Institute of Politics, Rutgers University-New Brunswick. CAWP publishes annual reports and datasets about women serving in state legislatures, broken down by political party and legislative chamber (state senate and house). The reports and datasets are available from 2015-2023. 

To access a specific year's dataset, you need to visit that year's URL (listed in the `URLs to CAWP's data` below). To download data for a specific year, you need to click on the `Export Table Data` link that is just above a header called `Women in State Legislatures YYYY` where `YYYY` is the year for which you are acquiring data. 

Clicking on the `Export Table Data` link will download a CSV to your computer, probably in your Downloads folder. You must move the CSV file to the `/data/input` directory. The `_proc.R` script expects the CSV files to be in that directory.  You also need to rename the CSV file because the name on the downloaded file is not meaningful. We strongly recommend renaming the CSV file to `Data_YYYY.csv` where `YYYY` is the year the data represents. The `_proc.R` script expects the CSV file name to include the word `Data`.

## Data processing
After you have acquired the data, placed them in the `/data/input/` directory, and renamed the files, you should run the script in the `/R` directory with `_proc.R` in its file name. This script will load the data into R and create the state-level measures related to the proportion of state legislators identifying as female. It will then write out a CSV file to the `/data/output` directory. 

## Documentation
To generate the PDF documentation for the measure, you should knit the script in the `/R` directory with the `.Rmd` file extension. Knit will convert the R markdown file to a PDF in the `/R` directory. 

The information that populates the`Data Summary` section of the documentation comes from a CSV file found in the `/data/input` directory. The `variable_descriptions.csv` file lists the variable names, descriptions, and data types for each column in the output CSV.

## URLs to CAWP's data
* Center for American Women and Politics (CAWP). 2024. “Women in State Legislatures 2023.” New Brunswick, NJ: Center for American Women and Politics, Eagleton Institute of Politics, Rutgers University-New Brunswick. https://cawp.rutgers.edu/facts/levels-office/state-legislature/women-state-legislatures-2024. (Accessed January 5, 2024) 

* Center for American Women and Politics (CAWP). 2022. “Women in State Legislatures 2022.” New Brunswick, NJ: Center for American Women and Politics, Eagleton Institute of Politics, Rutgers University-New Brunswick. https://cawp.rutgers.edu/facts/levels-office/state-legislature/women-state-legislatures-2022. (Accessed August 31, 2022) 

* Center for American Women and Politics (CAWP). 2021. “Women in State Legislatures 2021.” New Brunswick, NJ: Center for American Women and Politics, Eagleton Institute of Politics, Rutgers University-New Brunswick. https://cawp.rutgers.edu/facts/levels-office/state-legislature/women-state-legislatures-2021. (Accessed August 31, 2022) 

* Center for American Women and Politics (CAWP). 2020. “Women in State Legislatures 2020.” New Brunswick, NJ: Center for American Women and Politics, Eagleton Institute of Politics, Rutgers University-New Brunswick. https://cawp.rutgers.edu/facts/levels-office/state-legislature/women-state-legislatures-2020. (Accessed August 31, 2022) 

* Center for American Women and Politics (CAWP). 2019. “Women in State Legislatures 2019.” New Brunswick, NJ: Center for American Women and Politics, Eagleton Institute of Politics, Rutgers University-New Brunswick. https://cawp.rutgers.edu/facts/levels-office/state-legislature/women-state-legislatures-2019. (Accessed August 31, 2022) 

* Center for American Women and Politics (CAWP). 2018. “Women in State Legislatures 2018.” New Brunswick, NJ: Center for American Women and Politics, Eagleton Institute of Politics, Rutgers University-New Brunswick. https://cawp.rutgers.edu/facts/levels-office/state-legislature/women-state-legislatures-2018. (Accessed August 31, 2022) 

* Center for American Women and Politics (CAWP). 2017. “Women in State Legislatures 2017.” New Brunswick, NJ: Center for American Women and Politics, Eagleton Institute of Politics, Rutgers University-New Brunswick. https://cawp.rutgers.edu/facts/levels-office/state-legislature/women-state-legislatures-2017. (Accessed August 31, 2022) 

* Center for American Women and Politics (CAWP). 2016. “Women in State Legislatures 2016.” New Brunswick, NJ: Center for American Women and Politics, Eagleton Institute of Politics, Rutgers University-New Brunswick. https://cawp.rutgers.edu/facts/levels-office/state-legislature/women-state-legislatures-2016. (Accessed August 31, 2022) 

* Center for American Women and Politics (CAWP). 2015. “Women in State Legislatures 2015.” New Brunswick, NJ: Center for American Women and Politics, Eagleton Institute of Politics, Rutgers University-New Brunswick. https://cawp.rutgers.edu/facts/levels-office/state-legislature/women-state-legislatures-2015. (Accessed August 31, 2022) 
