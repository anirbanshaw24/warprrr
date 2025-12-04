
<!-- README.md is generated from README.Rmd. Please edit that file -->

# warprrr ⚡<a href="https://anirbanshaw24.github.io/warprrr/"><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- badges: start -->

[![CRAN](https://www.r-pkg.org/badges/version/warprrr)](https://CRAN.R-project.org/package=warprrr)
[![R-CMD-check](https://github.com/anirbanshaw24/warprrr/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/anirbanshaw24/warprrr/actions/workflows/R-CMD-check.yml)
[![LintR-check](https://github.com/anirbanshaw24/warprrr/actions/workflows/lintr-check.yml/badge.svg)](https://github.com/anirbanshaw24/warprrr/actions/workflows/lintr-check.yml)
[![Spell-check](https://github.com/anirbanshaw24/warprrr/actions/workflows/spell-check.yml/badge.svg)](https://github.com/anirbanshaw24/warprrr/actions/workflows/spell-check.yml)
[![Test
coverage](https://github.com/anirbanshaw24/warprrr/actions/workflows/test-coverage.yml/badge.svg)](https://github.com/anirbanshaw24/warprrr/actions/workflows/test-coverage.yml)
[![Codecov](https://codecov.io/gh/anirbanshaw24/warprrr/graph/badge.svg?token=JUTW42674L)](https://app.codecov.io/gh/anirbanshaw24/warprrr)
<!-- badges: end -->

## Overview

**warprrr** streamlines data import, validation, and caching workflows
in R by leveraging S7 classes and high-performance libraries (**arrow**,
**data.table**, **haven**).  
It supports multiple file formats, fast caching, robust configuration,
and precise timing—making it ideal for large-scale or clinical data
workflows.

## Key Features

- **Unified Data Import**: Read CSV, TSV, PSV, TXT, Parquet, Feather,
  SAS XPT/sas7bdat formats with a consistent API.
- **Smart Caching**: Automatic feather-format caching for rapid
  re-reads.
- **Flexible Backend**: Forwards arguments to backend readers such as
  `fread`, `arrow`, `haven`.
- **File Integrity & Validation**: Validates file existence and
  writability before read.
- **Precise Timing & Verbosity**: Detailed logging and timing.
- **Modern R6/S7 Architecture**: Fully S7-powered for extensibility.
- **Clinical-Grade Reliability**: Built for high-volume reporting and
  multi-format ingestion.

## Supported File Formats

| Format  | Extension | Reader Function     |
|---------|-----------|---------------------|
| CSV     | .csv      | data.table::fread   |
| TSV     | .tsv      | data.table::fread   |
| PSV     | .psv      | data.table::fread   |
| TXT     | .txt      | data.table::fread   |
| Parquet | .parquet  | arrow::read_parquet |
| Feather | .feather  | arrow::read_feather |
| SAS     | .sas7bdat | haven::read_sas     |
| SAS XPT | .xpt      | haven::read_xpt     |

Custom read arguments are forwarded automatically via `...` or
`read_fun_args`.

## Installation

``` r
install.packages("warprrr")
```

Development version:

``` r
remotes::install_github("anirbanshaw24/warprrr")
```

## Quick Start

``` r
library(warprrr)

dat <- data.frame(id = 1:3, val = c("A", "B", "C"))
utils::write.csv(dat, "test.csv", row.names = FALSE)

df1 <- read_data("test.csv", verbose = TRUE)
df2 <- read_data("test.csv", verbose = TRUE)
```

## Advanced Usage

### Pass Options to Readers

``` r
df_small <- read_data("huge.csv", nrows = 100)
```

### Custom Cache Path

``` r
df <- read_data("file.csv", cache_path = tempdir())
```

### Timing Reads

``` r
timing <- time_taken_precise({ read_data("test.csv") })
print(timing)
```

## Programmatic Example

``` r
files <- c("study1.csv", "study2.parquet", "study3.sas7bdat")
result_list <- purrr::map(files, ~read_data(.x))
```

## Parallel Background Ingestion

``` r
jobs <- lapply(files, function(f)
  callr::r_bg(read_data, list(data_path = f))
)
lapply(jobs, function(job) job$get_result())
```

## Troubleshooting

- Validate file paths with `fs::file_exists()`
- Ensure cache_path is writable
- Check error for unsupported formats
- Prefer Parquet/Feather for very large files

## Further Help

- Homepage & documentation  
- API reference  
- Issues  
- Citation: `citation("warprrr")`
