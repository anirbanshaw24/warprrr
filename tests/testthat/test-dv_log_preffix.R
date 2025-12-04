
testthat::describe("dv_log_preffix()", {
  it("returns a blue string with timestamp", {
    res <- dv_log_preffix()
    expect_true(is.character(res))
    expect_match(res, "cranpkgtemplate @")
  })
})
