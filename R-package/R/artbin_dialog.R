#' Open the artbin dialog
#'
#' Launches an interactive Shiny dialog for the [artbin()] function.
#' Requires the \pkg{shiny} package.
#'
#' @return Invisibly returns `NULL`. Called for its side effect (opening a
#'   browser window).
#'
#' @export
artbin_dialog <- function() {
  if (!requireNamespace("shiny", quietly = TRUE))
    stop("Package 'shiny' is required. Install it with install.packages('shiny').",
         call. = FALSE)
  app_dir <- system.file("shiny", "artbin", package = "artbin")
  shiny::runApp(app_dir, display.mode = "normal")
}
