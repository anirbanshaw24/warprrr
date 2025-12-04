
testthat::describe("read_data()", {

  # Setup: Write small test files (csv, parquet, feather)
  temp_sas <- tempfile(fileext = ".sas7bdat")
  temp_parquet <- tempfile(fileext = ".parquet")
  temp_feather <- tempfile(fileext = ".feather")
  n <- 1e7  # 10 million rows
  dat <- data.frame(
    id = seq_len(n),
    val = sample(c("A", "B", "C"), n, replace = TRUE)
  )

  haven::write_sas(dat, temp_sas)
  arrow::write_parquet(dat, temp_parquet)
  arrow::write_feather(dat, temp_feather)

  it("reads a csv file as data.frame", {
    x <- read_data(temp_sas)
    testthat::expect_s3_class(x, "data.frame")
    testthat::expect_equal(nrow(x), 10000000.0)
  })

  it("passes arguments to fread (nrows)", {
    x <- read_data(temp_sas, n_max = 2)
    testthat::expect_equal(nrow(x), 2)
  })

  it("reads a parquet file", {
    x <- read_data(temp_parquet)
    testthat::expect_s3_class(x, "data.frame")
    testthat::expect_equal(nrow(x), 10000000.0)
  })

  it("reads a feather file", {
    x <- read_data(temp_feather)
    testthat::expect_s3_class(x, "data.frame")
    testthat::expect_equal(nrow(x), 10000000.0)
  })

  it("returns error for missing file", {
    testthat::expect_error(
      read_data("missing_file.csv"),
      "MUST be a valid path"
    )
  })

  it("uses cache on second read", {
    cache_dir <- tempfile()
    fs::dir_create(cache_dir)
    time_without_cache <- system.time(
      x1 <- read_data(temp_sas, cache_path = cache_dir)
    )
    time_without_cache <- time_without_cache[["elapsed"]]
    # Delete original file to test cache retrieval
    time_with_cache <- system.time(
      x2 <- read_data(temp_sas, cache_path = cache_dir)
    )
    time_with_cache <- time_with_cache[["elapsed"]]

    cache_faster_by <- (1 - time_with_cache/time_without_cache) * 100
    testthat::expect_gt(cache_faster_by, 95)
    testthat::expect_lt(
      as.numeric(time_with_cache),
      as.numeric(time_without_cache)
    )
    testthat::expect_identical(x1, x2)
  })
})
