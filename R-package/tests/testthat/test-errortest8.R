library(artbin)

# ============================================================
# Tests from artbin_errortest_8.do (Item 8)
# Error codes not already covered in test-artbin.R
# ============================================================


# ============================================================
# alpha out of range
# ============================================================

test_that("Error if alpha = 0", {
  expect_error(artbin(pr = c(0.1, 0.2), alpha = 0), "alpha")
})

test_that("Error if alpha = 1", {
  expect_error(artbin(pr = c(0.1, 0.2), alpha = 1), "alpha")
})

test_that("Error if alpha = 100", {
  expect_error(artbin(pr = c(0.1, 0.2), alpha = 100), "alpha")
})

test_that("Error if alpha = -0.05", {
  expect_error(artbin(pr = c(0.1, 0.2), alpha = -0.05), "alpha")
})


# ============================================================
# power out of range
# ============================================================

test_that("Error if power = 0", {
  expect_error(artbin(pr = c(0.1, 0.2), power = 0), "power")
})

test_that("Error if power = 1", {
  expect_error(artbin(pr = c(0.1, 0.2), power = 1), "power")
})

test_that("Error if power = 100", {
  expect_error(artbin(pr = c(0.1, 0.2), power = 100), "power")
})

test_that("Error if power = -0.8", {
  expect_error(artbin(pr = c(0.1, 0.2), power = -0.8), "power")
})


# ============================================================
# n out of range
# ============================================================

test_that("Error if n is negative", {
  expect_error(artbin(pr = c(0.1, 0.2), n = -500), "positive")
})


# ============================================================
# ccorrect with >2 groups
# ============================================================

test_that("Error if ccorrect with >2 groups (sample size)", {
  expect_error(artbin(pr = c(0.1, 0.2, 0.3), ccorrect = TRUE), "2 groups")
})

test_that("Error if ccorrect with >2 groups (power)", {
  expect_error(artbin(pr = c(0.1, 0.2, 0.3), ccorrect = TRUE, n = 500), "2 groups")
})


# ============================================================
# onesided with >2 groups (without trend/doses)
# ============================================================

test_that("Error if onesided with >2 groups, sample size", {
  expect_error(artbin(pr = c(0.1, 0.2, 0.3), onesided = TRUE), ">2 groups")
})

test_that("Error if onesided with >2 groups, power", {
  expect_error(artbin(pr = c(0.1, 0.2, 0.3), onesided = TRUE, n = 100), ">2 groups")
})


# ============================================================
# local + nvmethod != 3
# ============================================================

test_that("Error if local=TRUE and nvmethod=1", {
  expect_error(artbin(pr = c(0.1, 0.2), local = TRUE, nvmethod = 1), "nvmethod")
})

test_that("Error if local=TRUE and nvmethod=2", {
  expect_error(artbin(pr = c(0.1, 0.2), local = TRUE, nvmethod = 2), "nvmethod")
})


# ============================================================
# wald + nvmethod != 1
# ============================================================

test_that("Error if wald=TRUE and nvmethod=2", {
  expect_error(artbin(pr = c(0.1, 0.2), wald = TRUE, nvmethod = 2), "nvmethod")
})

test_that("Error if wald=TRUE and nvmethod=3", {
  expect_error(artbin(pr = c(0.1, 0.2), wald = TRUE, nvmethod = 3), "nvmethod")
})


# ============================================================
# ltfu out of range
# ============================================================

test_that("Error if ltfu >= 1", {
  expect_error(artbin(pr = c(0.1, 0.2), ltfu = 1), "ltfu")
})

test_that("Error if ltfu = 2", {
  expect_error(artbin(pr = c(0.1, 0.2), ltfu = 2), "ltfu")
})

test_that("Error if ltfu < 0", {
  expect_error(artbin(pr = c(0.1, 0.2), ltfu = -0.1), "ltfu")
})
