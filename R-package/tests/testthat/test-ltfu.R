library(artbin)

# Helper: extract total n
nn <- function(x) x$n

# ============================================================
# Tests from artbin_test_ltfu.do
# ============================================================


# ============================================================
# power -> n: total n with ltfu == n without ltfu / (1 - ltfu)
# D (expected events) is the same with or without ltfu
# ============================================================

test_that("ltfu power->n: n_ltfu == n_noltfu / (1 - ltfu), D unchanged", {
  x0 <- artbin(pr = c(0.02, 0.02), margin = 0.02, noround = TRUE)
  x1 <- artbin(pr = c(0.02, 0.02), margin = 0.02, noround = TRUE, ltfu = 0.1)
  # Compare per-group n (stored as float with noround=TRUE) rather than $n
  # which is integer-cast even with noround=TRUE
  expect_equal(x1$n_per_group[[1]], x0$n_per_group[[1]] / 0.9, tolerance = 1e-7)
  expect_equal(x1$n_per_group[[2]], x0$n_per_group[[2]] / 0.9, tolerance = 1e-7)
  expect_equal(x1$D, x0$D, tolerance = 1e-7)
})


# ============================================================
# n -> power: power(ltfu=0.1, n=1000) == power(n=900, no ltfu)
# ============================================================

test_that("ltfu n->power: power(ltfu=0.1, n=1000) == power(n=900, no ltfu)", {
  x_ltfu   <- artbin(pr = c(0.02, 0.02), margin = 0.02, noround = TRUE, n = 1000, ltfu = 0.1)
  x_noltfu <- artbin(pr = c(0.02, 0.02), margin = 0.02, noround = TRUE, n = 900)
  expect_equal(x_ltfu$power, x_noltfu$power, tolerance = 1e-7)
})


# ============================================================
# Round-trip: SS -> power -> SS with ltfu preserves n
# Four option sets matching artbin_test_ltfu.do
# ============================================================

test_that("ltfu round-trip: pr(.02,.02) margin(.02) aratio(1,2)", {
  n_orig <- 1000
  x1 <- artbin(pr = c(0.02, 0.02), margin = 0.02, aratios = c(1, 2),
               n = n_orig, ltfu = 0.1, noround = TRUE, convcrit = 1e-8)
  x2 <- artbin(pr = c(0.02, 0.02), margin = 0.02, aratios = c(1, 2),
               power = x1$power, ltfu = 0.1, noround = TRUE, convcrit = 1e-8)
  expect_equal(sum(x2$n_per_group), n_orig, tolerance = 1e-7)
})

test_that("ltfu round-trip: pr(.02,.04) aratio(1,2)", {
  n_orig <- 1000
  x1 <- artbin(pr = c(0.02, 0.04), aratios = c(1, 2),
               n = n_orig, ltfu = 0.1, noround = TRUE, convcrit = 1e-8)
  x2 <- artbin(pr = c(0.02, 0.04), aratios = c(1, 2),
               power = x1$power, ltfu = 0.1, noround = TRUE, convcrit = 1e-8)
  expect_equal(sum(x2$n_per_group), n_orig, tolerance = 1e-7)
})

test_that("ltfu round-trip: pr(.02,.04,.06) aratio(3,2,1)", {
  n_orig <- 1000
  x1 <- artbin(pr = c(0.02, 0.04, 0.06), aratios = c(3, 2, 1),
               n = n_orig, ltfu = 0.1, noround = TRUE, convcrit = 1e-8)
  x2 <- artbin(pr = c(0.02, 0.04, 0.06), aratios = c(3, 2, 1),
               power = x1$power, ltfu = 0.1, noround = TRUE, convcrit = 1e-8)
  expect_equal(sum(x2$n_per_group), n_orig, tolerance = 1e-7)
})

test_that("ltfu round-trip: pr(.02,.04,.06) trend", {
  n_orig <- 1000
  x1 <- artbin(pr = c(0.02, 0.04, 0.06), trend = TRUE,
               n = n_orig, ltfu = 0.1, noround = TRUE, convcrit = 1e-8)
  x2 <- artbin(pr = c(0.02, 0.04, 0.06), trend = TRUE,
               power = x1$power, ltfu = 0.1, noround = TRUE, convcrit = 1e-8)
  expect_equal(sum(x2$n_per_group), n_orig, tolerance = 1e-7)
})


# ============================================================
# Non-integer ltfu * n: n is preserved as supplied
# ============================================================

test_that("ltfu non-integer: ltfu=0.05, n=1836 -> n==1836", {
  x <- artbin(pr = c(0.02, 0.02), margin = 0.02, ltfu = 0.05, n = 1836)
  expect_equal(x$n, 1836)
})
