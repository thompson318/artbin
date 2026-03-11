# K-group sample size / power calculation.
# Equivalent to the general K-groups section of Stata's artbin.ado.
#
# pr      - vector of event probabilities (length K+1, first is control)
# ar      - vector of allocation ratios (normalised to sum to 1)
# alpha   - significance level for use in calculations (may be 2*alpha for
#           one-sided: the caller handles that doubling)
# power   - desired power
# n       - total sample size (0 = calculate SS)
# trend   - logical: use linear trend test
# doses   - numeric vector of doses (NULL = 0, 1, ..., K)
# condit  - logical: Peto's conditional test
# wald    - logical: Wald test (only for non-trend unconditional)
# local_alt - logical: local alternatives
# convcrit  - convergence criterion for bisection (default 1e-7)
#
# Returns a list with n (total, unrounded), power (or beta), D (expected events).
.artbin_kgroup <- function(pr, ar, alpha, power, n = 0,
                           trend = FALSE, doses = NULL,
                           condit = FALSE, wald = FALSE,
                           local_alt = FALSE,
                           convcrit = 1e-7) {
  ngroups <- length(pr)
  K       <- ngroups - 1L
  calc_ss <- (n == 0)
  beta    <- if (calc_ss) 1 - power else NA_real_

  # Weighted means and centred deviations
  pibar <- sum(pr * ar)
  s     <- pibar * (1 - pibar)
  S     <- pr * (1 - pr)
  sbar  <- sum(S * ar)
  MU    <- pr - pibar

  # Doses for trend test
  if (trend || !is.null(doses)) {
    if (is.null(doses)) {
      doses <- seq(0, ngroups - 1)
    } else {
      # Pad with last value if fewer doses than groups
      if (length(doses) < ngroups) {
        doses <- c(doses, rep(doses[length(doses)], ngroups - length(doses)))
      }
    }
    doses <- doses - sum(doses * ar)  # centre
  }

  if (!condit) {
    # -------------------------------------------------------
    # Unconditional test
    # -------------------------------------------------------
    if (!trend && is.null(doses)) {
      # Chi-square / Wald test (not trend)
      if (wald) {
        VA <- matrix(0, K, K)
        for (k in seq_len(K)) {
          for (l in seq_len(K)) {
            kk <- k + 1L
            ll <- l + 1L
            VA[k, l] <- S[kk] * ((k == l) / ar[kk] - 1) - S[ll] + sbar
          }
        }
        MU_k <- MU[-1]
        q0   <- as.numeric(t(MU_k) %*% solve(VA) %*% MU_k)
      } else {
        q0 <- sum(MU^2 * ar) / s
      }
      a_crit <- qchisq(1 - alpha, df = K)

      if (local_alt || wald) {
        # Local alternative or Wald: use non-central chi-square directly
        if (calc_ss) {
          n_out <- .npnchi2(K, a_crit, beta) / q0
          D_out <- n_out * pibar
          list(n = n_out, power = power, D = D_out)
        } else {
          b <- pchisq(a_crit, df = K, ncp = n * q0)
          list(n = n, power = 1 - b, D = n * pibar)
        }
      } else {
        # Distant alternative, score test: use _pe2 / bisection
        W  <- 1 - 2 * ar
        a0 <- (sum(S) - sbar) / s
        q1 <- sum(MU^2 * S * ar) / s^2
        a1 <- (sum(S^2 * W) + sbar^2) / s^2

        if (calc_ss) {
          # Interval bisection to find n
          n0_approx <- .npnchi2(K, a_crit, beta) / q0

          b0 <- .pe2(a0, q0, a1, q1, K, n0_approx, a_crit)
          if (abs(b0 - beta) <= convcrit) {
            n_out <- n0_approx
          } else {
            if (b0 < beta) {
              nu <- n0_approx; nl <- n0_approx / 2
            } else {
              nl <- n0_approx; nu <- 2 * n0_approx
            }
            repeat {
              n_mid <- (nl + nu) / 2
              b_mid <- .pe2(a0, q0, a1, q1, K, n_mid, a_crit)
              if (abs(b_mid - beta) <= convcrit || (nu - nl) <= convcrit) {
                n_out <- n_mid
                break
              }
              if (b_mid < beta) nu <- n_mid else nl <- n_mid
            }
          }
          D_out <- n_out * pibar
          list(n = n_out, power = power, D = D_out)
        } else {
          b <- .pe2(a0, q0, a1, q1, K, n, a_crit)
          list(n = n, power = 1 - b, D = n * pibar)
        }
      }
    } else {
      # -------------------------------------------------------
      # Trend test (unconditional)
      # -------------------------------------------------------
      tr <- sum(MU * doses * ar)
      q0 <- sum(doses^2 * ar) * s

      if (local_alt) {
        q1 <- q0
      } else {
        q1 <- sum(doses^2 * S * ar)
      }

      za_crit <- if (wald) {
        sqrt(q1) * qnorm(1 - alpha / 2)
      } else {
        sqrt(q0) * qnorm(1 - alpha / 2)
      }

      if (calc_ss) {
        a_val <- za_crit + sqrt(q1) * qnorm(power)
        n_out <- (a_val / tr)^2
        D_out <- n_out * pibar
        list(n = n_out, power = power, D = D_out)
      } else {
        a_val <- abs(tr) * sqrt(n) - za_crit
        b     <- 1 - pnorm(a_val / sqrt(q1))
        list(n = n, power = 1 - b, D = n * pibar)
      }
    }
  } else {
    # -------------------------------------------------------
    # Conditional test (Peto's approximation)
    # -------------------------------------------------------
    v   <- pibar * (1 - pibar)
    LOR <- log(pr / (1 - pr)) - log(pr[1] / (1 - pr[1]))
    LOR[1] <- 0
    LOR <- LOR - sum(LOR * ar)

    if (!trend && is.null(doses)) {
      q0     <- sum(LOR^2 * ar)
      a_crit <- qchisq(1 - alpha, df = K)

      if (calc_ss) {
        l     <- .npnchi2(K, a_crit, beta)
        d_val <- (l + sqrt(l * (l - 4 * q0 * v))) / (2 * q0 * (1 - pibar))
        n_out <- d_val / pibar
        D_out <- d_val
        list(n = n_out, power = power, D = D_out)
      } else {
        d_val <- n * pibar
        l     <- d_val * (n - d_val) * q0 / (n - 1)
        b     <- pchisq(a_crit, df = K, ncp = l)
        list(n = n, power = 1 - b, D = d_val)
      }
    } else {
      # Conditional trend test
      tr     <- sum(doses * LOR * ar)
      q0     <- sum(doses^2 * ar)
      za_one <- qnorm(1 - alpha / 2)

      if (calc_ss) {
        a_val <- sqrt(q0) * (za_one + qnorm(power))
        l     <- (a_val / tr)^2
        d_val <- (l + sqrt(l * (l - 4 * v))) / (2 * (1 - pibar))
        n_out <- d_val / pibar
        D_out <- d_val
        list(n = n_out, power = power, D = D_out)
      } else {
        d_val <- n * pibar
        l     <- d_val * (n - d_val) / (n - 1)
        a_val <- abs(tr) * sqrt(l / q0) - za_one
        b     <- 1 - pnorm(a_val)
        list(n = n, power = 1 - b, D = d_val)
      }
    }
  }
}
