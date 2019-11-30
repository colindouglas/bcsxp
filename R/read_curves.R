#' Read a BCS XP calibration file
#'
#' This function reads an ASCII-formated calibration export file ("C-files") from a BCS XP coagulation analyzer
#' and returns the calibration data results into a tidy tibble.
#' @param path Path to the *.BCSXp file
#' @param include_subassays Adds a subassay list column to the output. Defaults to FALSE
#' @keywords BCS XP coagulation analyzer
#' @export
#' @examples
#' read_curve(path = "data/C201911271.BCSXp", include_subassays = TRUE)


read_curves <- function(chunks, include_subassays = FALSE) {

    parse_curve <- function(chunk) {
    # Store the flags separately and remove
    assay_info <- stringr::str_split(chunk[1], pattern = "\t")[[1]]
    names(assay_info) <- c("curve_name", "curve_date", "curve_time",
                           "assay_number", "assay_name", "raw_unit", "concentration_unit", "units2",
                           "repeats", "reagent_lots")
    flags <- chunk[[2]]
    supporting_points <- as.integer(chunk[3])

    points <- list()
    for (i in 1:supporting_points) {
      point <- stringr::str_split(chunk[2 + 2*i], pattern = "\t")[[1]]
      if(chunk[3 + 2*i] == "") {
        point_flags <- NA
      } else {
        point_flags <- chunk[3 + 2*i]
      }

      names(point) <- c("concentration", "raw", "calibrator_lot")
      point <- as.list(point)
      point$concentration <- as.numeric(point$concentration)
      point$raw <- as.numeric(point$raw)
      points[[i]] <- point
      points[[i]]["flags"] <- point_flags
    }
    output <- as.list(assay_info)
    output[["flags"]] <- flags
    output[["measurements"]] <- supporting_points
    output[["points"]] <- list(points)

    return(output)
  }

  curves <- purrr::map_dfr(chunks, ~ parse_curve(.))

  curves_clean <- dplyr::mutate(curves,
                                datetime = lubridate::dmy_hms(paste(curve_date, curve_time)),
                                filename = version$path)
  curves_clean <- dplyr::select(curves_clean, datetime, dplyr::everything())
  curves_clean <- dplyr::select(curves_clean, -points, dplyr::everything(), points)

  return(curves_clean)

}

