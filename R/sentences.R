#' Split sentences
#'
#' Split text into individual sentences using openNLP.
#'
#' @param text Text to split into sentences.
#' @param nclusters Number of clusters to use for running openNLP
#' @return List of same size as text with each element a vector of sentences.
SplitSentences <- function(text, nclusters=parallel::detectCores()) {
  cl <- makeCluster(nclusters)
  clusterEvalQ(cl, {
    library(openNLP)
    library(NLP)
    library(data.table)
    sent_token_annotator <- openNLP::Maxent_Sent_Token_Annotator()
  })

  res <- pbapply::pblapply(text, function(t) {
    if (nchar(t)) {
      try({
        tokenized <- NLP::annotate(t, list(sent_token_annotator))
        as.data.table(tokenized)[type == "sentence", list(start, end)]
      })
    }
  }, cl=cl)

  stopCluster(cl)
  res
}

#' Last sentence
#'
#' Returns last sentence of a piece of text.
#'
#' @param text Text to use.
#' @param nclusters Number of clusters to use for running openNLP to
#'   detect sentences.
#' @return Last sentence of text.
LastSentence <- function(text, nclusters=parallel::detectCores()) {
  sentences <- SplitSentences(text, nclusters)
  mapply(function(s, t) {
    if (is.null(s) || inherits(s, "try-error") || nrow(s) == 0) {
      NA_character_
    } else {
      s[.N, substr(t, start, end)]
    }
  }, sentences, text)
}

#' First sentence
#'
#' Returns first sentence of a piece of text.
#'
#' @param text Text to use.
#' @param nclusters Number of clusters to use for running openNLP to
#'   detect sentences.
#' @return First sentence of text.
FirstSentence <- function(text, nclusters=parallel::detectCores()) {
  sentences <- SplitSentences(text, nclusters)
  mapply(function(s, t) {
    if (is.null(s) || inherits(s, "try-error")) {
      NA_character_
    } else {
      s[1, substr(t, start, end)]
    }
  }, sentences, text)
}
