library(artbin)

# Helper: extract total n
nn <- function(x) x$n

# Helper: extract per-group n
ng <- function(x, i) x$n_per_group[[i]]

# ============================================================
# Tests from artbin_testing_2.do (Item 2 - Superiority)
# Tests not already covered in test-artbin.R
# ============================================================

test_that("Sealed envelope: superiority, pr(0.1 0.2), alpha=0.1, power=0.8, wald -> 155/arm", {
  x <- artbin(pr = c(0.1, 0.2), alpha = 0.1, power = 0.8, wald = TRUE)
  expect_equal(ng(x, 1), 155)
  expect_equal(ng(x, 2), 155)
  expect_equal(nn(x), 310)
})

test_that("Power back-calc: pr(0.1 0.2), alpha=0.1, n=310, wald -> power ~0.8", {
  x <- artbin(pr = c(0.1, 0.2), alpha = 0.1, n = 310, wald = TRUE)
  expect_equal(round(x$power, 1), 0.8)
})
