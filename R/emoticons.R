#' Escape regular expressions
#'
#' @param re A regular expression to escape.
#' @return The escaped regular expression.
EscapeRegex <- function(re) {
  re <- gsub("\\\\", "\\\\\\\\", re)
  re <- gsub("\\)", "\\\\)", re)
  re <- gsub("\\(", "\\\\(", re)
  re <- gsub("\\|", "\\\\|", re)
  re <- gsub("\\[", "\\\\[", re)
  re <- gsub("\\{", "\\\\{", re)
  re <- gsub("\\}", "\\\\}", re)
  re <- gsub("\\^", "\\\\^", re)
  re <- gsub("\\$", "\\\\$", re)
  re <- gsub("\\*", "\\\\*", re)
  re <- gsub("\\+", "\\\\+", re)
  re <- gsub("\\?", "\\\\?", re)
  gsub("\\.", "\\\\.", re)
}

#' Emoticon regex
#'
#' Builds emoticon regex
#'
#' @param emoticon.re Regular expressions for each emoticon.
#' @param front Regular expression for symbols that can appear in
#'   front of the emoticon.
#' @param back Regular expression for symbols that can appear behind
#'   the emoticon.
#' @return A single regular expression for all emoticons.
EmoticonRegex <- function(emoticon.re, front, back) {
  emoticon.re <- paste(emoticon.re, collapse="|")
  if (back == "" & front == "") {
    sprintf("(^|(?<=(\\s)))(%s)($|(?=(\\s)))", emoticon.re)
  } else if (back == "") {
    sprintf("(^|(?<=(\\s|%s)))(%s)($|(?=(\\s)))", front, emoticon.re)
  } else if (front == "") {
    sprintf("(^|(?<=(\\s)))(%s)($|(?=(\\s|%s)))", emoticon.re, back)
  } else {
    sprintf("(^|(?<=(\\s|%s)))(%s)($|(?=(\\s|%s)))", front, emoticon.re, back)
  }
}

#' Find regex
#'
#' Builds a data.table object from locations matching a set of regular
#' expressions.
#'
#' @param text Text to find regular expressions in.
#' @param regex The regular expressions.
#' @param include.text If TRUE, includes the original text in the
#'   table.
#' @return A data.table object with the result of the regex extracted
#'   and where it starts and ends in the original text.
FindRegex <- function(text, regex, include.text=TRUE) {
  rbindlist(lapply(regex, function(re) {
    res <- str_locate_all(text, re)
    res <- rbindlist(lapply(which(sapply(res, nrow) > 0), function(id) {
      as.data.table(cbind(id=id, res[[id]]))
    }))
    if (nrow(res)) {
      res[, emoticon := str_sub(text[id], start, end)]
      if (include.text) {
        res[, text := text[id]]
      }
      res
    }
  }))
}

#' Find emoticons
#'
#' @param text The text to find emoticons in.
#' @param emoticons Regular expressions for detecting emoticons.
#' @param include.text If TRUE, includes the original text in the
#'   table.
#' @return A data.tabble object with emoticons extracted from the text.
#' @export
FindEmoticons <- function(text, emoticons=emoticons.re, include.text=TRUE) {
  emoticons.re <- emoticons[, list(re=EmoticonRegex(regex, front, back)),
                            by=c("front", "back")]
  FindRegex(text, emoticons.re$re, include.text)
}

#' Find Unicode emojis
#'
#' @param text Text to find emojis in.
#' @param include.text If TRUE, includes the original text in the
#'   table.
#' @return A data.table object with emojis extracted from the text.
#' @export
FindUnicodeEmojis <- function(text, include.text=TRUE) {
  regex <- sprintf("[%s]", paste(emojis[nchar == 1, char], collapse=""))
  FindRegex(text, regex, include.text)
}

#' Find Unicode emoji sequences
#'
#' @param text Text to find emoji sequences in.
#' @param include.text If TRUE, includes the original text in the
#'   table.
#' @return A data.table object with emoji sequences extracted from the text.
FindUnicodeEmojisSeq <- function(text, include.text=TRUE) {
  regex <- paste(emojis$char, collapse="|")
  FindRegex(text, regex, include.text)
}

re.slack.emoji <- "(:[-+_[:alnum:]]+:)"

#' Find Slack emojis
#'
#' @param text Text to find emojis in.
#' @param include.text If TRUE, includes the original text in the
#'   table.
#' @return A data.table object with emojis extracted from the text.
#' @export
FindSlackEmojis <- function(text, include.text=TRUE) {
  FindRegex(text, re.slack.emoji, include.text)
}

#' Find emoticons and emojis
#'
#' @param data Data.table of data to find emoticons and emojis in.
#' @param text.col Name of the column containing the text.
#' @param cols Columns from data to keep. If NULL, then uses the key
#'   of data.
#' @param include.text If TRUE, includes the original text in the
#'   table.
#' @param funcs List of functions to use for identifying emoticons and
#'   emojis.
#' @return A data.table object with emoticons and emojis extracted
#'   from the text and subset of columns from data.
#' @export
EmoticonsAndEmojis <- function(data, text.col="text",
                               cols=NULL, include.text=TRUE,
                               funcs=list(emoticon=FindEmoticons,
                                          emoji=FindUnicodeEmojis,
                                          #emoji.seq=FindUnicodeEmojisSeq,
                                          slack=FindSlackEmojis)) {
  res <- rbindlist(lapply(names(funcs), function(f) {
    res <- funcs[[f]](data[[text.col]], include.text=include.text)
    if (nrow(res)) cbind(res, type=f)
  }))
  if (is.data.table(data)) {
    data <- data[res$id, if (is.null(cols)) key(data) else cols, with=FALSE]
  } else if (is.data.frame(data) & !is.null(cols)) {
    data[res$id, cols]
  } else {
    data <- data.table()
  }
  if (nrow(data)) {
    res$id <- NULL
    cbind(data, res)
  } else res
}

#' Text before and after emoticons
#'
#' Computes text before and after emoticons.
#'
#' @param emoticons Emoticon data.table object.
#' @param nclusters Number of clusters to use for running openNLP to
#'   detect sentences.
#' @return Emoticon data.table object with \code{text.before},
#'   \code{text.after}, \code{sentence.before} and
#'   \code{sentence.after} columns added.
#' @export
TextBeforeAfterEmoticons <- function(emoticons,
                                     nclusters=parallel::detectCores()) {
  emoticons[, text.before := substr(text, shift(end, fill=0) + 1, start - 1),
            by=list(source, bug.id, comment.id)]
  emoticons[, text.after := substr(text, end + 1, shift(start, type="lead",
                                                        fill=nchar(text[1]))),
            list(source, bug.id, comment.id)]
  logging::loginfo("Computing sentence before")
  emoticons[, sentence.before := LastSentence(text.before, nclusters)]
  logging::loginfo("Computing sentence after")
  emoticons[, sentence.after := FirstSentence(text.after, nclusters)]
  emoticons
}
