
testthat::describe("pkg_env", {
  it("is a new environment", {
    expect_true(is.environment(pkg_env))
    expect_identical(environmentName(pkg_env), "")
  })
})
