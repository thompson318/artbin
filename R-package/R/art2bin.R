# Two-arm sample size / power calculation.
# Equivalent to Stata's art2bin subroutine.
#
# p0      - control event probability
# p1      - treatment event probability
# margin  - NI/SS margin (0 for superiority)
# n0, n1  - per-group sample sizes (0 = calculate)
# r       - allocation ratio n1/n0
# alpha   - significance level (as supplied, not halved)
# power   - desired power
# nvmethod - null variance method (1, 2, or 3)
# onesided - logical
# ccorrect - logical
# local_alt - logical (local alternatives)
# wald    - logical (Wald test instead of score)
# calc_ss - TRUE = calculate sample size; FALSE = calculate power
#
# Returns a list with n, n0, n1, power, Dart (expected events), alpha.
.art2bin <- function(p0, p1, margin = 0, n0 = 0, n1 = 0, r = 1,
                     alpha, power = 0.8, nvmethod = 3L,
                     onesided = FALSE, ccorrect = FALSE,
                     local_alt = FALSE, wald = FALSE,
                     calc_ss = TRUE) {
  np  <- .null_probs(p0, p1, margin, r, nvmethod)
  p0n <- np$p0null
  p1n <- np$p1null

  D     <- abs(p1 - p0 - margin)
  za    <- if (onesided) qnorm(1 - alpha) else qnorm(1 - alpha / 2)
  snull <- sqrt(p0n * (1 - p0n) + p1n * (1 - p1n) / r)
  salt  <- sqrt(p0  * (1 - p0)  + p1  * (1 - p1)  / r)

  if (calc_ss) {
    zb <- qnorm(power)
    m <- if (local_alt) {
      ((za * snull + zb * snull) / D)^2
    } else if (wald) {
      ((za * salt  + zb * salt)  / D)^2
    } else {
      ((za * snull + zb * salt)  / D)^2
    }
    if (ccorrect) m <- .cc_adjust(m, D, r)
    n0_out <- m
    n1_out <- r * m
    list(n = n0_out + n1_out, n0 = n0_out, n1 = n1_out,
         power = power, Dart = n0_out * p0 + n1_out * p1, alpha = alpha)
  } else {
    # power calculation
    if (ccorrect) n0 <- .cc_adjust(n0, D, r, deflate = TRUE)
    pow <- if (local_alt) {
      pnorm((D * sqrt(n0) - za * snull) / snull)
    } else if (wald) {
      pnorm((D * sqrt(n0) - za * salt) / salt)
    } else {
      pnorm((D * sqrt(n0) - za * snull) / salt)
    }
    list(power = pow, n0 = n0, n1 = n1,
         Dart = n0 * p0 + n1 * p1, alpha = alpha)
  }
}
