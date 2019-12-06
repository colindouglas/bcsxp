#' Read a BCS XP R-file file
#'
#' This function reads an ASCII-formated raw data file ("R-files") from a BCS XP coagulation analyzer
#' and returns the details on the assay, as well as a list column that contains absorbance vs. time curves
#' @param path Path to the *.BCSXp file
#' @param header Manually pass along the file header so it's details can be returned
#' @keywords BCS XP coagulation analyzer
#' @export

read_rawfile <- function(chunks, header) {

  # Parse a chunk (representing a single assay) into a tidy row
  parse_raw <- function(chunk) {

    # The first line is the descriptive data for the assay
    raw_info <- stringr::str_split(chunk[1], pattern = "\t", simplify = TRUE)
    names(raw_info) <- c("id", "sample_name", "sample_type", "assay_number",
                           "assay_name", "assay_date", "assay_time")
    output <- tibble::as_tibble(as.list(raw_info))

    # The second line is the reagent lots
    output$reagent_lots <- chunk[2]
    output$cuvette <- chunk[3]
    output$flags <- ifelse(chunk[7] == "", NA, chunk[7])

    # I don't know what these are!
    output$unknown4 <- chunk[4]
    output$unknown5 <- chunk[5]

    # Sixth line describes how the measurements were made
    raw_result <- stringr::str_split(chunk[6], pattern = "\t", simplify = TRUE)
    names(raw_result) <- c("detection method", "raw", "raw_unit")
    output <- dplyr::bind_cols(output, as.list(raw_result))

    # Eighth line describes how many individual measurements there are in the curve
    raw_measurements <- as.numeric(chunk[8])

    measurements <- tibble::tibble()
    for (i in 1:raw_measurements) {
      measurement <- stringr::str_split(chunk[8 + i], pattern = "\t", simplify = TRUE)
      names(measurement) <- c("time", "abs")
      measurements <- dplyr::bind_rows(measurements, as.list(measurement))
    }

    output$wave <- list(measurements)
    return(output)

  }

  raw <- purrr::map_dfr(chunks, ~ parse_raw(.))

  raw_clean <- dplyr::mutate(raw,
                                datetime = lubridate::dmy_hms(paste(assay_date, assay_time)),
                                sample_type = dplyr::case_when(
                                  sample_type == "C" ~ "Control",
                                  sample_type == "S" ~ "Sample",
                                  TRUE ~ as.character(NA)),
                                instrument = paste(header$instrument, header$serial),
                                filename = header$path
  )

  # Reorder the columns
  raw_clean <- dplyr::select(raw_clean, datetime, dplyr::everything(), -assay_date, -assay_time, -unknown4, -unknown5)
  raw_clean <- dplyr::select(raw_clean, -wave, dplyr::everything())

}