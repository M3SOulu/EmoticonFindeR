#' Emoticon Regular Expressions
#'
#' Regular expressions for detecting emoticons.
#'
#' @format A \code{data.table} object with X rows and X columns:
#' \describe{
#'   \item{emoticon}{The emoticon.}
#'   \item{regex}{The regular expression matching the emoticon.}
#'   \item{front}{The regular expression matching what can be in front of the emoticon.}
#'   \item{back}{The regular expression matching what can be behind the emoticon.}
#' }
"emoticons.re"

#' Emojis
#'
#' List of emojis.
#'
#' @format A \code{data.table} object with X rows and X columns:
#' \describe{
#'   \item{code}{Unicode code point.}
#'   \item{char}{Unicode characters.}
#'   \item{name}{Emoji short name.}
#'   \item{type}{Emoji category.}
#'   \item{nchar}{Number of Unicode characters.}
#' }
#' @source \url{https://data.world/kgarrett/emojis}
"emojis"
