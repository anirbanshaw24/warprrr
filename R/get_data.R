
get_data <- S7::new_generic("get_data", c("warper", "verbose"))
#' Generic Data fetcher for warprrr Class
#'
#' Loads data from cache if available, otherwise reads source and caches result.
#'
#' @param warper warprrr object.
#' @param verbose Print detailed messages if TRUE.
#' @return Data.table, tibble, or arrow table, as appropriate.
#' @noRd
#'
#' @importFrom arrow read_feather write_feather
#' @importFrom fs file_exists
#' @importFrom glue glue
#'
S7::method(get_data, list(warprrr, S7::class_logical)) <- function(
    warper, verbose) {
  if (fs::file_exists(warper@cache_full_file_path)) {
    inform_glue_verbose(
      "Cache found! ",
      "Reading from cache.",
      verbose = verbose
    )
    time_taken <- time_taken_precise({ # nolint
      data <- arrow::read_feather(warper@cache_full_file_path)
    })
    inform_glue_verbose(
      "Cached Data Read in [ {time_taken} secs ].",
      verbose = verbose
    )
    data
  } else {
    inform_glue_verbose(
      "Reading `{warper@data_path}`.",
      verbose = verbose
    )
    time_taken <- time_taken_precise(
      data <- read_data_multi_format(
        warper@file_ext, warper@data_path, warper@read_fun_args
      )
    )
    inform_glue_verbose(
      "Non-Cached Data Read in [ {time_taken} secs ].",
      verbose = verbose
    )
    cache_time_taken <- time_taken_precise( # nolint
      arrow::write_feather(
        data, warper@cache_full_file_path
      )
    )
    inform_glue_verbose(
      "Data cached in [ {cache_time_taken} secs ].",
      verbose = verbose
    )
    data
  }
}
