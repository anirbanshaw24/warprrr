
utils::globalVariables(
  c("warprrr", "get_data", "inform_glue")
)

#' Title
#'
#' @param data_path The path to data. csv, psv, tsv, parquet, feather, txt,
#' sas7bdat, xpt file formats are supported
#' @param ... Arguments passed onto the respective read function. csv, psv, tsv,
#' txt, is read with data.table::fread. sas7bdat and xpt are read with
#' haven::read_sas and haven::read_xpt respectively. parquet and feather
#' are read with arrow::read_parquet and arrow::read_feather respectively.
#' Arguments can be passed to these functions via this argument.
#' @param cache_path The path to use to store the cache.
#' @param verbose Whether to print logs, time taken to read non-cached vs
#'  cached data etc.
#'
#' @return
#'   A named list:
#'   \describe{
#'     \item{data}{The loaded data frame.}
#'     \item{warprrr}{An S7 class instance containing file paths, caching info, file status,
#'       hash (for cache), and accessors to underlying properties.}
#'   }
#'
#' - **`data`**: The data frame loaded from `data_path`, ready for analysis.
#' - **`warprrr`**: S7 class with properties for inspecting file info, cache status, and managing caching.
#'
#' The `warprrr` object exposes properties:
#' - `data_path`, `read_fun_args`, `cache_path`: *Configurable* (can be set at creation)
#' - `file_ext`, `file_info`, `cache_hash`, `cache_ext`, `cache_hash_file_name`, `cache_full_file_path`: *Read-only*, auto-computed via getter methods—cannot be manually changed.
#'
#' Use the class to inspect file characteristics, ensure reproducible caching, and track metadata for pipelines.
#'
#' See `warprrr` class documentation for property details and intended usage.
#'
#' @export
#'
read_data <- function(
    data_path,
    cache_path = NULL,
    verbose = FALSE, ...) {
  if (is.null(cache_path)) {
    cache_path <- file.path(tools::R_user_dir("warprrr", which = "cache"))
  }
  read_fun_args <- list(...)
  warpr <- warprrr( # nolint
    data_path = data_path,
    cache_path = cache_path,
    read_fun_args = read_fun_args
  )
  list(
    data = warpr |>
      get_data(verbose = verbose), # nolint
    warprrr = warpr
  )
}
