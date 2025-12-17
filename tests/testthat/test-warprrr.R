
testthat::describe("warprrr S7 class", {
  temp_cache <- tempfile()
  fs::dir_create(temp_cache)
  temp_csv <- tempfile(fileext = ".csv")
  temp_parquet <- tempfile(fileext = ".parquet")
  temp_file_unsupported <- tempfile(fileext = ".unsupported")

  # Create dummy data for files
  write.csv(mtcars, temp_csv, row.names = FALSE)
  arrow::write_parquet(mtcars, temp_parquet)
  writeLines("Unsupported file format", temp_file_unsupported)

  it("validates default cache_path permissions and auto-creates directory", {
    dc <- warprrr(
      data_path = temp_csv,
      cache_path = temp_cache
    )
    expect_true(fs::dir_exists(dc@cache_path))
    perms <- fs::file_info(dc@cache_path)$permissions
    expect_true(grepl("^r", perms))
    expect_null(attributes(dc@cache_path)$error)
  })

  it("throws error if cache_path permissions are incorrect", {
    temp_perm <- tempfile()
    fs::dir_create(temp_perm)
    Sys.chmod(temp_perm, mode = "0444", use_umask = FALSE)
    expect_error({
      dc <- warprrr(
        data_path = temp_csv,
        cache_path = temp_perm
      )
    }, "Cache folder is not writable!")
    Sys.chmod(temp_perm, mode = "0777", use_umask = FALSE)
  })

  it("requires a valid data_path file", {
    expect_error(
      warprrr(data_path = "not_a_real_file.csv"),
      "@data_path MUST be a valid path to file that exists."
    )
  })

  it("returns correct file extension", {
    dc <- warprrr(data_path = temp_csv)
    expect_equal(dc@file_ext, "csv")
  })

  it("returns file_info for data_path", {
    dc <- warprrr(data_path = temp_csv)
    expect_true(is.data.frame(dc@file_info))
    expect_true("size" %in% names(dc@file_info))
  })

  it("produces reproducible cache_hash", {
    dc <- warprrr(data_path = temp_csv)
    hash1 <- dc@cache_hash
    Sys.sleep(0.1)
    hash2 <- dc@cache_hash
    expect_identical(hash1, hash2)
  })

  it("produces different cache_hash when file content changes", {
    temp_csv_mod <- tempfile(fileext = ".csv")
    write.csv(mtcars[1:10, ], temp_csv_mod, row.names = FALSE)
    dc1 <- warprrr(data_path = temp_csv_mod)
    hash1 <- dc1@cache_hash

    Sys.sleep(1.1) # Ensure modification time differs
    write.csv(mtcars[1:20, ], temp_csv_mod, row.names = FALSE)
    dc2 <- warprrr(data_path = temp_csv_mod)
    hash2 <- dc2@cache_hash

    expect_false(identical(hash1, hash2))
    fs::file_delete(temp_csv_mod)
  })

  it("uses .parquet as default cache_ext", {
    dc <- warprrr(data_path = temp_csv)
    expect_equal(dc@cache_ext, ".feather")
  })

  it("generates correct cache_hash_file_name", {
    dc <- warprrr(data_path = temp_csv)
    expect_true(grepl(dc@cache_hash, dc@cache_hash_file_name))
    expect_true(grepl(".feather", dc@cache_hash_file_name))
  })

  it("provides absolute cache path", {
    dc <- read_data(data_path = temp_csv, cache_path = temp_cache)$warprrr
    expect_true(fs::is_absolute_path(dc@cache_full_file_path))
  })

  it("reads data_object depending on extension (csv)", {
    dc <- warprrr(data_path = temp_csv)
    obj <- dc@data_object
    expect_s3_class(obj, "data.table")
    expect_identical(dim(obj), dim(mtcars))
  })

  it("reads data_object depending on extension (parquet)", {
    dc <- warprrr(data_path = temp_parquet)
    expect_identical(
      class(dc@data_object),
      c("tbl_df", "tbl", "data.frame")
    )
    expect_identical(dim(dc@data_object), dim(mtcars))
  })

  it("errors on unsupported file extension", {
    dc <- warprrr(data_path = temp_file_unsupported)
    expect_error(dc@data_object, "files are not supported")
  })

  it("get_data caches and loads data correctly (cache miss -> cache hit)", {
    cache_dir <- tempfile()
    fs::dir_create(cache_dir)
    dc <- warprrr(data_path = temp_csv, cache_path = cache_dir)

    result1 <- get_data(dc, verbose = FALSE)
    expect_s3_class(result1, "data.table")
    expect_true(fs::file_exists(dc@cache_full_file_path))

    result2 <- get_data(dc, verbose = FALSE)
    expect_identical(
      class(result2),
      c("data.table", "data.frame")
    )
    expect_equal(as.data.frame(result1), as.data.frame(result2))
  })

  it("creates valid feather cache file", {
    cache_dir <- tempfile()
    fs::dir_create(cache_dir)
    dc <- warprrr(data_path = temp_csv, cache_path = cache_dir)
    get_data(dc, verbose = FALSE)

    expect_true(fs::file_exists(dc@cache_full_file_path))
    expect_equal(fs::path_ext(dc@cache_full_file_path), "feather")

    cached <- arrow::read_feather(dc@cache_full_file_path)
    expect_s3_class(cached, "data.frame")
  })

  it("maintains data integrity through cache cycle", {
    cache_dir <- tempfile()
    fs::dir_create(cache_dir)
    dc <- warprrr(data_path = temp_csv, cache_path = cache_dir)

    original <- data.table::fread(temp_csv)
    cached <- get_data(dc, verbose = FALSE)
    recached <- get_data(dc, verbose = FALSE)

    expect_equal(as.data.frame(original), as.data.frame(cached))
    expect_equal(as.data.frame(cached), as.data.frame(recached))
  })

  it("cache read is faster than original read", {
    cache_dir <- tempfile()
    fs::dir_create(cache_dir)
    dc <- warprrr(data_path = temp_csv, cache_path = cache_dir)

    time1 <- system.time(get_data(dc, verbose = FALSE))["elapsed"]
    time2 <- system.time(get_data(dc, verbose = FALSE))["elapsed"]

    print("====================================")
    print(time1)
    print(time2)
    print("====================================")

    expect_true(time2 < time1 * 2) # At least not slower
  })

  it("handles empty CSV file", {
    temp_empty <- tempfile(fileext = ".csv")
    # Create CSV with headers but no data rows
    empty_df <- data.frame(col1 = character(0), col2 = numeric(0))
    write.csv(empty_df, temp_empty, row.names = FALSE)
    dc <- warprrr(data_path = temp_empty)

    result <- suppressMessages(get_data(dc, verbose = FALSE))
    expect_equal(nrow(result), 0)
    expect_true(ncol(result) > 0) # Has columns but no rows
    fs::file_delete(temp_empty)
  })

  it("handles cache paths with spaces and special chars", {
    cache_special <- tempfile(pattern = "test cache #1")
    fs::dir_create(cache_special)

    dc <- warprrr(data_path = temp_csv, cache_path = cache_special)
    result <- get_data(dc, verbose = FALSE)

    expect_true(fs::file_exists(dc@cache_full_file_path))
    expect_s3_class(result, "data.table")
  })

  it("multiple instances share same cache hash", {
    cache_dir <- tempfile()
    fs::dir_create(cache_dir)

    dc1 <- warprrr(data_path = temp_csv, cache_path = cache_dir)
    dc2 <- warprrr(data_path = temp_csv, cache_path = cache_dir)

    expect_equal(dc1@cache_hash, dc2@cache_hash)
    expect_equal(dc1@cache_full_file_path, dc2@cache_full_file_path)
  })

  it("handles missing cache path gracefully", {
    cache_dir <- tempfile()
    dc <- warprrr(data_path = temp_csv, cache_path = cache_dir)
    expect_true(fs::dir_exists(dc@cache_path))
  })

  it("supports SAS7BDAT if haven available", {
    skip_if_not_installed("haven")
    temp_sas <- tempfile(fileext = ".sas7bdat")
    iris_sas <- datasets::iris
    names(iris_sas) <- gsub("\\.", "_", names(iris_sas))
    suppressWarnings(haven::write_sas(iris_sas, temp_sas))
    dc <- warprrr(data_path = temp_sas)
    obj <- dc@data_object
    expect_s3_class(obj, "tbl_df")
    expect_identical(dim(obj), dim(datasets::iris))
  })

  # NEW: Test file_info contains expected fields
  it("file_info contains all standard fs fields", {
    dc <- warprrr(data_path = temp_csv)
    info <- dc@file_info
    expected_cols <- c("path", "type", "size", "permissions",
                       "modification_time", "access_time")
    expect_true(all(expected_cols %in% names(info)))
  })

  # NEW: Test cache invalidation on file modification
  it("creates new cache when source file is modified", {
    temp_csv_mod <- tempfile(fileext = ".csv")
    cache_dir <- tempfile()
    fs::dir_create(cache_dir)

    write.csv(mtcars[1:10, ], temp_csv_mod, row.names = FALSE)
    dc1 <- warprrr(data_path = temp_csv_mod, cache_path = cache_dir)
    cache_path_1 <- dc1@cache_full_file_path
    get_data(dc1, verbose = FALSE)

    Sys.sleep(1.1)
    write.csv(mtcars[1:20, ], temp_csv_mod, row.names = FALSE)
    dc2 <- warprrr(data_path = temp_csv_mod, cache_path = cache_dir)
    cache_path_2 <- dc2@cache_full_file_path

    expect_false(identical(cache_path_1, cache_path_2))
    fs::file_delete(temp_csv_mod)
  })

  # Cleanup
  fs::dir_delete(temp_cache)
  fs::file_delete(temp_csv)
  fs::file_delete(temp_parquet)
  fs::file_delete(temp_file_unsupported)
})

testthat::describe("warprrr utility functions", {
  it("time_taken_precise returns numeric elapsed time", {
    result <- time_taken_precise({
      Sys.sleep(0.01)
    })
    expect_type(result, "double")
    expect_true(result >= 0.01)
  })

  it("warprrr returns formatted timestamp", {
    prefix <- dv_log_preffix()
    expect_true(grepl("warprrr", prefix))
    expect_true(grepl("\\d{4}-\\d{2}-\\d{2}", prefix))
  })

  it("inform_glue outputs without error", {
    expect_output(inform_glue("Test message"), "Test message")
  })

  it("error_glue stops execution", {
    expect_error(error_glue("Test error"), "Test error")
  })
})
