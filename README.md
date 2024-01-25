# IPUMS-CDOH
[IPUMS CDOH (Contextual Determinants of Health)](https://cdoh.ipums.org/) provides access to measures of disparities, policies, and counts, by state and county, for historically marginalized populations in the United States, including Black, Asian, Hispanic/Latina/o/e/x, LGBTQ+ persons and women. CDOH measures are available free of charge.

This repository provides instructions and code used to generate the measures. We do this for two reasons. First, we believe in transparency and want to provide users with the chance to check our work. Second, while we think our measures are generally useful for scientists, we understand that people may want to customize measures for their particular analyses. They can use our code as the basis for creating customized measures. 

## Required R packages
The CDOH code relies on a number of R packages. We recommend users install the following packages before they run any of the CDOH scripts.

* `tidyverse` - our code leverage many functions provided by the packages in the [tidyverse](https://www.tidyverse.org/) collection  
* `here`- we use the [here](https://here.r-lib.org/) package to generate path names 
* `glue` - we use the [glue](https://glue.tidyverse.org/) package to generate file names using variable names
* `ipumsr`- we use the [ipumsr](https://tech.popdata.org/ipumsr/) package to programatically access [IPUMS](https://www.ipums.org/) metadata and generate, submit, and download IPUMS extracts
* `srvyr` - we use the [srvyr](https://github.com/gergness/srvyr/) package to process survey data from [IPUMS CPS](https://cps.ipums.org/cps/)
* `readxl` - we use the [readxl](https://readxl.tidyverse.org/) package to read data from Excel spreadsheets
* `osfr` - we use the [osfr](https://docs.ropensci.org/osfr/) package to access projects on the Open Science Framework ([OSF](https://osf.io/)) 

The `ipumsr` package uses IPUMS' Application Programming Interface (API), which requires a key. If you do not have an IPUMS API key, we recommend reading the instructions provided in the [Introduction to the IPUMS API for R Users](https://tech.popdata.org/ipumsr/articles/ipums-api.html) article.

## Data sources
CDOH measures draw on a variety of different data sources, and those sources are listed in the documentation/instructions in their respective folders in the `/measures` directory. 

## Processing pipeline
### 1. Data acquisition
We begin by acquiring the input data that underlie a particular measure. Data acquisition is done programmatically using functions in specific R packages (e.g., `ipumsr` or `osfr`), or by downloading data files from specific websites. We provide instructions for data acquisition within each measure's folder in the `/measures` directory. 

### 2. Data processing
After we have acquired the input data for a particular measure, we can then process it to create the CDOH measure. Within the `/R` directory for each measure, there will be a script with `_proc.R` at end of its name. This script loads in the required input data, generates the variables for the measure, and writes out a CSV file into the `/data/output_data` directory. 

### 3. Documentation generation
We then create a PDF file documenting a particular measure, including descriptions of the input data, formulas used to create variables, and the name and description of each variable in the output CSV file. The file with the `.Rmd` extension in the measure's `/R` directory generates the PDF, and we use the `Knit` function in RStudio for that purpose. The PDF file will be written to the `/R` directory.

## Citation 
Publications and research reports should include a citation for each measure you use. You can find measure-specific citations in the `.Rmd` files in the `/measures` directories. The citation for the overall IPUMS Contextual Determinants of Health is:

`Claire Kamp Dush, Wendy Manning, and David Van Riper. IPUMS Contextual Determinants of Health: Version 1.0 [dataset]. Minneapolis, MN: IPUMS. 2023. https://doi.org/10.18128/D130.V1.0`
 
## Funding support
Funding for IPUMS CDOH is provided by grant U01HD108779 from the National Institutes of Health. Funding for the creation of this repository is provided by a pilot grants from the [Social, Behavioral, & Economic COVID Coordinator Center (SBE CCC)](https://www.icpsr.umich.edu/web/pages/sbeccc/). The SBE CCC is funded by grant U24AG076462 from the National Institutes of Health.
