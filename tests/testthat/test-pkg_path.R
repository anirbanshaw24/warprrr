
testthat::describe("pkg_path()", {
  it("returns a valid fs_path object for an existing file", {
    path <- warprrr::pkg_path(
      "constants", "constants.yml", allow_error = FALSE
    )
    testthat::expect_s3_class(path, "fs_path")
    testthat::expect_true(file.exists(as.character(path)))
  })

  it("returns an empty fs_path object for a non-existent
     file when allow_error = FALSE", {
       path <- warprrr::pkg_path(
         "not_a_real_dir", "foo.txt", allow_error = FALSE
       )
       testthat::expect_s3_class(path, "fs_path")
       testthat::expect_identical(as.character(path), "")
     })

  it("throws an error for a non-existent file when allow_error = TRUE", {
    testthat::expect_error(
      warprrr::pkg_path("not_a_real_dir", "foo.txt", allow_error = TRUE)
    )
  })
})
