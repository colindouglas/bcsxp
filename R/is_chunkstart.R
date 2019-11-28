#' Check if a character vector is the start of an assay chunk
#'
#' This function checks if a given character vector "looks" like the start of an assay chunk from a BCS XP ASCII export
#' First it checks if the string is tab separated with a length of 2 or greater
#' If that's true, it checks if the second tab is an "S" (i.e., a sample) or a "C" (i.e., a control).
#' Returns TRUE or FALSE
#' @param chunk A vector of lines from an assay chunk
#' @param include_subassays Whether to include the subassays. Adds a subassay list column to the output. Defaults to FALSE
#' @keywords BCS XP coagulation analyzer
#' @export
#' @examples
#' is_chunkstart("507742	C		22.11.2017	10:18:35	51	FVIII.ch	000101 mE/min	% d.N.	% d.N.	1	498.565161478602	FVIII.ch_SHP	93.2837113573832") # TRUE
#' is_chunkstart("39	FactorVIIIchromogen	DeltaEMin	494.106092827486") # FALSE

is_chunkstart <- function(file) {
  line_split <- unlist(stringr::str_split(file, pattern = "\t"))
  if (length(line_split) < 2) {
    return(FALSE)
  } else {
    return(line_split[2] %in% c("S", "C"))
  }
}
