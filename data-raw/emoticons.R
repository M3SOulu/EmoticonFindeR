library(data.table)

## Emoticons Regex

emoticons.re <- fread("emoticons_regex.csv")
Encoding(emoticons.re$emoticon) <- "UTF-8"
Encoding(emoticons.re$regex) <- "UTF-8"
## usethis::use_data(emoticons.re, overwrite=TRUE)

## Emojis

emojis <- rbindlist(lapply(dir("kgarrett-emojis/data"), function(f) {
  cbind(fread(file.path("kgarrett-emojis/data", f)), file=f)
}))
emojis <- emojis[, list(code, char=browser,
                        name=cldr_short_name,
                        type=sub("\\.csv$", "", file),
                        nchar=nchar(browser))]
Encoding(emojis$char) <- "UTF-8"
Encoding(emojis$name) <- "UTF-8"

## usethis::use_data(emojis, overwrite=TRUE)

## Internal data

usethis::use_data(emoticons.re, emojis, internal=TRUE, overwrite=TRUE)
