#' Read a BCS XP data file
#'
#' This function reads an ASCII-formated sample export file ("S-files") from a BCS XP coagulation analyzer
#' and returns the assay results into a tidy tibble.
#' @param path Path to the *.BCSXp file
#' @param include_subassays Whether to include the subassays. Adds a subassay list column to the output. Defaults to FALSE
#' @keywords BCS XP coagulation analyzer
#' @export
#' @examples
#' read_bcsxp(path = "data/S201911271.BCSXp", include_subassays = TRUE)


read_bcsxp <- function(path, include_subassays = FALSE) {
  if (file.exists(path)) {
    file <- readLines(path, warn = FALSE) # Suppress warnings because the last line is always malformed
  } else {
    stop("Path does not exist: ", path)
  }

  # Get file details from the header
  version <- unlist(stringr::str_split(file[1], pattern = "\t"))
  names(version) <- c("instrument", "file_type", "serial", "software_version", "unknown3")
  version <- c(version, path = path)
  version <- as.list(version)

  # Which element indices are the starts of chunks
  chunk_starts <- which(sapply(file, is_chunkstart, USE.NAMES = FALSE))

  # Which element indices are the last line of a chunk
  chunk_ends <- as.integer(c(tail(chunk_starts - 1, -1), length(file)-1))

  # Construct a list of chunks to map over
  chunks <- list()
  for (i in 1:length(chunk_starts)) {
    chunks[[i]] <- file[
      chunk_starts[i]:chunk_ends[i]
      ]
  }
  # Parse the assays in each chunk
  assays <- purrr::map_dfr(chunks, ~ parse_assay(., include_subassays))
  assays_clean <- dplyr::mutate(assays,
                   datetime = lubridate::dmy_hms(paste(sample_date, sample_time)),
                   sample_type = dplyr::case_when(
                     sample_type == "C" ~ "Control",
                     sample_type == "S" ~ "Sample",
                     TRUE ~ as.character(NA)),
                   instrument = paste(version$instrument, version$serial),
                   filename = version$path
  )

  # Reorder the columns
  assays_clean_narrow <- dplyr::select(assays_clean, datetime, dplyr::everything(), subassays, -sample_date, -sample_time, -unknown1, -unknown2, -units2)
  return(assays_clean_narrow)
}
