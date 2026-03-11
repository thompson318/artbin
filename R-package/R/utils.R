# Internal utility functions for artbin

#' @importFrom stats pchisq pnorm qchisq qnorm uniroot
NULL

# Find noncentrality parameter ncp such that pchisq(x, df, ncp) = p.
# Equivalent to Stata's npnchi2(df, x, p).
# As ncp increases, the non-central chi-sq distribution shifts right,
# so pchisq(x, df, ncp) decreases monotonically from pchisq(x, df, 0) to 0.
.npnchi2 <- function(df, x, p) {
  if (pchisq(x, df, ncp = 0) <= p) return(0)
  f <- function(ncp) pchisq(x, df, ncp = ncp) - p
  upper <- max(100, 10 * x)
  while (f(upper) > 0) upper <- upper * 10
  uniroot(f, c(0, upper), tol = 1e-10)$root
}

# Calculate beta (type II error) for the k-group distant-alternative case.
# Equivalent to Stata's _pe2 subroutine.
# Returns beta = P(Type II error).
.pe2 <- function(a0, q0, a1, q1, k, n, a) {
  b0 <- a0 + n * q0
  b1 <- a1 + 2 * n * q1
  l  <- b0^2 - k * b1
  f  <- sqrt(l * (l + k * b1))
  l  <- (l + f) / b1
  f  <- a * (k + l) / b0
  pchisq(f, df = k, ncp = l)
}

# Continuity correction adjustment.
# Equivalent to Stata's _cc subroutine.
# deflate = FALSE: inflate n (for sample size calculation)
# deflate = TRUE:  deflate n (for power calculation)
.cc_adjust <- function(n, adiff, ratio = 1, deflate = FALSE) {
  a <- (ratio + 1) / (adiff * ratio)
  if (deflate) {
    ((2 * n - a)^2) / (4 * n)
  } else {
    cf <- ((1 + sqrt(1 + 2 * a / n))^2) / 4
    n * cf
  }
}

# Compute null-hypothesis event probabilities for 2-arm trials.
# nvmethod: 1 = sample estimate, 2 = fixed marginals, 3 = constrained ML.
# p0, p1 are the anticipated (alternative-hypothesis) event probabilities.
# r = n1/n0 is the allocation ratio.
# margin is the non-inferiority/superiority margin.
.null_probs <- function(p0, p1, margin, r, nvmethod) {
  if (nvmethod == 1L) {
    list(p0null = p0, p1null = p1)
  } else if (nvmethod == 2L) {
    p0null <- (p0 + r * p1 - r * margin) / (1 + r)
    p1null <- (p0 + r * p1 + margin) / (1 + r)
    if (p0null <= 0 || p0null >= 1 || p1null <= 0 || p1null >= 1) {
      cli::cli_abort(c(
        "Event probabilities and/or margin are incompatible with the",
        "fixed marginal totals null variance method (nvmethod = 2)."
      ))
    }
    list(p0null = p0null, p1null = p1null)
  } else {
    # nvmethod == 3: constrained maximum likelihood (Farrington & Manning 1990)
    a_c <- 1 + r
    b_c <- margin * (r + 2) - 1 - r - p0 - r * p1
    c_c <- (margin - 1 - r - 2 * p0) * margin + p0 + r * p1
    d_c <- p0 * margin * (1 - margin)

    v <- (b_c / (3 * a_c))^3 - (b_c * c_c) / (6 * a_c^2) + d_c / (2 * a_c)
    disc <- (b_c / (3 * a_c))^2 - c_c / (3 * a_c)
    u <- sign(v) * sqrt(max(0, disc))

    toosmall <- 1e-12
    cos_arg <- if (abs(v) <= toosmall && abs(u^3) <= toosmall) {
      0
    } else {
      v / u^3
    }
    cos_arg <- max(-1, min(1, cos_arg))  # clamp to valid acos domain

    w      <- (pi + acos(cos_arg)) / 3
    p0null <- 2 * u * cos(w) - b_c / (3 * a_c)
    p1null <- p0null + margin

    if (p0null <= 0 || p0null >= 1 || p1null <= 0 || p1null >= 1) {
      cli::cli_abort(
        "Constrained ML solution for null probabilities is outside (0, 1). \\
         Please contact the artbin authors."
      )
    }
    list(p0null = p0null, p1null = p1null)
  }
}
