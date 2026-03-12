library(artbin)

# Helper: extract total n
nn <- function(x) x$n

# Helper: extract per-group n
ng <- function(x, i) x$n_per_group[[i]]

# ============================================================
# Tests from artbin_testing_3.do (Item 3)
# Continuity correction cross-validation vs Stata's power command
# ============================================================

test_that("ccorrect: pr(0.05 0.1), alpha=0.05, power=0.9 -> 621/arm", {
  x <- artbin(pr = c(0.05, 0.1), alpha = 0.05, power = 0.9, ccorrect = TRUE)
  expect_equal(ng(x, 1), 621)
  expect_equal(ng(x, 2), 621)
  expect_equal(nn(x), 1242)
})

test_that("ccorrect: pr(0.03 0.07), alpha=0.05, power=0.95 -> 818/arm", {
  x <- artbin(pr = c(0.03, 0.07), alpha = 0.05, power = 0.95, ccorrect = TRUE)
  expect_equal(ng(x, 1), 818)
  expect_equal(ng(x, 2), 818)
  expect_equal(nn(x), 1636)
})

test_that("ccorrect: pr(0.1 0.2), alpha=0.05, power=0.85 -> 247/arm", {
  x <- artbin(pr = c(0.1, 0.2), alpha = 0.05, power = 0.85, ccorrect = TRUE)
  expect_equal(ng(x, 1), 247)
  expect_equal(ng(x, 2), 247)
  expect_equal(nn(x), 494)
})

test_that("ccorrect: pr(0.1 0.01), alpha=0.025, power=0.8 -> 143/arm", {
  x <- artbin(pr = c(0.1, 0.01), alpha = 0.025, power = 0.8, ccorrect = TRUE)
  expect_equal(ng(x, 1), 143)
  expect_equal(ng(x, 2), 143)
  expect_equal(nn(x), 286)
})

test_that("ccorrect: pr(0.15 0.2), alpha=0.1, power=0.9 -> 1027/arm", {
  x <- artbin(pr = c(0.15, 0.2), alpha = 0.1, power = 0.9, ccorrect = TRUE)
  expect_equal(ng(x, 1), 1027)
  expect_equal(ng(x, 2), 1027)
  expect_equal(nn(x), 2054)
})

test_that("ccorrect: pr(0.3 0.1), alpha=0.05, power=0.9 -> 92/arm", {
  x <- artbin(pr = c(0.3, 0.1), alpha = 0.05, power = 0.9, ccorrect = TRUE)
  expect_equal(ng(x, 1), 92)
  expect_equal(ng(x, 2), 92)
  expect_equal(nn(x), 184)
})
