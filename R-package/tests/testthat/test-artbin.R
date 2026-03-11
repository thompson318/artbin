library(artbin)

# Helper: extract total n
nn <- function(x) x$n

# Helper: extract per-group n
ng <- function(x, i) x$n_per_group[[i]]


# ============================================================
# Tests from artbin_testing_1.do (NI, Wald test)
# ============================================================

test_that("Blackwelder 1982: NI, p=0.1/0.1, margin=0.2, alpha=0.1, power=0.9", {
  x <- artbin(pr = c(0.1, 0.1), margin = 0.2, alpha = 0.1, power = 0.9, wald = TRUE)
  expect_equal(ng(x, 1), 39)
  expect_equal(ng(x, 2), 39)
  expect_equal(nn(x), 78)
})

test_that("Julious 2011 Table 4: NI, p=0.3/0.3, margin=0.05, alpha=0.05, power=0.9", {
  x <- artbin(pr = c(0.3, 0.3), margin = 0.05, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(ng(x, 1), 1766)
  expect_equal(ng(x, 2), 1766)
})

test_that("Pocock 2003: NI, p=0.15/0.15, margin=0.15, alpha=0.05, power=0.9", {
  x <- artbin(pr = c(0.15, 0.15), margin = 0.15, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(ng(x, 1), 120)
  expect_equal(ng(x, 2), 120)
})

test_that("Sealed envelope: NI, p=0.2/0.2, margin=0.1, alpha=0.2, power=0.8", {
  x <- artbin(pr = c(0.2, 0.2), margin = 0.1, alpha = 0.2, power = 0.8, wald = TRUE)
  expect_equal(ng(x, 1), 145)
  expect_equal(ng(x, 2), 145)
})


# ============================================================
# Tests from artbin_examples.do
# ============================================================

test_that("Pocock 1983 Anturan: superiority, pr(0.1 0.05), wald, power=0.9", {
  x <- artbin(pr = c(0.1, 0.05), alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(nn(x), 1156)
  expect_equal(ng(x, 1), 578)
  expect_equal(ng(x, 2), 578)
})

test_that("NI onesided: pr(0.9 0.9), margin=-0.05, onesided -> 457 per arm", {
  x <- artbin(pr = c(0.9, 0.9), margin = -0.05, onesided = TRUE)
  expect_equal(ng(x, 1), 457)
  expect_equal(ng(x, 2), 457)
  expect_equal(nn(x), 914)
})

test_that("4-arm superiority: pr(0.1 0.2 0.3 0.4), alpha=0.1, power=0.9 -> 44 per group", {
  x <- artbin(pr = c(0.1, 0.2, 0.3, 0.4), alpha = 0.1, power = 0.9)
  expect_equal(ng(x, 1), 44)
  expect_equal(ng(x, 2), 44)
  expect_equal(ng(x, 3), 44)
  expect_equal(ng(x, 4), 44)
  expect_equal(nn(x), 176)
})

test_that("STREAM NI: pr(0.7 0.75), margin=-0.1, wald, aratios=1:2, ltfu=0.2 -> 398", {
  # v2.1.1 Stata result: 398 (133+265). The artbin_examples.do comment of 399
  # was written for v2.0.2 which applied rounding at an intermediate step.
  x <- artbin(pr = c(0.7, 0.75), margin = -0.1, power = 0.8,
              aratios = c(1, 2), wald = TRUE, ltfu = 0.2)
  expect_equal(nn(x), 398)
  expect_equal(ng(x, 1), 133)
  expect_equal(ng(x, 2), 265)
})


# ============================================================
# Argument validation
# ============================================================

test_that("Error if n and power both given", {
  expect_error(artbin(pr = c(0.3, 0.5), n = 100, power = 0.8),
               "Cannot specify both")
})

test_that("Error if pr has fewer than 2 elements", {
  expect_error(artbin(pr = 0.3), "At least two")
})

test_that("Error if pr values out of range", {
  expect_error(artbin(pr = c(0, 0.5)), "strictly between")
  expect_error(artbin(pr = c(0.3, 1)), "strictly between")
})

test_that("Error if margin specified for >2 groups", {
  expect_error(artbin(pr = c(0.2, 0.3, 0.4), margin = 0.1), "more than 2 groups")
})

test_that("Error if pr equal for 2-arm superiority", {
  expect_error(artbin(pr = c(0.3, 0.3)), "cannot be equal")
})

test_that("Error if local and wald combined", {
  expect_error(artbin(pr = c(0.2, 0.4), local = TRUE, wald = TRUE),
               "cannot both")
})

test_that("Error if condit and wald combined", {
  expect_error(artbin(pr = c(0.2, 0.4, 0.6), condit = TRUE, wald = TRUE),
               "cannot both")
})

test_that("Error if trend specified for 2-arm trial", {
  expect_error(artbin(pr = c(0.2, 0.4), trend = TRUE), "2-arm")
})


# ============================================================
# Power calculation mode
# ============================================================

test_that("Power mode: pr(0.1 0.05) wald, n=1156 -> power ~ 0.9", {
  x <- artbin(pr = c(0.1, 0.05), alpha = 0.05, n = 1156, wald = TRUE)
  expect_equal(x$calc_mode, "power")
  expect_true(abs(x$power - 0.9) < 0.01)
})

test_that("Power mode: pr(0.25 0.35), n=400 returns power in (0,1)", {
  x <- artbin(pr = c(0.25, 0.35), n = 400)
  expect_equal(x$calc_mode, "power")
  expect_true(x$power > 0 && x$power < 1)
})


# ============================================================
# Trial type classification
# ============================================================

test_that("Trial type: superiority when margin=0", {
  x <- artbin(pr = c(0.2, 0.35))
  expect_equal(x$trial_type, "superiority")
})

test_that("Trial type: non-inferiority (unfavourable, margin>0)", {
  x <- artbin(pr = c(0.1, 0.1), margin = 0.05, wald = TRUE)
  expect_equal(x$trial_type, "non-inferiority")
  expect_equal(x$outcome, "unfavourable")
})

test_that("Trial type: non-inferiority (favourable, margin<0)", {
  x <- artbin(pr = c(0.9, 0.9), margin = -0.05)
  expect_equal(x$trial_type, "non-inferiority")
  expect_equal(x$outcome, "favourable")
})


# ============================================================
# Default power = 0.8
# ============================================================

test_that("Default power is 0.8", {
  x <- artbin(pr = c(0.25, 0.35))
  expect_equal(x$power, 0.8)
})


# ============================================================
# Return object structure
# ============================================================

test_that("Return object has expected fields", {
  x <- artbin(pr = c(0.25, 0.35))
  expect_s3_class(x, "artbin")
  expect_true(all(c("n", "n_per_group", "power", "D", "D_per_group",
                    "pr", "margin", "alpha", "trial_type", "outcome",
                    "calc_mode") %in% names(x)))
})

test_that("n_per_group sums to n", {
  x <- artbin(pr = c(0.25, 0.35))
  expect_equal(sum(x$n_per_group), x$n)
})
