library(artbin)

# Helper: extract total n
nn <- function(x) x$n

# Helper: extract per-group n
ng <- function(x, i) x$n_per_group[[i]]

# ============================================================
# Tests from artbin_testing_5.do (Item 5 - EAST comparison)
# Tests not already covered in test-artbin.R (EAST tests 2 and 10)
# ============================================================

test_that("EAST: pr(0.3 0.3), margin=0.1, alpha=0.05, power=0.8, wald -> 660", {
  x <- artbin(pr = c(0.3, 0.3), margin = 0.1, alpha = 0.05, power = 0.8, wald = TRUE)
  expect_equal(nn(x), 660)
  expect_equal(ng(x, 1), 330)
  expect_equal(ng(x, 2), 330)
})

test_that("EAST: pr(0.9 0.9), margin=-0.023, alpha=0.05, power=0.9, wald, aratios=1:2 -> 8045", {
  x <- artbin(pr = c(0.9, 0.9), margin = -0.023, alpha = 0.05, power = 0.9,
              wald = TRUE, aratios = c(1, 2))
  expect_equal(nn(x), 8045)
})
