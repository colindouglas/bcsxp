#' Read a BCS XP data file
#'
#' This function reads an ASCII-formated sample export file ("S-files") from a BCS XP coagulation analyzer
#' and returns the assay results into a tidy tibble.
#' @param path Path to the *.BCSXp file
#' @param include_subassays Adds a subassay list column to the output. Defaults to FALSE
#' @keywords BCS XP coagulation analyzer
#' @export
#' @examples
#' read_bcsxp(path = "data/S201911271.BCSXp", include_subassays = TRUE)


read_bcsxp <- function(path, filetype = "guess", include_subassays = FALSE) {
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

  if (filetype == "guess") {
    filename <- tail(stringr::str_split(path, pattern = "/")[[1]], 1)
    first_char <- substring(filename, first = 1, last = 1)

    if (first_char %in% c("S", "C")) {
      filetype <- first_char
    } else {
      stop("Unable to guess filetype of ", filename)
    }
  }

  if (filetype == "S") {
    return(
      read_assays(chunks, include_subassays, version)
    )
  }
  if (filetype == "C") {
    return(
      read_curves(chunks, version)
    )
  }

}
