
testthat::describe("success_glue()", {
  it("outputs success message in green color", {
    expect_output(success_glue("Success!"), "Success!")
  })
})
