#' Sample size and power for binary outcome clinical trials
#'
#' Calculates sample size (given power) or power (given total sample size) for
#' clinical trials with binary outcomes, supporting two or more arms.
#'
#' @param pr Numeric vector of length >= 2. Anticipated event probabilities
#'   (`pi1^a, pi2^a, ...`). The first element is the control group; subsequent
#'   elements are treatment groups. All values must be strictly between 0 and 1.
#' @param margin Numeric in (-1, 1). Non-inferiority or substantial-superiority
#'   margin for the difference in proportions (`pi2 - pi1`). Use `0` (default)
#'   for a superiority trial. Only applies to 2-arm trials.
#'
#'   For an **unfavourable** outcome (lower probability is better):
#'   - `m > 0`: non-inferiority — H0: `pi2 - pi1 >= m`, H1: `pi2 - pi1 < m`
#'   - `m < 0`: substantial-superiority — H0: `pi2 - pi1 >= m`, H1: `pi2 - pi1 < m`
#'
#'   For a **favourable** outcome (higher probability is better), the
#'   inequalities are reversed:
#'   - `m < 0`: non-inferiority — H0: `pi2 - pi1 <= m`, H1: `pi2 - pi1 > m`
#'   - `m > 0`: substantial-superiority — H0: `pi2 - pi1 <= m`, H1: `pi2 - pi1 > m`
#' @param power Numeric in (0, 1). Desired power. Default `0.8`. Mutually
#'   exclusive with `n`.
#' @param n Integer. Total sample size, used to calculate power. Mutually
#'   exclusive with `power`.
#' @param aratios Numeric vector. Allocation ratios for groups 1, 2, ..., K.
#'   For a 2-arm trial, a scalar `r` is interpreted as `1:r`. Default: equal
#'   allocation to all groups.
#' @param ltfu Numeric in `[0, 1)`. Expected loss to follow-up proportion.
#'   Default `0`. The calculated sample size is inflated by `1 / (1 - ltfu)`
#'   before rounding.
#' @param alpha Numeric. Significance level. Interpreted as two-sided unless
#'   `onesided = TRUE`. Default `0.05`.
#' @param onesided Logical. If `TRUE`, `alpha` is interpreted as a one-sided
#'   level. `alpha(0.05)` is therefore equivalent to `alpha(0.025), onesided`.
#'   Not allowed for multi-group trials unless `trend` or `doses` is specified.
#'   Default `FALSE`.
#'
#'   Note: `artbin` always powers the trial for the direction of interest only,
#'   even when a two-sided alpha is given. This differs from [stats::power.prop.test()],
#'   which reports power for rejection in either direction.
#' @param trend Logical. Use a linear trend test (>=3 arms only). The default
#'   is a test for any difference between groups. See also `doses`. Default
#'   `FALSE`.
#' @param doses Numeric vector. Dose (or other quantitative) values for a
#'   linear trend test across groups (implies `trend = TRUE`). If fewer doses
#'   than groups are provided, the last dose value is repeated for remaining
#'   groups. Default when `trend = TRUE`: `1, 2, ..., K`. Not permitted for
#'   2-arm trials.
#' @param condit Logical. Use Peto's conditional test, which conditions on the
#'   total number of events and uses Peto's one-step approximation to the log
#'   odds ratio. This is also a good approximation for other conditional tests.
#'   Implies `local = TRUE`. Not available for non-inferiority or
#'   substantial-superiority trials, or with `wald` or `ccorrect`. Default
#'   `FALSE`.
#' @param wald Logical. Use the Wald test (null variance estimated from the
#'   sample). Default `FALSE` (score test). Cannot be combined with `local`,
#'   `condit`, or `ccorrect`.
#' @param ccorrect Logical. Apply a continuity correction. Not available with
#'   `condit`. 2-arm only. Default `FALSE`.
#' @param local Logical. Use local alternatives: the variance of the difference
#'   in proportions is computed under the null hypothesis only, rather than
#'   under both null and alternative. This approximation is reasonable when the
#'   odds ratio under the alternative is between about 0.5 and 2, but tends to
#'   give larger sample sizes than the default (distant alternatives) and is not
#'   generally recommended. It is included to allow comparisons with other
#'   software. Cannot be combined with `wald`. Default `FALSE`.
#' @param noround Logical. If `TRUE`, do not round sample sizes to integers.
#'   Default `FALSE` (round each group up to the nearest integer).
#'   Automatically set to `TRUE` when `n` is supplied.
#' @param favourable Logical or `NULL`. `TRUE` = favourable outcome (higher
#'   probability is better, e.g. survival); `FALSE` = unfavourable (lower is
#'   better, e.g. mortality). `NULL` (default) = infer from `pr` and `margin`:
#'   if `pi2^a > pi1^a + margin` the outcome is assumed favourable, otherwise
#'   unfavourable.
#' @param force Logical. If `TRUE`, suppress the error raised when the
#'   inferred outcome direction conflicts with the `favourable` argument. Useful
#'   when designing observational studies where a harmful risk factor reverses
#'   the usual favourability interpretation. Default `FALSE`.
#' @param nvmethod Integer (1, 2, or 3). Controls how null-hypothesis event
#'   probabilities are estimated in 2-arm trials. `1` = sample estimate (Wald);
#'   `2` = fixed marginal totals; `3` = constrained maximum likelihood (score,
#'   default). Setting `wald = TRUE` automatically uses `nvmethod = 1`; this
#'   argument is provided for comparisons with other software.
#' @param convcrit Numeric. Convergence criterion for the bisection algorithm
#'   used in k-group (>=3 arm) sample size calculations. Tighten (e.g. `1e-8`)
#'   if greater numerical precision is needed. Default `1e-7`.
#'
#' @details
#' All calculations are based on a Normal approximation to the difference in
#' proportions (or, with `condit`, to the score statistic). This approximation
#' may be unreliable for very small samples. As a guide, treat results with
#' caution when any expected cell count falls below 5 (the standard rule for
#' Pearson's chi-squared test). For small samples, consider using the continuity
#' correction (`ccorrect = TRUE`) or verifying the power by simulation.
#'
#' In a **multi-group trial**, `artbin` tests the global null hypothesis that
#' all probabilities are equal. The alternative is that at least two groups
#' differ.
#'
#' `artbin` can also be used to design observational studies. For a harmful
#' risk factor, the favourable/unfavourable outcome types are reversed relative
#' to a clinical trial; use `force = TRUE` to override the inferred direction.
#'
#' @return An object of class `"artbin"`, which is a named list containing:
#'   \describe{
#'     \item{`n`}{Total sample size (or the input `n` when computing power).}
#'     \item{`n_per_group`}{Named integer vector of per-group sample sizes
#'       (`group_1`, `group_2`, ...).}
#'     \item{`power`}{Power (designed or calculated).}
#'     \item{`D`}{Expected total number of events.}
#'     \item{`D_per_group`}{Named numeric vector of per-group expected events.}
#'     \item{`pr`, `margin`, `alpha`, `aratios`, `ltfu`}{Input parameters.}
#'     \item{`trial_type`}{`"superiority"`, `"non-inferiority"`, or
#'       `"substantial-superiority"`.}
#'     \item{`outcome`}{`"favourable"` or `"unfavourable"` (2-arm) or
#'       `"not determined"` (>2 arms).}
#'     \item{`onesided`, `wald`, `local`, `ccorrect`, `condit`, `trend`}{
#'       Logical flags as supplied.}
#'     \item{`calc_mode`}{`"sample_size"` or `"power"`.}
#'   }
#'
#' @references
#'   Marley-Zagar, E., White, I.R., Royston, P., Barthel, F.M.-S., Parmar,
#'   M.K.B. & Babiker, A.G. (2023). artbin: Extended sample size for
#'   randomised trials with binary outcomes. *Stata Journal*, **23**, 24–52.
#'   \doi{10.1177/1536867X231161971}
#'
#'   Quartagno, M., Walker, A.S., Babiker, A.G. et al. (2020). Handling an
#'   uncertain control group event risk in non-inferiority trials:
#'   non-inferiority frontiers and the power-stabilising transformation.
#'   *Trials*, **21**, 145. \doi{10.1186/s13063-020-4070-4}
#'
#'   Barthel, F.M.-S., Royston, P. & Babiker, A. (2005). A menu-driven facility
#'   for complex sample size calculations in randomized controlled trials with a
#'   survival or a binary outcome: update. *Stata Journal*, **5**, 123–129.
#'
#'   Farrington, C.P. & Manning, G. (1990). Test statistics and sample size
#'   formulae for comparative binomial trials with null hypothesis of
#'   non-zero risk difference or non-unity relative risk. *Statistics in
#'   Medicine*, **9**, 1447–1454.
#'
#' @examples
#' # 2-arm superiority trial (outcome inferred as favourable: pi2 > pi1)
#' artbin(pr = c(0.25, 0.35))
#'
#' # Same but with local alternatives (reasonable when OR is between 0.5 and 2)
#' artbin(pr = c(0.25, 0.35), local = TRUE)
#'
#' # Non-inferiority trial (unfavourable outcome)
#' artbin(pr = c(0.1, 0.1), margin = 0.2, wald = TRUE, power = 0.9, alpha = 0.1)
#'
#' # Calculate power for a given sample size
#' artbin(pr = c(0.25, 0.35), n = 400)
#'
#' # Four-arm superiority trial with unequal allocation (1:2:2:2)
#' artbin(pr = c(0.15, 0.25, 0.35, 0.45), aratios = c(1, 2, 2, 2))
#'
#' # Four-arm trial using a linear trend test
#' artbin(pr = c(0.15, 0.25, 0.35, 0.45), trend = TRUE)
#'
#' # With 20% loss to follow-up
#' artbin(pr = c(0.25, 0.35), ltfu = 0.2)
#'
#' @export
artbin <- function(pr,
                   margin    = 0,
                   power     = NULL,
                   n         = NULL,
                   aratios   = NULL,
                   ltfu      = 0,
                   alpha     = 0.05,
                   onesided  = FALSE,
                   trend     = FALSE,
                   doses     = NULL,
                   condit    = FALSE,
                   wald      = FALSE,
                   ccorrect  = FALSE,
                   local     = FALSE,
                   noround   = FALSE,
                   favourable = NULL,
                   force     = FALSE,
                   nvmethod  = NULL,
                   convcrit  = 1e-7) {

  # -------------------------------------------------------------------------
  # Input validation
  # -------------------------------------------------------------------------
  if (!is.null(n) && !is.null(power)) {
    cli::cli_abort("Cannot specify both {.arg n} and {.arg power}.")
  }
  if (is.null(n) && is.null(power)) power <- 0.8

  npr <- length(pr)
  if (npr < 2) {
    cli::cli_abort("At least two event probabilities required in {.arg pr}.")
  }
  if (any(pr <= 0) || any(pr >= 1)) {
    cli::cli_abort("All event probabilities in {.arg pr} must be strictly between 0 and 1.")
  }
  if (!is.null(margin) && margin != 0 && npr > 2) {
    cli::cli_abort("Cannot use {.arg margin} with more than 2 groups.")
  }
  if (npr == 2 && min(pr) == max(pr) && (is.null(margin) || margin == 0)) {
    cli::cli_abort("Event probabilities cannot be equal for a 2-group superiority trial.")
  }
  if (alpha <= 0 || alpha >= 1) {
    cli::cli_abort("{.arg alpha} must be in (0, 1).")
  }
  if (!is.null(power) && (power <= 0 || power >= 1)) {
    cli::cli_abort("{.arg power} must be in (0, 1).")
  }
  if (!is.null(n) && n <= 0) {
    cli::cli_abort("{.arg n} must be a positive integer.")
  }
  if (ltfu < 0 || ltfu >= 1) {
    cli::cli_abort("{.arg ltfu} must be in [0, 1).")
  }

  # Deprecated syntax checks
  if (!is.null(getOption("artbin.check_old_syntax")) &&
      isTRUE(getOption("artbin.check_old_syntax"))) {
    # placeholder for future checks
  }

  # Conflict checks
  if (local && wald) {
    cli::cli_abort("{.arg local} and {.arg wald} cannot both be TRUE.")
  }
  if (condit && wald) {
    cli::cli_abort("{.arg condit} and {.arg wald} cannot both be TRUE.")
  }
  # nvmethod: user-supplied value takes precedence; wald defaults to 1, else 3
  user_supplied_nvm <- !is.null(nvmethod)
  if (wald) {
    if (user_supplied_nvm && as.integer(nvmethod) != 1L) {
      cli::cli_abort("Need {.arg nvmethod = 1} when {.arg wald = TRUE}.")
    }
    nvmethod <- 1L
  } else {
    if (is.null(nvmethod)) nvmethod <- 3L
    nvmethod <- as.integer(nvmethod)
    if (nvmethod < 1L || nvmethod > 3L) nvmethod <- 3L
  }
  if (local && nvmethod != 3L) {
    cli::cli_abort("Need {.arg nvmethod = 3} when {.arg local = TRUE}.")
  }
  if (!is.null(margin) && margin != 0 && condit) {
    cli::cli_abort("Cannot use {.arg condit} for non-inferiority / substantial-superiority trials.")
  }
  if (npr == 2 && trend) {
    cli::cli_abort("Cannot use {.arg trend} for a 2-arm trial.")
  }
  if (npr == 2 && !is.null(doses)) {
    cli::cli_abort("Cannot use {.arg doses} for a 2-arm trial.")
  }
  if (!is.null(doses)) trend <- TRUE

  # Conditional implies local
  if (condit && !local) {
    cli::cli_alert_info("As {.arg condit = TRUE}, {.arg local} will be set to TRUE.")
    local <- TRUE
  }

  if (ccorrect && npr > 2) {
    cli::cli_abort("Continuity correction is not available for more than 2 groups.")
  }
  if (onesided && npr > 2 && !trend && is.null(doses)) {
    cli::cli_abort("One-sided test is not allowed for >2 groups unless trend/doses are specified.")
  }

  # Allocation ratios
  if (!is.null(aratios)) {
    if (any(aratios <= 0)) cli::cli_abort("All {.arg aratios} must be positive.")
    if (npr > 2 && length(aratios) < npr) {
      cli::cli_abort(
        "Please supply the same number of {.arg aratios} as {.arg pr} for >2 groups."
      )
    }
  }

  # favourable / unfavourable check
  if (!is.null(favourable) && !is.logical(favourable)) {
    cli::cli_abort("{.arg favourable} must be TRUE, FALSE, or NULL.")
  }

  # When n is given, don't round
  calc_ss <- is.null(n)
  if (!calc_ss) noround <- TRUE

  obsfrac <- 1 - ltfu

  # -------------------------------------------------------------------------
  # Normalise allocation ratios
  # For 2-arm, a single ratio r means 1:r (first group = 1, second = r)
  # -------------------------------------------------------------------------
  if (is.null(aratios)) {
    allr <- rep(1, npr)
  } else if (npr == 2 && length(aratios) == 1) {
    allr <- c(1, aratios)
  } else {
    allr <- aratios[seq_len(npr)]
  }
  # Rescale so allr[1] == 1 (matches Stata rounding logic)
  if (allr[1] != 1) allr <- allr / allr[1]
  totalallr <- sum(allr)

  # -------------------------------------------------------------------------
  # Infer / check trial outcome direction (2-arm only)
  # -------------------------------------------------------------------------
  trial_type <- "superiority"
  outcome    <- if (npr == 2) NA_character_ else "not determined"
  H0 <- H1 <- NULL
  niss <- !is.null(margin) && margin != 0

  if (npr == 2) {
    p1_ctrl <- pr[1]; p2_trt <- pr[2]
    threshold <- p1_ctrl + margin

    if (p2_trt == threshold) {
      cli::cli_abort("p2 cannot equal p1 + margin.")
    }

    inferred_fav <- p2_trt > threshold  # TRUE = favourable

    if (is.null(favourable)) {
      outcome <- if (inferred_fav) "favourable" else "unfavourable"
    } else {
      outcome <- if (favourable) "favourable" else "unfavourable"
      # Check consistency
      if (favourable && !inferred_fav) {
        if (!force) {
          cli::cli_abort(
            "artbin thinks your outcome is unfavourable. Check your command, \\
             or set {.arg force = TRUE}."
          )
        } else {
          cli::cli_warn("artbin thinks your outcome should be unfavourable.")
        }
      }
      if (!favourable && inferred_fav) {
        if (!force) {
          cli::cli_abort(
            "artbin thinks your outcome is favourable. Check your command, \\
             or set {.arg force = TRUE}."
          )
        } else {
          cli::cli_warn("artbin thinks your outcome should be favourable.")
        }
      }
    }

    # Trial type
    if ((outcome == "unfavourable" && margin > 0) ||
        (outcome == "favourable"   && margin < 0)) {
      trial_type <- "non-inferiority"
    } else if ((outcome == "unfavourable" && margin < 0) ||
               (outcome == "favourable"   && margin > 0)) {
      trial_type <- "substantial-superiority"
    }

    if (outcome == "unfavourable") {
      H0 <- paste0("H0: pi2 - pi1 >= ", margin)
      H1 <- paste0("H1: pi2 - pi1 < ",  margin)
    } else {
      H0 <- paste0("H0: pi2 - pi1 <= ", margin)
      H1 <- paste0("H1: pi2 - pi1 > ",  margin)
    }
  }

  # -------------------------------------------------------------------------
  # Core calculation
  # -------------------------------------------------------------------------
  # Determine allocation ratio for art2bin (r = n1/n0)
  r_2arm <- allr[2] / allr[1]

  if (npr == 2 && !condit) {
    # Two-arm path: use .art2bin
    alpha_2arm <- alpha  # art2bin handles onesided internally

    # When calculating power from given n:
    # split n into per-group using allocation ratio (use observed fraction)
    if (!calc_ss) {
      n_obs <- round(n * obsfrac)  # art2bin works with observed n
      n0_in <- floor(n_obs / (1 + r_2arm))
      n1_in <- n_obs - n0_in
    } else {
      n0_in <- 0; n1_in <- 0
    }

    res2 <- .art2bin(
      p0        = pr[1],
      p1        = pr[2],
      margin    = margin,
      n0        = n0_in,
      n1        = n1_in,
      r         = r_2arm,
      alpha     = alpha_2arm,
      power     = if (calc_ss) power else 0.8,
      nvmethod  = nvmethod,
      onesided  = onesided,
      ccorrect  = ccorrect,
      local_alt = local,
      wald      = wald,
      calc_ss   = calc_ss
    )

    n_raw   <- res2$n  # unrounded total (or input n)
    pow_out <- res2$power

  } else {
    # K-group path (or 2-arm conditional)
    # Normalise allocation ratios to sum to 1
    ar_norm <- allr / sum(allr)

    # For one-sided test in k-group: double alpha before use
    alpha_k <- if (onesided) 2 * alpha else alpha

    # Handle n -> power: use observed n
    n_k <- if (!calc_ss) round(n * obsfrac) else 0

    resk <- .artbin_kgroup(
      pr        = pr,
      ar        = ar_norm,
      alpha     = alpha_k,
      power     = if (calc_ss) power else 0.8,
      n         = n_k,
      trend     = trend,
      doses     = doses,
      condit    = condit,
      wald      = wald,
      local_alt = local,
      convcrit  = convcrit
    )

    n_raw   <- resk$n
    pow_out <- resk$power
  }

  # -------------------------------------------------------------------------
  # Rounding and per-group sample sizes (matches Stata logic)
  # -------------------------------------------------------------------------
  nbygroup <- n_raw / totalallr

  n_groups <- numeric(npr)
  names(n_groups) <- paste0("group_", seq_len(npr))

  if (calc_ss) {
    for (a in seq_len(npr)) {
      if (noround) {
        n_groups[a] <- nbygroup * allr[a] / obsfrac
      } else {
        n_groups[a] <- ceiling(nbygroup * allr[a] / obsfrac)
      }
    }
    ntotal <- sum(n_groups)
  } else {
    ntotal <- n
    for (a in seq_len(npr)) {
      n_groups[a] <- ntotal * allr[a] / totalallr
    }
  }

  # Expected events
  d_groups <- n_groups * pr * obsfrac
  names(d_groups) <- paste0("group_", seq_len(npr))
  D_total <- sum(d_groups)

  # -------------------------------------------------------------------------
  # Allocation ratio display string
  # -------------------------------------------------------------------------
  if (all(allr == 1)) {
    allocr_str <- "equal group sizes"
  } else {
    allocr_str <- paste(allr, collapse = ":")
  }

  # -------------------------------------------------------------------------
  # Build return object
  # -------------------------------------------------------------------------
  structure(
    list(
      n           = as.integer(ntotal),
      n_per_group = n_groups,
      power       = pow_out,
      D           = D_total,
      D_per_group = d_groups,
      # Input parameters
      pr          = pr,
      margin      = margin,
      alpha       = alpha,
      aratios     = allr,
      aratios_str = allocr_str,
      ltfu        = ltfu,
      # Trial description
      trial_type  = trial_type,
      outcome     = outcome,
      H0          = H0,
      H1          = H1,
      # Flags
      onesided    = onesided,
      wald        = wald,
      local       = local,
      ccorrect    = ccorrect,
      condit      = condit,
      trend       = trend,
      doses       = doses,
      nvmethod    = nvmethod,
      noround     = noround,
      calc_mode   = if (calc_ss) "sample_size" else "power"
    ),
    class = "artbin"
  )
}

#' @export
print.artbin <- function(x, ...) {
  width <- 78
  off   <- 40

  pad <- function(label, value, width = off) {
    label_pad <- formatC(label, width = -(width - 2), flag = "-")
    cat(label_pad, value, "\n", sep = "")
  }

  cat("\nART - ANALYSIS OF RESOURCES FOR TRIALS\n")
  cat(strrep("-", width), "\n", sep = "")
  cat("A sample size program by Abdel Babiker, Patrick Royston,\n")
  cat("Friederike Barthel, Ella Marley-Zagar and Ian White\n")
  cat("MRC Clinical Trials Unit at UCL, London WC1V 6LJ, UK.\n")
  cat(strrep("-", width), "\n", sep = "")

  pad("Type of trial", x$trial_type)
  pad("Number of groups", length(x$pr))

  if (length(x$pr) == 2) {
    pad("Favourable/unfavourable outcome", x$outcome)
  } else {
    pad("Favourable/unfavourable outcome", x$outcome)
  }

  pad("Allocation ratio", x$aratios_str)

  test_desc <- if (length(x$pr) == 2 || (length(x$pr) > 2 && !x$condit)) {
    if (length(x$pr) == 2) {
      "unconditional comparison of 2 binomial proportions"
    } else if (x$trend) {
      paste0("Linear trend test")
    } else {
      paste0("unconditional comparison of ", length(x$pr), " binomial proportions")
    }
  } else {
    "Conditional test using Peto's approximation to the odds ratio"
  }
  pad("Statistical test assumed", test_desc)

  wald_str <- if (x$wald) "  using the wald test" else "  using the score test"
  cat(formatC("", width = -(off - 2), flag = "-"), wald_str, "\n", sep = "")

  pad("Local or distant", if (x$local) "local" else "distant")
  pad("Continuity correction", if (x$ccorrect) "yes" else "no")

  if (!is.null(x$H0) && x$trial_type != "superiority") {
    pad("Null hypothesis",        x$H0)
    pad("Alternative hypothesis", x$H1)
  }

  pr_str <- paste(formatC(x$pr, format = "f", digits = 3), collapse = "  ")
  cat("\n")
  pad("Anticipated event probabilities", pr_str)

  sided_str <- if (x$onesided) "one-sided" else "two-sided"
  cat("\n")
  pad("Alpha", sprintf("%.3f (%s)", x$alpha, sided_str))
  if (!x$onesided) {
    cat(formatC("", width = -(off - 2), flag = "-"),
        sprintf("  (taken as %.3f one-sided)", x$alpha / 2), "\n", sep = "")
  }

  if (x$calc_mode == "sample_size") {
    pad("Power (designed)", sprintf("%.3f", x$power))
  } else {
    pad("Power (calculated)", sprintf("%.3f", x$power))
  }

  if (x$ltfu > 0) {
    cat("\n")
    pad("Loss to follow up assumed", sprintf("%.0f %%", x$ltfu * 100))
  }

  mess <- if (x$calc_mode == "sample_size") "(calculated)" else "(designed)"
  cat("\n")
  pad(paste("Total sample size", mess),       x$n)

  n_str <- paste(x$n_per_group, collapse = " ")
  pad(paste("Sample size per group", mess),   n_str)

  pad("Expected total number of events",      sprintf("%.2f", x$D))

  d_str <- paste(sprintf("%.2f", x$D_per_group), collapse = " ")
  pad("Expected number of events per group",  d_str)

  cat(strrep("-", width), "\n", sep = "")
  invisible(x)
}
