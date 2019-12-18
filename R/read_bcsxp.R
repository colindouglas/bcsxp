#' Read a BCS XP data file
#'
#' This function reads an ASCII-formated sample export file ("S-files") from a BCS XP coagulation analyzer
#' and returns the assay results into a tidy tibble.
#' @param path Path to the *.BCSXp file
#' @param filetype The type of file to be read. One of c("S", "C", or "guess").
#' @param include_subassays Adds a subassay list column to the output. Defaults to FALSE
#' @keywords BCS XP coagulation analyzer
#' @importFrom graphics points
#' @importFrom utils tail
#' @importFrom stringr str_split
#' @importFrom purrr map2
#' @export

 read_bcsxp <- function(path, filetype = "guess", include_subassays = FALSE) {
  if (file.exists(path)) {
    file <- readLines(path, warn = FALSE) # Suppress warnings because the last line is always malformed
  } else {
    stop("Path does not exist: ", path)
  }

  # Get file details from the header
  header <- unlist(str_split(file[1], pattern = "\t"))
  names(header) <- c("instrument", "filetype", "serial", "software_version", "unknown3")
  header <- c(header, path = path)
  header <- as.list(header)

  # Guessing the type of file from the file
  if (tolower(filetype) == "guess") {
    # Check if the header gives the filetype
    # Stored in the first line as the second TSV
    firstchar_header <- tolower(
      substring(tolower(header$filetype), first = 1, last = 1)
    )

    # If the header specifies file type, move on
    if (firstchar_header %in% c("s", "c", "r")) {
      filetype <- firstchar_header
    } else {
      # If the header doesn't specify filetype, warn and try to guess it from the path
      filename <- tail(str_split(path, pattern = "/")[[1]], 1)
      firstchar_filename <- tolower(substring(filename, first = 1, last = 1))
      if (firstchar_filename %in% c("s", "c", "r")) {
        filetype <- firstchar_filename
        warning("Guessing file type from path: ", path)
      } else {
        # If can't guess filetype from header or path, stop.
        stop("Unable to guess file type from header or path. Is it a *.BCSXp file?")
      }
    }
  }

  # Which element indices are the starts of chunks
  chunk_starts <- which(unlist(is_chunkstart(file)))

  # Which element indices are the last line of a chunk
  chunk_ends <- as.integer(c(tail(chunk_starts - 1, -1), length(file)-1))

  chunks <- map2(chunk_starts, chunk_ends, ~ file[.x:.y])

# use read_assays() to read S-files
  if (filetype == "s") {
    return(
      read_assays(chunks, include_subassays, header)
    )
  }
  # Use read_curves() to read C-files
  if (filetype == "c") {
    return(
      read_curves(chunks, header)
    )
  }
  # Ise read_rawfiles to read R-files
  if (filetype == "r") {
    return(
      read_rawfile(chunks, header)
    )
  }

}
