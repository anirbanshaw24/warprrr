
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cranpkgtemplate ⏲️ <a href="https://anirbanshaw24.github.io/cranpkgtemplate/"><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- badges: start -->

[![CRAN](https://www.r-pkg.org/badges/version/cranpkgtemplate)](https://CRAN.R-project.org/package=cranpkgtemplate)
[![R-CMD-check](https://github.com/anirbanshaw24/cranpkgtemplate/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/anirbanshaw24/cranpkgtemplate/actions/workflows/R-CMD-check.yml)
[![LintR-check](https://github.com/anirbanshaw24/cranpkgtemplate/actions/workflows/lintr-check.yml/badge.svg)](https://github.com/anirbanshaw24/cranpkgtemplate/actions/workflows/lintr-check.yml)
[![Spell-check](https://github.com/anirbanshaw24/cranpkgtemplate/actions/workflows/spell-check.yml/badge.svg)](https://github.com/anirbanshaw24/cranpkgtemplate/actions/workflows/spell-check.yml)
[![Test
coverage](https://github.com/anirbanshaw24/cranpkgtemplate/actions/workflows/test-coverage.yml/badge.svg)](https://github.com/anirbanshaw24/cranpkgtemplate/actions/workflows/test-coverage.yml)
[![Codecov](https://codecov.io/gh/anirbanshaw24/cranpkgtemplate/graph/badge.svg?token=JUTW42674L)](https://app.codecov.io/gh/anirbanshaw24/cranpkgtemplate)
<!-- badges: end -->

## Elegant S7-based parallel job orchestration for R

{cranpkgtemplate} provides a clean, modern interface for running
background parallel jobs using S7 classes, mirai daemon(s), and callr
process management. Perfect for computationally intensive workflows that
need robust error handling and progress monitoring.

## Features

- S7 Class System: Type-safe, modern R object system
- Parallel Processing: Efficient daemon-based parallelization via mirai
- Background Execution: Non-blocking job execution with callr::r_bg
- Error Resilience: Built-in tryCatch error handling per job
- Progress Monitoring: Console spinner with live status updates
- Flexible Configuration: Customizable daemon count and cleanup options
- Clean API: Intuitive print(), summary(), and
  run_jobs(wait_for_results) methods

## Installation

You can install the development version of cranpkgtemplate from
[CRAN](https://CRAN.R-project.org/package=cranpkgtemplate) with:

``` r
install.packages("cranpkgtemplate")
```

## Quick Start

## Advanced Usage

### Error Handling

### Background Job Arguments

### Asynchronous Execution

### Multiple Functions in Parallel and in Background

You can run multiple different functions, each with their own arguments,
in parallel background jobs using {cranpkgtemplate}. Just supply a list
of functions and a matching list of argument sets:

## Performance Tips

- Optimal Daemon Count: Start with ceiling(cores / 5), adjust based on
  workload
- Batch Size: Group small tasks to reduce overhead
- Memory Usage: Monitor with bg_args = list(supervise = TRUE)
- Error Recovery: Use tryCatch in your functions for custom error
  handling

## Dependencies

- S7: Modern object system
- mirai: High-performance parallelization
- callr: Background R processes
- purrr: Functional programming toolkit
- cli: Progress indicators
- glue: String interpolation

## Further Help & Documentation

- For full documentation, visit the [package
  website](https://anirbanshaw24.github.io/cranpkgtemplate/)
- API reference: [Reference
  manual](https://anirbanshaw24.github.io/cranpkgtemplate/reference/)
- Report issues: [GitHub
  Issues](https://github.com/anirbanshaw24/cranpkgtemplate/issues)

## Troubleshooting

- Windows: Make sure Rtools is installed for compilation.
- Linux/macOS: Ensure system build tools (gcc, make, pandoc) are
  present.
- Parallel/job failures: Check <job@results> for error output; validate
  function arguments.
- Session Info: Please include output of sessionInfo() in bug reports.

## Citation

- To cite cranpkgtemplate in publications, run:

``` r
citation("cranpkgtemplate")
#> To cite package 'cranpkgtemplate' in publications use:
#> 
#>   Shaw A (2025). _cranpkgtemplate: ToDo_. R package version 0.0.0.9000,
#>   <https://github.com/anirbanshaw24/cranpkgtemplate>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {cranpkgtemplate: ToDo},
#>     author = {Anirban Shaw},
#>     year = {2025},
#>     note = {R package version 0.0.0.9000},
#>     url = {https://github.com/anirbanshaw24/cranpkgtemplate},
#>   }
```
