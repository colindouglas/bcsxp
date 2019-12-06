#' Read a BCS XP C-file file
#'
#' This function reads an ASCII-formated calibration export file ("C-files") from a BCS XP coagulation analyzer
#' and returns the calibration data results into a tidy tibble.
#' @param chunks A list of text from BCS XP ASCII export files, broken up into chunks
#' @param header Manually pass along the file header so it's details can be returned
#' @keywords BCS XP coagulation analyzer
#' @export

read_curves <- function(chunks, header) {

    parse_curve <- function(chunk) {
    # Store the flags separately and remove
    assay_info <- stringr::str_split(chunk[1], pattern = "\t")[[1]]
    names(assay_info) <- c("curve_name", "curve_date", "curve_time",
                           "assay_number", "assay_name", "raw_unit", "concentration_unit", "units2",
                           "repeats", "reagent_lots")
    flags <- chunk[[2]]
    supporting_points <- as.integer(chunk[3])

    points <- tibble::tibble()
    for (i in 1:supporting_points) {
      point <- stringr::str_split(chunk[2 + 2*i], pattern = "\t")[[1]]

      # The flags for this specific calibration point
      point_flags <- ifelse(chunk[3 + 2*i] == "", NA, chunk[3 + 2*i])
      names(point) <- c("concentration", "raw", "calibrator_lot")
      point <- as.list(point)
      point$concentration <- as.numeric(point$concentration)
      point$raw <- as.numeric(point$raw)
      point$flags <- ifelse(point_flags == "", NA, point_flags)
      points <- dplyr::bind_rows(points, point)
    }
    output <- as.list(assay_info)
    output[["flags"]] <- ifelse(flags == "", NA, flags)
    output[["points"]] <- list(points)

    tibble::as_tibble(output)
  }

  curves <- purrr::map_dfr(chunks, ~ parse_curve(.))

  curves_clean <- dplyr::mutate(curves,
                                datetime = lubridate::dmy_hms(paste(curve_date, curve_time)),
                                instrument = paste(header$instrument, header$serial),
                                filename = header$path)
  curves_clean <- dplyr::select(curves_clean, datetime, dplyr::everything(), -curve_date, -curve_time, -units2, -repeats)
  curves_clean <- dplyr::select(curves_clean, -points, dplyr::everything(), points)

  return(curves_clean)

}

