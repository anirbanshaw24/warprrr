
#' Print a Summary of warprrr Object
#'
#' Displays a compact, formatted summary of key fields in a warprrr object:
#' data path (with existence status), data format, read function (with arguments),
#' cache directory, cache extension, and cache file status.
#'
#' Output is designed for clear viewing in R consoles, logs, or shiny app outputs.
#'
#' @name print
#' @param x A `warprrr` S7 object containing data wrangling and caching configuration.
#' @param ... Further arguments passed to or from other methods (ignored).
#' @return Invisibly returns the input `warprrr` object.
#' @seealso [warprrr]
#' @keywords internal
S7::method(print, warprrr) <- function(x, ...) {
  # Check if data file exists
  data_exists <- fs::file_exists(x@data_path)
  existence <- if (data_exists) "[OK] exists" else "[X] missing"

  # Gather full cache file existence
  cache_exists <- fs::file_exists(x@cache_full_file_path)
  cache_existence <- if (cache_exists) "[OK] (present)" else "[X] (not present)"

  # Build read_fun call
  args_str <- if (length(x@read_fun_args) == 0) {
    ""
  } else {
    paste(
      lapply(names(x@read_fun_args), function(nm) {
        arg <- x@read_fun_args[[nm]]
        # Quote if character, literal if not
        if (is.character(arg)) paste0(nm, " = '", arg, "'")
        else paste0(nm, " = ", toString(arg))
      }),
      collapse = ", "
    )
  }

  read_fun <- switch(
    x@file_ext,
    csv = "data.table::fread",
    tsv = "data.table::fread",
    psv = "data.table::fread",
    txt = "data.table::fread",
    sas7bdat = "haven::read_sas",
    xpt = "haven::read_xpt",
    parquet = "arrow::read_parquet",
    feather = "arrow::read_feather",
    "UNSUPPORTED"
  )

  cat(
    "\n<warprrr::warprrr>\n",
    "  Data Path      : `", x@data_path, "` [", existence, "]\n",
    "  Data Format    : `", x@file_ext, "`\n",
    "  Read Command   : ```", read_fun, "(\n    '", x@data_path, "'",
    if (args_str != "") paste0(", ", args_str), "\n  )```\n", sep = ""
  )
  cat(
    "  Cache Dir      : `", x@cache_path, "`\n",
    "  Cache Ext      : `", x@cache_ext, "`\n",
    # "  Cache File     : ", x@cache_full_file_path, " [", cache_existence, "]\n",
    sep = ""
  )
  invisible(x)
}
