
testthat::describe("inform_glue()", {
  it("outputs info message with blue color", {
    expect_output(inform_glue("Test message"), "Test message")
  })
})
