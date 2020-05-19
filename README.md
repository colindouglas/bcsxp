# Read BCS XP Results Files

  <!-- badges: start -->
  [![R build status](https://github.com/colindouglas/bcsxp/workflows/R-CMD-check/badge.svg)](https://github.com/colindouglas/bcsxp/actions)
  [![GitHub commit](https://img.shields.io/github/last-commit/colindouglas/bcsxp)](https://github.com/colindouglas/bcsxp/commit/master)
  <!-- badges: end -->
  
This package reads ASCII sample files ("S-files"), calibration files ("C-files"), and raw data ("R-files") exported from BCS XP coagulation analyzers, and returns a tidy row-wise dataframe. It can also read the subassays for each assay, and return a list column containing the results.

Currently, the package is not able to read data exported in XML format. Data for the tests are not included in the repo due to rights issues.

## Installation (from Github)

```r
# install.packages("devtools")
devtools::install_github("colindouglas/bcsxp")
```
## Usage

### Guess Filetype and Read
`read_bcsxp(path, filetype = "guess")` attempts to guess the type of file based on it's header and path and reads it with the appropriate method. By default, it does not attempt to parse the subassays for each assay in an S-file.

### Reading an S-File
`read_bcsxp(path, filetype = "S", include_subassays = FALSE)` reads an exported ASCII file containing data on samples and controls, typically named "S*yyyymmddn*.BCSXp". It returns a tibble with the following columns:

* `datetime`: The date and time the assay finished
* `sample_name`: The name of the sample on the instrument. For controls, it is the control lot number
* `sample_type`: Either "Sample" or "Control"
* `assay_number`: The number uniquely identifying the assay performed. Manufacturer assays < 1000.
* `assay_name`: The short name identifying the assay
* `reagent_lots`: The lot numbers of the reagents used to perform the assay, separated by spaces
* `raw_unit`: The measurement units for the assay, often "secs" for clotting assays or "mE/min" from chromogenic assays
* `result_unit`: The units of the assay output. Often "secs" or "%d.N." for factor assays
* `raw`: The raw measurement, in units of `raw_unit`. If the assay is calibrated, this is the measurement before intepretation through the curve
* `calibration_curve`: The calibration curve through which the raw measurement is interpreted
* `result`: The output of the assay, in units of `result_unit`. If the assay is calibrated, this is the `raw` interpreted through `calibration_curve`
* `flags`: These are warning or error flags raised during the assay
* `instrument`: The name of the instrument and the instrument serial number, separated by a space
* `filename`: The path to the file from which the data originated
* `subassays`: If the function is called with `include_subassays = TRUE`, this is a list column containing the details of the assays-within-the-assay. This column is excluded by default

### Reading a C-File
`read_bcsxp(path, filetype = "C")` reads an exported ASCII file containing data on calibration curves, typically named "C*yyyymmddn*.BCSXp". It returns a tibble with the following columns:

* `datetime`: The date and time the calibration curve measurement finished
* `curve_name`: The name of the calibration curve. 
* `assay_number`: The number uniquely identifying the assay performed. Manufacturer assays < 1000.
* `assay_name`: The short name identifying the assay
* `reagent_lots`: The lot numbers of the reagents used to perform the assay, separated by spaces
* `raw_unit`: The measurement units for the assay, often "secs" for clotting assays or "mE/min" from chromogenic assays
* `concentration_unit`: The units of the assay output. Often "secs" or "%d.N." for factor assays
* `reagent_lots`: The lot numbers of the reagents used to perform the assay, separated by spaces
* `flags`: These are warning or error flags that were raised during the calibration
* `measurements`: The number of supporting points for the calibration curve
* `instrument`: The name of the instrument and the instrument serial number, separated by a space
* `filename`: The path to the file from which the data originated
* `points`: A list column that contains results for the individual points in the calibration curve

### Reading a R-File
`read_bcsxp(path, filetype = "R")` reads an exported ASCII file containing raw absorbance vs. time data for each assay, typically named "R*yyyymmddn*.BCSXp". It returns a tibble with the following columns:

* `datetime`: The date and time the calibration curve measurement finished
* `id`: Unique identifier for each assay
* `sample_name`: The name of the sample on the instrument. For controls, it is the control lot number
* `sample_type`: Either "Sample" or "Control"
* `assay_number`: The number uniquely identifying the assay performed. Manufacturer assays < 1000.
* `assay_name`: The short name identifying the assay
* `reagent_lots`: The lot numbers of the reagents used to perform the assay, separated by spaces
* `cuvette`: The cuvette position in which the reaction occured
* `flags`: These are warning or error flags raised during the assay
* `detection method`: The method the software uses to infer the raw result. For clot-based assays, this is the endpoint detection method
* `raw`: The raw measurement, in units of `raw_unit`. If the assay is calibrated, this is the measurement before intepretation through the curve
* `raw_unit`: The measurement units for the assay, often "secs" for clotting assays or "mE/min" from chromogenic assays
* `instrument`: The name of the instrument and the instrument serial number, separated by a space
* `filename`: The path to the file from which the data originated
* `wave`: A list column with two columns, `time` in seconds, and optical `abs`orbance in mA
