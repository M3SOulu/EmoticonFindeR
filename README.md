[![Build Status](https://travis-ci.org/M3SOulu/EmoticonFindeR.svg?branch=master)](https://travis-ci.org/M3SOulu/EmoticonFindeR)
[![Coverage Status](https://img.shields.io/codecov/c/github/M3SOulu/EmoticonFindeR/master.svg)](https://codecov.io/github/M3SOulu/EmoticonFindeR?branch=master)

# Emotion FindeR

Set of functions to find emoticons and emojis in textual data.

## Installation

<!-- From CRAN: -->

<!--     install.packages("EmoticonFindeR") -->

With devtools:

    devtools::install_github("M3SOulu/EmoticonFindeR")


## Example Usage

The package contains individual functions to extract emoticons,
Unicode emojis and Slack emojis from character strings.

    FindEmoticons(text)
    FindUnicodeEmojis(text)
    FindSlackEmojis(text)

They output a data.table object and the three function can be run at
once using the EmoticonsAndEmojis function. This once takes as input a
table where one of the column contains the character string to look
for emoticons. The package also contain a function to extract the text
preceding and following each identified emoticon or emoji:

    emoticons <- EmoticonsAndEmojis(data, text.col="text")
    TextBeforeAfter(emoticons)

<!-- ## Paper and Citation -->
