
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
#' @return A named list of the form: list(data = data, warprrr = warprrr_class).
#'  warprrr class can be used to observe or use the properties of this instance
#'   of warprrr.
#' @export
#'
read_data <- function(
    data_path,
    cache_path = file.path(tools::R_user_dir("warprrr", which = "cache")),
    verbose = FALSE, ...) {
  read_fun_args <- list(...)
  warpr <- warprrr(
    data_path = data_path,
    cache_path = cache_path,
    read_fun_args = read_fun_args
  )
  list(
    data = warpr |>
      get_data(verbose = verbose),
    warprrr = warpr
  )
}
