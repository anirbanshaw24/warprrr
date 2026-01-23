
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
warprrr <- S7::new_class(
  "warprrr",
  package = "warprrr",
  properties = list(
    data_path = S7::new_property(
      class = S7::class_character,
      validator = function(value) {
        file_ext <- fs::path_ext(value)
        supported_files <- c(
          "csv", "tsv", "psv", "txt", "sas7bdat", "xpt", "parquet", "feather"
        )
        if (!file_ext %in% supported_files) {
          return(
            warning_glue(
              "`{file_ext}` files are not supported. ",
              "Supported formats are: ",
              "{paste0(supported_files, collapse = ', ')}"
            )
          )
        }
        NULL
      }
    ),
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
