library(artbin)

# Helper: extract total n
nn <- function(x) x$n

# Helper: extract per-group n
ng <- function(x, i) x$n_per_group[[i]]

# ============================================================
# Tests from artbin_testing_4.do (Item 4)
# Margin/onesided tests not already covered in test-artbin.R
# (tests 12, 13, 15-18 are covered there via niss cross-validation)
# All use alpha=0.025, onesided=TRUE, wald=TRUE (Julious 2011 Table 4)
# ============================================================

test_that("Julious 2011: pr(0.2 0.3), margin=0.15, alpha=0.025, onesided, wald -> 1556/arm", {
  x <- artbin(pr = c(0.2, 0.3), margin = 0.15, alpha = 0.025, onesided = TRUE,
              power = 0.9, wald = TRUE)
  expect_equal(ng(x, 1), 1556)
  expect_equal(ng(x, 2), 1556)
  expect_equal(nn(x), 3112)
})

test_that("Julious 2011: pr(0.2 0.1), margin=0.05, alpha=0.025, onesided, wald -> 117/arm", {
  x <- artbin(pr = c(0.2, 0.1), margin = 0.05, alpha = 0.025, onesided = TRUE,
              power = 0.9, wald = TRUE)
  expect_equal(ng(x, 1), 117)
  expect_equal(ng(x, 2), 117)
  expect_equal(nn(x), 234)
})

test_that("Julious 2011: pr(0.15 0.15), margin=0.1, alpha=0.025, onesided, wald -> 268/arm", {
  x <- artbin(pr = c(0.15, 0.15), margin = 0.1, alpha = 0.025, onesided = TRUE,
              power = 0.9, wald = TRUE)
  expect_equal(ng(x, 1), 268)
  expect_equal(ng(x, 2), 268)
  expect_equal(nn(x), 536)
})

test_that("Julious 2011: pr(0.1 0.15), margin=0.1, alpha=0.025, onesided, wald -> 915/arm", {
  x <- artbin(pr = c(0.1, 0.15), margin = 0.1, alpha = 0.025, onesided = TRUE,
              power = 0.9, wald = TRUE)
  expect_equal(ng(x, 1), 915)
  expect_equal(ng(x, 2), 915)
  expect_equal(nn(x), 1830)
})
