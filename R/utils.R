
#' Generate a normalized package resource file path.
#'
#' Returns the normalized file path for a resource in the `cranpkgtemplate`
#'  package.
#' If the file does not exist and `allow_error = TRUE`, an error is thrown.
#'  If `allow_error = FALSE`,
#' returns an empty `fs_path` object.
#'
#' @param ... Character vectors specifying file path components within
#'  the package.
#' @param allow_error Logical. If `TRUE`, throw an error if the file
#'  is missing; otherwise, return `fs::path("")`.
#'
#' @return An `fs_path` object (normalized file path) or an empty path
#'  if missing and `allow_error = FALSE`.
#' @export
pkg_path <- function(..., allow_error = FALSE) {
  fs::path(
    system.file(
      ..., package = "cranpkgtemplate", mustWork = allow_error
    )
  )
}

load_config <- function() {
  config_file <- pkg_path(
    "constants", "constants.yml", allow_error = TRUE
  )

  if (file.exists(config_file)) {
    config::get(file = config_file)
  } else {
    warning("Config file not found in package.")
    NULL
  }
}

pkg_env <- new.env(parent = emptyenv())

get_print_constants <- function() {
  pkg_env$pkg_constants$print
}


`%>%` <- magrittr::`%>%`

#' @importFrom glue glue
#' @importFrom cli col_br_cyan
#'
dv_log_preffix <- function() {
  cli::col_br_cyan(
    glue::glue(
      "\ncranpkgtemplate @ {format(Sys.time(), '%Y-%m-%d %H:%M:%S')}: "
    )
  )
}

#' Title Log start of job controller
#'
#' @importFrom stringr str_flatten
#' @importFrom glue glue
#' @importFrom cli col_br_blue
#'
#' @export
#'
log_start <- function() {
  cat(
    cli::col_br_blue(
      glue::glue(
        stringr::str_flatten(rep(">", 13)),
        " START ",
        stringr::str_flatten(rep(">", 13)),
        "\n\n"
      )
    )
  )
}
#' Title Log end of job controller
#'
#' @importFrom stringr str_flatten
#' @importFrom glue glue
#' @importFrom cli col_br_blue
#'
#' @export
#'
log_end <- function() {
  cat(
    cli::col_br_blue(
      glue::glue(
        stringr::str_flatten(rep("<", 13)),
        " END ",
        stringr::str_flatten(rep("<", 13)),
        "\n\n"
      )
    )
  )
}

#' @importFrom glue glue
#' @importFrom cli col_br_green
#'
inform_glue <- function(..., envir = parent.frame()) {

  cat(
    cli::col_br_blue(
      glue::glue(
        "\n{dv_log_preffix()}",
        ...,
        "\n\n",
        .envir = envir
      )
    )
  )
}

#' @importFrom glue glue
#' @importFrom cli col_br_green
#'
success_glue <- function(..., envir = parent.frame()) {

  cat(
    cli::col_br_green(
      glue::glue(
        "\n{dv_log_preffix()}",
        ...,
        "\n\n",
        .envir = envir
      )
    )
  )
}

#' @importFrom glue glue
#' @importFrom cli col_br_red
#'
error_glue <- function(..., envir = parent.frame()) {

  rlang::abort(
    cli::col_br_red(
      glue::glue(
        "\n{dv_log_preffix()}",
        ...,
        "\n\n",
        .envir = envir
      )
    )
  )
}

#' @importFrom glue glue
#' @importFrom cli col_br_yellow
#'
warning_glue <- function(...) {

  cat(
    cli::col_br_yellow(
      glue::glue(
        "\n{dv_log_preffix()}",
        ...,
        "\n\n"
      )
    )
  )
}

system_glue <- function(...) {
  system(
    glue::glue(...)
  )
}
