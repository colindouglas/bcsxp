#' Read a BCS XP S-file file
#'
#' This function reads an ASCII-formated sample export file ("S-files") from a BCS XP coagulation analyzer
#' and returns the assay results into a tidy tibble.
#' @param chunks A list of text from BCS XP ASCII export files, broken up into chunks
#' @param include_subassays Adds a subassay list column to the output. Defaults to FALSE
#' @param header Manually pass along the file header so it's details can be returned
#' @keywords BCS XP coagulation analyzer
#' @export

read_assays <- function(chunks, include_subassays = FALSE, header) {

  # Parse a chunk (representing a single assay) into a tidy row
  parse_assay <- function(chunk, include_subassays = FALSE) {

    # The first line is the bulk of the data
    assay_info <- stringr::str_split(chunk[1], pattern = "\t")[[1]]
    names(assay_info) <- c("sample_name", "sample_type", "unknown1", "sample_date", "sample_time",
                           "assay_number", "assay_name", "reagent_lots", "raw_unit",
                           "result_unit", "units2", "unknown2", "raw", "calibration_curve", "result")
    output <- tibble::as_tibble(as.list(assay_info))

    # Second line is assay flags
    output$flags <- ifelse(chunk[2] == "", NA, chunk[2])

    # If the argument was called with the include_subassay flags, parse all of the subassays
    if (include_subassays) {
      subassay_count <- as.numeric(chunk[3])
      subassay_repeats <- 0
      subassays <- tibble::tibble()
      for (j in 1:subassay_count) {
        # TODO: I don't know if this math holds up with > 2 subassays
        subassay_start <- 4 + (j - 1)*2 + subassay_repeats
        info <- unlist(stringr::str_split(chunk[subassay_start], pattern = "\t"))
        names(info) <- c("number", "name", "endpoint", "raw")
        subassays <- dplyr::bind_rows(subassays, as.list(info))
        subassay_repeats <- as.numeric(chunk[subassay_start + 1])

        repeats <- tibble::tibble()
        for (i in 1:subassay_repeats) {
          this_repeat <- unlist(stringr::str_split(chunk[subassay_start + 1 + i], pattern = "\t"))
          names(this_repeat) <- c("id", "raw")
          repeats <- dplyr::bind_rows(repeats, this_repeat)
        }
        subassays <- dplyr::mutate(subassays, repeats = list(repeats))
      }
      output <- dplyr::mutate(output, subassays = list(subassays))
    }
    output
  }


  assays <- purrr::map_dfr(chunks, ~ parse_assay(., include_subassays))
  assays_clean <- dplyr::mutate(assays,
                                datetime = lubridate::dmy_hms(paste(sample_date, sample_time)),
                                sample_type = dplyr::case_when(
                                  sample_type == "C" ~ "Control",
                                  sample_type == "S" ~ "Sample",
                                  TRUE ~ as.character(NA)),
                                instrument = paste(header$instrument, header$serial),
                                filename = header$path
  )

  # Reorder the columns
  assays_clean <- dplyr::select(assays_clean, datetime, dplyr::everything(), -sample_date, -sample_time, -unknown1, -unknown2, -units2)
  if (include_subassays) {
    assays_clean <- dplyr::select(assays_clean, -subassays, dplyr::everything(), subassays)
  }

  return(assays_clean)
}
