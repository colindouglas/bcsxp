#' Check if a character vector is the start of an assay chunk
#'
#' This function checks if a given character vector "looks" like the start of an assay chunk from a BCS XP ASCII export
#' First it checks if the string is tab separated with a length of 2 or greater
#' If that's true, it checks if the second tab is an "S" (i.e., a sample) or a "C" (i.e., a control).
#' Returns TRUE or FALSE
#' @param x A character string
#' @keywords BCS XP coagulation analyzer
#' @export

is_chunkstart <- function(x) {
  line_split <- unlist(stringr::str_split(x, pattern = "\t"))
  if (length(line_split) < 2) {
    return(FALSE)
  } else {
    return(
      line_split[2] %in% c("S", "C") | # matching in S files
        grepl("[0-9]{2}\\.[0-9]{2}\\.[0-9]{4}", line_split[2]) # matching in C files
    )
  }
}
