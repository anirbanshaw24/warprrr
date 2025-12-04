
testthat::describe("error_glue()", {
  it("throws an error with colored message", {
    expect_error(error_glue("Error!"), "Error!")
  })
})
