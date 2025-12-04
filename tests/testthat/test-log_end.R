
testthat::describe("log_end()", {
  it("cat outputs end message in blue", {
    expect_output(log_end(), "END")
  })
})
