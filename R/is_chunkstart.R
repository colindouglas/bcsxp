#' Check if a character vector is the start of an assay chunk
#'
#' This function checks if a given character vector "looks" like the start of an assay chunk from a BCS XP ASCII export
#' First it checks if the string is tab separated with a length of 2 or greater
#' If that's true, it checks if the second tab is an "S" (i.e., a sample) or a "C" (i.e., a control).
#' Returns TRUE or FALSE
#' @param x A character string
#' @keywords BCS XP coagulation analyzer
#' @importFrom purrr map
#' @export

is_chunkstart <- function(x) {
  line_split <- strsplit(x, split = "\t")
  map(line_split, function(y) {
    if (length(y) < 2) {
      return(FALSE)
    } else {
      return(
        y[2] == "S" | y[2] == "C" | # matching in S files
          y[3] == "S" | y[3] == "C" | # matching in R files
          grepl("[0-9]{2}\\.[0-9]{2}\\.[0-9]{4}", y[2]) # matching in C files
      )
    }
  })
}
