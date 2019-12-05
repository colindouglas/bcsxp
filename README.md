# Read BCS XP Results Files

This package reads ASCII sample files ("S-files") and calibration files ("C-files") exported from BCS XP coagulation analyzers, and returns a tidy row-wise dataframe. It can also read the subassays for each assay, and return a list column containing the results.

Currently, the package is not able to read raw data ("R-files") or data exported in XML format.

Data for the tests are not included in the repo.

## Installation 

```r
# install.packages("devtools")
devtools::install_github("colindouglas/bcsxp")
```
## Usage

### Reading an S-File
`read_bcsxp(path, filetype = "S")` reads in a exported ASCII file containing data on samples and controls, typically named "S*yyyymmddn*.BCSXp". It returns a tibble with the following columns:

* `datetime`: The date and time the assay finished
* `sample_name`: The name of the sample on the instrument. For controls, it is the control lot number
* `sample_type`: Either "Sample" or "Control"
* `assay_number`: The number uniquely identifying the assay performed. Manufacturer assays < 1000.
* `assay_name`: The short name identifying the assay
* `reagent_lots`: The lot numbers of the reagents used to perform the assay, separated by spaces
* `raw_unit`: The measurement units for the assay, often "secs" for clotting assays or "mE/min" from chromogenic assays
* `result_unit`: The units of the assay output. Often "secs" or "%d.N." for factor assays.
* `raw`: The raw measurement, in units of `raw_unit`. If the assay is calibrated, this is the measurement before intepretation through the curve
* `calibration_curve`: The calibration curve through which the raw measurement is interpreted
* `result`: The output of the assay, in units of `result_unit`. If the assay is calibrated, this is the `raw` interpreted through `calibration_curve`
* `flags`: These are warning or error flags that the assay raised
* `instrument`: The name of the instrument and the instrument serial number, separated by a space
* `filename`: The path to the file from which the data originated
* `subassays`: If the function is called with `subassays = TRUE`, this is a list column containing the details of the assays-within-the-assay.

### Reading a C-File
`read_bcsxp(path, filetype = "C")` reads in a exported ASCII file containing data on calibration curves, typically named "C*yyyymmddn*.BCSXp". It returns a tibble with the following columns:

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
