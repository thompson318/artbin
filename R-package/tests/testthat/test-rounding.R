library(artbin)

# ============================================================
# Tests from artbin_test_rounding.do
# Five option sets, each checking:
#   1. rounded n_i == ceiling(unrounded n_i) per arm
#   2. D_i/n_i ratio preserved after rounding
#   3. total n == sum(n_i), total D == sum(D_i)  [partial coverage in test-artbin.R]
# ============================================================

rounding_scenarios <- list(
  list(pr = c(0.02, 0.02), margin = 0.02, aratios = c(1, 2)),
  list(pr = c(0.02, 0.04), aratios = c(1, 2)),
  list(pr = c(0.2,  0.3),  aratios = c(10, 17)),
  list(pr = c(0.02, 0.04, 0.06), aratios = c(3, 2, 1)),
  list(pr = c(0.02, 0.04, 0.06), trend = TRUE)
)

test_that("rounding: n per arm == ceiling(unrounded n per arm)", {
  for (s in rounding_scenarios) {
    x_nr <- do.call(artbin, c(s, list(noround = TRUE)))
    x_r  <- do.call(artbin, s)
    for (i in seq_along(s$pr)) {
      expect_equal(
        x_r$n_per_group[[i]],
        ceiling(x_nr$n_per_group[[i]]),
        info = paste("scenario", deparse(s), "arm", i)
      )
    }
  }
})

test_that("rounding: D_i/n_i ratio preserved after rounding", {
  for (s in rounding_scenarios) {
    x_nr <- do.call(artbin, c(s, list(noround = TRUE)))
    x_r  <- do.call(artbin, s)
    for (i in seq_along(s$pr)) {
      expect_equal(
        x_r$D_per_group[[i]]  / x_r$n_per_group[[i]],
        x_nr$D_per_group[[i]] / x_nr$n_per_group[[i]],
        tolerance = 1e-9,
        info = paste("scenario", deparse(s), "arm", i)
      )
    }
  }
})

test_that("rounding: total n == sum of per-arm n", {
  for (s in rounding_scenarios) {
    x <- do.call(artbin, s)
    expect_equal(x$n, sum(x$n_per_group))
  }
})

test_that("rounding: total D == sum of per-arm D", {
  for (s in rounding_scenarios) {
    x <- do.call(artbin, s)
    expect_equal(x$D, sum(x$D_per_group), tolerance = 1e-9)
  }
})
