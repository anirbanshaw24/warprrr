
#' Print a Summary of warprrr Object
#'
#' Displays a compact, formatted summary of key fields in a warprrr object:
#' data path (with existence status), data format, read function (with arguments),
#' cache directory, cache extension, and cache file status.
#'
#' Output is designed for clear viewing in R consoles, logs, or shiny app outputs.
#'
#' @param warper A `warprrr` S7 object containing data wrangling and caching configuration.
#'
#' @return Invisibly returns the input `warprrr` object.
#' @seealso [warprrr]
#' @keywords internal
S7::method(print, warprrr) <- function(warper) {
  # Check if data file exists
  data_exists <- fs::file_exists(warper@data_path)
  existence <- if (data_exists) "✅ exists" else "❌ missing"
  # Gather full cache file existence
  cache_exists <- fs::file_exists(warper@cache_full_file_path)
  cache_existence <- if (cache_exists) "✅ (present)" else "❌ (not present)"

  # Build read_fun call
  args_str <- if (length(warper@read_fun_args) == 0) {
    ""
  } else {
    paste(
      lapply(names(warper@read_fun_args), function(nm) {
        arg <- warper@read_fun_args[[nm]]
        # Quote if character, literal if not
        if (is.character(arg)) paste0(nm, " = '", arg, "'")
        else paste0(nm, " = ", toString(arg))
      }),
      collapse = ", "
    )
  }

  read_fun <- switch(
    warper@file_ext,
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
    "  Data Path      : ", warper@data_path, " [", existence, "]\n",
    "  Data Format    : ", warper@file_ext, "\n",
    "  Read Command   : ", read_fun, "(\n    '", warper@data_path, "'",
    if (args_str != "") paste0(", ", args_str), "\n  )\n", sep = ""
  )
  cat(
    "  Cache Dir      : ", warper@cache_path, "\n",
    "  Cache Ext      : ", warper@cache_ext, "\n",
    # "  Cache File     : ", warper@cache_full_file_path, " [", cache_existence, "]\n",
    sep = ""
  )
  invisible(warper)
}
