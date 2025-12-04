
#' Title
#'
#' @param data_path The path to data. csv, psv, tsv, parquet, feather, txt,
#' sas7bdat, xpt file formats are supported
#' @param ... Arguments passed onto the respective read function. csv, psv, tsv,
#' txt, is read with data.table::fread. sas7bdat and xpt are read with
#' haven::read_sas and haven::read_xpt respectively. parquet and feather
#' are read with arrow::read_parquet and arrow::read_feather respectively.
#' Arguments can be passed to these functions via this argument.
#'
#' @return An object of class data.frame.
#' @export
#'
read_data <- function(data_path, verbose = FALSE, ...) {
  warpr <- warprrr(
    data_path = data_path,
    read_fun_args = list(
      ...
    )
  )
  warpr |>
    get_data(verbose = verbose)
}
