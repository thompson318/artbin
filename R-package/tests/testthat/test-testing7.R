library(artbin)

# Helper: extract total n
nn <- function(x) x$n

# Helper: extract per-group n
ng <- function(x, i) x$n_per_group[[i]]

# ============================================================
# Tests from artbin_testing_7.do (Item 7)
# ============================================================


# ============================================================
# One-sided / two-sided equivalence for >2 groups
# alpha onesided = alpha/2 two-sided gives same result
# ============================================================

test_that("onesided equiv: trend, alpha=0.05 onesided == alpha=0.1 two-sided", {
  x1 <- artbin(pr = c(0.1, 0.2, 0.3), trend = TRUE, alpha = 0.05, onesided = TRUE)
  x2 <- artbin(pr = c(0.1, 0.2, 0.3), trend = TRUE, alpha = 0.1)
  expect_equal(nn(x1), nn(x2))
})

test_that("onesided equiv: doses(2,4,6), alpha=0.05 onesided == alpha=0.1 two-sided", {
  x1 <- artbin(pr = c(0.1, 0.2, 0.3), doses = c(2, 4, 6), alpha = 0.05, onesided = TRUE)
  x2 <- artbin(pr = c(0.1, 0.2, 0.3), doses = c(2, 4, 6), alpha = 0.1)
  expect_equal(nn(x1), nn(x2))
})


# ============================================================
# artbin (score test) value cross-check
# ============================================================

test_that("artbin score test: pr(0.1 0.1), margin=0.05 -> 1162", {
  x <- artbin(pr = c(0.1, 0.1), margin = 0.05)
  expect_equal(nn(x), 1162)
})


# ============================================================
# Non-integer allocation ratio equivalence
# ============================================================

test_that("aratio 1:1.5 equivalent to 2:3", {
  x1 <- artbin(pr = c(0.15, 0.15), margin = 0.1, aratios = c(1, 1.5))
  x2 <- artbin(pr = c(0.15, 0.15), margin = 0.1, aratios = c(2, 3))
  expect_equal(nn(x1), nn(x2))
})


# ============================================================
# Expected events D formula: D == sum(pr_i * n_i) with noround
# ============================================================

test_that("D formula: D == sum(pr_i * n_i) for 2-arm noround scenarios", {
  scenarios <- list(
    list(pr = c(0.25, 0.35), margin = 0.2),
    list(pr = c(0.3,  0.5),  margin = 0.1),
    list(pr = c(0.4,  0.6),  margin = 0.05),
    list(pr = c(0.3,  0.5),  margin = -0.1),
    list(pr = c(0.4,  0.6),  aratios = c(1, 2))
  )
  for (s in scenarios) {
    x <- do.call(artbin, c(s, list(noround = TRUE)))
    expect_equal(x$D, sum(x$D_per_group), tolerance = 1e-9)
    for (i in seq_along(x$pr)) {
      expect_equal(x$D_per_group[[i]], x$pr[i] * x$n_per_group[[i]], tolerance = 1e-9)
    }
  }
})

test_that("D formula: D == sum(pr_i * n_i) for 3-arm noround", {
  x <- artbin(pr = c(0.2, 0.3, 0.4), noround = TRUE)
  expect_equal(x$D, sum(x$D_per_group), tolerance = 1e-9)
  for (i in 1:3) {
    expect_equal(x$D_per_group[[i]], x$pr[i] * x$n_per_group[[i]], tolerance = 1e-9)
  }
})
