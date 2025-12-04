
testthat::describe("log_start()", {
  it("cat outputs start message in blue", {
    expect_output(log_start(), "START")
  })
})
