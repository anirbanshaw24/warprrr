
testthat::describe("warning_glue()", {
  it("outputs warning message in yellow color", {
    expect_output(warning_glue("Warning!"), "Warning!")
  })
})
