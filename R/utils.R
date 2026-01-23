
#' Generate a normalized package resource file path.
#'
#' Returns the normalized file path for a resource in the `warprrr`
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
pkg_path <- function(..., allow_error = FALSE) {
  fs::path(
    system.file(
      ..., package = "warprrr", mustWork = allow_error
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
      "\nwarprrr @ {format(Sys.time(), '%Y-%m-%d %H:%M:%S')}: "
    )
  )
}

#' Title Log start of job controller
#'
#' @importFrom stringr str_flatten
#' @importFrom glue glue
#' @importFrom cli col_br_blue
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

#' Print a formatted, blue-colored glue message
#'
#' Uses \code{glue} for string interpolation and \code{cli} for colored output.
#'
#' @param ... Arguments passed to \code{glue::glue()} for formatting.
#' @param envir Environment passed to \code{glue::glue}.
#'  Default is \code{parent.frame()}.
#'
#' @importFrom glue glue
#' @importFrom cli col_br_blue
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
    ), call = rlang::caller_call(1)
  )
}

log_message <- function(..., envir = parent.frame()) {
  msg <- glue::glue(
    "\n{dv_log_preffix()}",
    ...,
    "\n\n",
    .envir = envir
  )
  msg
}

#' @importFrom glue glue
#' @importFrom cli col_br_yellow
#'
warning_glue <- function(..., envir = parent.frame()) {

  cat(
    cli::col_br_yellow(
      log_message(..., envir = envir)
    )
  )
  glue::glue(
    paste0(unlist(list(...)), collapse = ""),
    .envir = envir
  )
}

system_glue <- function(..., envir = parent.frame()) {
  system(
    glue::glue(..., .envir = envir)
  )
}

#' Measure Precise Evaluation Time
#'
#' Returns elapsed time in seconds (to six decimals) for the given expression.
#' @param expr Expression to be evaluated.
#' @return Numeric value: elapsed time in seconds.
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
inform_glue_verbose <- function(..., verbose, envir = parent.frame()) {
  if (verbose) inform_glue(..., envir = envir) # nolint
}

