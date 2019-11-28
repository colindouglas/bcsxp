#' Parse an assay in an exported BCS XP ASCII file
#'
#' This function parses an assay chunk from a BCS XP ASCII file. It is called from read_bcsxp()
#' and probably doesn't need to be called on it's own. Returns a list of assay parameters.
#' @param chunk A vector of lines from an assay chunk
#' @param include_subassays Whether to include the subassays. Adds a subassay list column to the output. Defaults to FALSE
#' @keywords BCS XP coagulation analyzer
#' @export
#' @examples
#' parse_assay(readLines(path = "data/S201911271.BCSXp")[3:7])

parse_assay <- function(chunk, include_subassays = FALSE) {
  assay_info <- stringr::str_split(chunk[1], pattern = "\t")[[1]]
  names(assay_info) <- c("sample_name", "sample_type", "unknown1", "sample_date", "sample_time",
                         "assay_number", "assay_name", "reagent_lots", "raw_unit",
                         "result_unit", "units2", "unknown2", "raw", "calibration_curve", "result")
  output <- as.list(assay_info)
  output[["flags"]] <- ifelse(chunk[2] == "", NA, chunk[2])
  if (include_subassays) {
    subassay_count <- as.numeric(chunk[3])

    subassay_repeats <- 0
    subassays <- list()
    for (j in 1:subassay_count) {
      subassay_start <- 4 + (j - 1)*2 + subassay_repeats
      info <- unlist(stringr::str_split(chunk[subassay_start], pattern = "\t"))
      names(info) <- c("number", "name", "endpoint", "raw")
      subassays[[j]] <- as.list(info)
      subassay_repeats <- as.numeric(chunk[subassay_start + 1])

      subassays[[j]][["repeats"]] <- list()
      for (i in 1:subassay_repeats) {
        this_repeat <- unlist(stringr::str_split(chunk[subassay_start + 1 + i], pattern = "\t"))
        names(this_repeat) <- c("id", "raw")
        subassays[[j]][["repeats"]][[i]] <- as.list(this_repeat)
      }
    }
    output[["subassays"]] <- list(subassays)
  }
  return(output)
}
