
testthat::describe("get_print_constants()", {
  it("returns the `$print` value if present", {
    pkg_env$pkg_constants <- list(print = "foo")
    expect_identical(get_print_constants(), "foo")
  })
  it("returns NULL if `$print` constant is missing", {
    pkg_env$pkg_constants <- list()
    expect_null(get_print_constants())
  })
})
