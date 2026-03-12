library(shiny)
library(artbin)

ui <- fluidPage(
  titlePanel("ART - Binary outcomes"),

  fluidRow(
    column(12,
      wellPanel(
        h4("Set-up"),
        fluidRow(
          column(3,
            textInput("pr",    "Anticipated probabilities", placeholder = "e.g. 0.1 0.2")
          ),
          column(3,
            textInput("margin", "Margin (NI/SS only)", placeholder = "e.g. 0.1")
          ),
          column(3,
            radioButtons("outcome", NULL,
                         choices = c("Favourable" = "fav", "Unfavourable" = "unfav"),
                         selected = "unfav", inline = TRUE)
          ),
          column(3,
            textInput("aratios", "Allocation ratios", placeholder = "e.g. 1 2")
          )
        ),
        fluidRow(
          column(3,
            radioButtons("calc_mode", NULL,
                         choices = c("Specify power" = "power", "Specify sample size" = "n"),
                         selected = "power", inline = TRUE)
          ),
          column(3,
            numericInput("pow_n", "Power or N", value = 0.8, min = 0, step = 0.05)
          ),
          column(3,
            numericInput("alpha", "Alpha", value = 0.05, min = 0.001, max = 0.5, step = 0.005)
          ),
          column(3,
            checkboxInput("onesided", "One-sided test (alpha)", value = FALSE)
          )
        ),
        fluidRow(
          column(3,
            checkboxInput("trend", "Trend", value = FALSE)
          ),
          column(3,
            conditionalPanel(
              condition = "input.trend == true",
              textInput("doses", "Doses", placeholder = "e.g. 0 1 2")
            )
          ),
          column(3,
            textInput("ltfu", "Loss to follow-up", placeholder = "e.g. 0.1")
          )
        )
      ),

      wellPanel(
        h4("Options"),
        fluidRow(
          column(3,
            checkboxInput("score", "Score test (default)", value = FALSE)
          ),
          column(3,
            checkboxInput("wald",  "Wald test",            value = FALSE)
          ),
          column(3,
            checkboxInput("local", "Local alternatives",   value = FALSE)
          ),
          column(3,
            checkboxInput("condit", "Conditional test (Peto)", value = FALSE)
          )
        ),
        fluidRow(
          column(3,
            checkboxInput("ccorrect", "Continuity correction", value = FALSE)
          ),
          column(3,
            checkboxInput("noround", "Do not round",           value = FALSE)
          )
        )
      ),

      fluidRow(
        column(12,
          actionButton("run", "Run artbin", class = "btn-primary"),
          actionButton("reset", "Reset")
        )
      ),

      br(),
      verbatimTextOutput("result")
    )
  ),

  tags$head(tags$style(HTML("
    .shiny-input-container { margin-bottom: 4px; }
    #result { min-height: 80px; }
  ")))
)

server <- function(input, output, session) {

  # --- mutual exclusions ---------------------------------------------------

  # score <-> wald
  observeEvent(input$score,  {
    if (input$score)  updateCheckboxInput(session, "wald",  value = FALSE)
  })
  observeEvent(input$wald, {
    if (input$wald) {
      updateCheckboxInput(session, "score",  value = FALSE)
      updateCheckboxInput(session, "local",  value = FALSE)
      updateCheckboxInput(session, "condit", value = FALSE)
    }
  })

  # local -> disable wald
  observeEvent(input$local, {
    if (input$local)  updateCheckboxInput(session, "wald", value = FALSE)
  })

  # condit -> disable wald
  observeEvent(input$condit, {
    if (input$condit) updateCheckboxInput(session, "wald", value = FALSE)
  })

  # --- reset ---------------------------------------------------------------

  observeEvent(input$reset, {
    updateTextInput(session, "pr",      value = "")
    updateTextInput(session, "margin",  value = "")
    updateTextInput(session, "aratios", value = "")
    updateRadioButtons(session, "outcome",   selected = "unfav")
    updateRadioButtons(session, "calc_mode", selected = "power")
    updateNumericInput(session, "pow_n",  value = 0.8)
    updateNumericInput(session, "alpha",  value = 0.05)
    updateCheckboxInput(session, "onesided", value = FALSE)
    updateCheckboxInput(session, "trend",    value = FALSE)
    updateTextInput(session, "doses", value = "")
    updateTextInput(session, "ltfu",  value = "")
    updateCheckboxInput(session, "score",    value = FALSE)
    updateCheckboxInput(session, "wald",     value = FALSE)
    updateCheckboxInput(session, "local",    value = FALSE)
    updateCheckboxInput(session, "condit",   value = FALSE)
    updateCheckboxInput(session, "ccorrect", value = FALSE)
    updateCheckboxInput(session, "noround",  value = FALSE)
    output$result <- renderPrint({ invisible(NULL) })
  })

  # --- run -----------------------------------------------------------------

  observeEvent(input$run, {
    output$result <- renderPrint({
      pr_vec <- tryCatch(as.numeric(strsplit(trimws(input$pr), "\\s+")[[1]]),
                         warning = function(e) NULL, error = function(e) NULL)
      if (is.null(pr_vec) || length(pr_vec) < 2)
        stop("'Anticipated probabilities' must contain at least two numbers.", call. = FALSE)

      args <- list(pr = pr_vec)

      margin_s <- trimws(input$margin)
      if (nchar(margin_s) > 0) args$margin <- as.numeric(margin_s)

      aratios_s <- trimws(input$aratios)
      if (nchar(aratios_s) > 0)
        args$aratios <- as.numeric(strsplit(aratios_s, "\\s+")[[1]])

      ltfu_s <- trimws(input$ltfu)
      if (nchar(ltfu_s) > 0) args$ltfu <- as.numeric(ltfu_s)

      args$alpha    <- input$alpha
      args$onesided <- input$onesided

      if (input$calc_mode == "power") {
        args$power <- input$pow_n
      } else {
        args$n <- as.integer(input$pow_n)
      }

      if (input$outcome == "fav")   args$favourable <- TRUE
      if (input$outcome == "unfav") args$favourable <- FALSE

      if (input$trend) {
        args$trend <- TRUE
        doses_s <- trimws(input$doses)
        if (nchar(doses_s) > 0)
          args$doses <- as.numeric(strsplit(doses_s, "\\s+")[[1]])
      }

      if (input$wald)     args$wald     <- TRUE
      if (input$local)    args$local    <- TRUE
      if (input$condit)   args$condit   <- TRUE
      if (input$ccorrect) args$ccorrect <- TRUE
      if (input$noround)  args$noround  <- TRUE

      result <- do.call(artbin, args)
      print(result)
    })
  })
}

shinyApp(ui, server)
