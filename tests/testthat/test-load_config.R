
testthat::describe("load_config()", {
  it("returns NULL and warns when config file is missing", {
    mockery::stub(load_config, "pkg_path", fs::path(tempfile()))
    expect_warning(res <- load_config(), "Config file not found")
    expect_null(res)
  })
})
