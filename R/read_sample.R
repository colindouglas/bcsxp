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
