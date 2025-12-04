
testthat::describe("system_glue()", {
  it("interpolates input and calls system", {
    expect_type(system_glue("echo 123"), "integer")
  })
})
