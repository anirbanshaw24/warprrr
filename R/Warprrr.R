
#' warprrr S7 Class for Data Wrangling and Caching
#'
#' Defines an S7 class that handles data loading and on-disk caching
#' using Parquet format where applicable.
#'
#' @param data_path Path to the input data file. Supported formats include
#'   CSV, PSV, TSV, TXT, Parquet, Feather, SAS7BDAT, and XPT.
#'
#' @param read_fun_args A named list of arguments passed to the underlying
#'   reader function. CSV, PSV, TSV, and TXT files are read using
#'   \code{data.table::fread()}. SAS7BDAT and XPT files are read using
#'   \code{haven::read_sas()} and \code{haven::read_xpt()}, respectively.
#'   Parquet and Feather files are read using
#'   \code{arrow::read_parquet()} and \code{arrow::read_feather()}.
#'
#' @param cache_path Path to the cache directory.
#'
#' @importFrom S7 new_class class_character new_property new_generic
#'   S7_dispatch method
#' @importFrom fs is_dir dir_create file_access path_ext file_info
#'   path_abs file_exists
#' @importFrom digest digest
#' @importFrom glue glue
#' @importFrom data.table fread
#' @importFrom haven read_sas read_xpt
#' @importFrom arrow read_parquet read_feather
#' @export
warprrr <- S7::new_class(
  "warprrr",
  package = "warprrr",
  properties = list(
    data_path = S7::class_character,
    read_fun_args = S7::class_list,
    cache_path = S7::new_property(
      class = S7::class_character,
      validator = function(value) {
        if (!fs::is_dir(value)) {
          fs::dir_create(value)
        }
        if (!fs::file_access(value, "write")) {
          "Cache folder is not writable!"
        }
      }
    ),
    file_ext = S7::new_property(
      getter = function(self) {
        fs::path_ext(
          self@data_path
        )
      }
    ),
    file_info = S7::new_property(
      getter = function(self) {
        fs::file_info(
          self@data_path
        )
      }
    ),
    cache_hash = S7::new_property(
      getter = function(self) {
        digest::digest(
          list(
            self@data_path,
            self@read_fun_args,
            self@file_info
          )
        )
      }
    ),
    cache_ext = S7::new_property(
      class = S7::class_character,
      getter = function(self) {
        ".feather"
      },
      validator = function(value) {
        switch(
          value,
          ".feather" = {
            NULL
          },
          {
            "Cache extension must be a .feather file."
          }
        )
      }
    ),
    cache_hash_file_name = S7::new_property(
      getter = function(self) {
        glue::glue(
          "{self@cache_hash}{self@cache_ext}"
        )
      }
    ),
    cache_full_file_path = S7::new_property(
      getter = function(self) {
        fs::path_abs(
          glue::glue(
            "{self@cache_path}/{self@cache_hash_file_name}"
          )
        )
      }
    ),
    data_object = S7::new_property(
      getter = function(self) {
        switch(
          self@file_ext,
          csv = {
            do.call(
              data.table::fread,
              c(list(self@data_path), self@read_fun_args)
            )
          },
          tsv = {
            do.call(
              data.table::fread,
              c(list(self@data_path), self@read_fun_args)
            )
          },
          psv = {
            do.call(
              data.table::fread,
              c(list(self@data_path), self@read_fun_args)
            )
          },
          txt = {
            do.call(
              data.table::fread,
              c(list(self@data_path), self@read_fun_args)
            )
          },
          sas7bdat = {
            do.call(
              haven::read_sas,
              c(list(self@data_path), self@read_fun_args)
            )
          },
          xpt = {
            do.call(
              haven::read_xpt,
              c(list(self@data_path), self@read_fun_args)
            )
          },
          parquet = {
            do.call(
              arrow::read_parquet,
              c(list(self@data_path), self@read_fun_args)
            )
          },
          feather = {
            do.call(
              arrow::read_feather,
              c(list(self@data_path), self@read_fun_args)
            )
          },
          {
            error_glue(
              "{self@file_ext} files are not supported."
            )
          }
        )
      }
    )
  ),
  validator = function(self) {
    if (!fs::file_exists(self@data_path)) {
      "@data_path MUST be a valid path to file that exists."
    }
  },
  constructor = function(
    data_path,
    read_fun_args = list(),
    cache_path = NULL) {
    if (is.null(cache_path)) {
      cache_path <- file.path(tools::R_user_dir("warprrr", which = "cache"))
    }

    S7::new_object(
      S7::S7_object(),
      data_path = data_path,
      cache_path = cache_path,
      read_fun_args = read_fun_args
    )
  }
)

#' Measure Precise Evaluation Time
#'
#' Returns elapsed time in seconds (to six decimals) for the given expression.
#' @param expr Expression to be evaluated.
#' @return Numeric value: elapsed time in seconds.
#' @examples
#' time_taken_precise({Sys.sleep(1)})
#' @export
time_taken_precise <- function(expr) {
  start <- proc.time()
  eval(expr)
  end <- proc.time()
  elapsed <- (end - start)["elapsed"]
  elapsed_precise <- format(elapsed, digits = 6, nsmall = 6)
  as.numeric(elapsed_precise)
}

#' Verbose Informational Message with glue
#'
#' Optionally prints a glue message if verbose is TRUE.
#'
#' @param ... Message arguments for glue.
#' @param envir The parent env when func is called. Required for glue to work.
#' @param verbose Logical; print message if TRUE.
#'
#' @return Invisible NULL.
#' @importFrom glue glue
#' @export
inform_glue_verbose <- function(..., verbose, envir = parent.frame()) {
  if (verbose) inform_glue(..., envir = envir) # nolint
}

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
#' @export
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
      data <- warper@data_object
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
