library(dplyr)

csvmapping <- function(vec, file) {
	replacements <- read.csv(file)

    vec <- gsub("^ *", "", gsub(" *$", "", gsub("  *", " ", gsub("[^A-Za-z0-9]", " ", tolower(vec)))))

    vec <- plyr::mapvalues(vec, replacements$string, replacements$replacement)    

    vec[vec == "NA" | vec == ""] <- NA

    vec
}

trimtolower <- function(vec) {
	gsub("^ *", "", gsub(" *$", "", gsub("  *", " ", gsub("[^A-Za-z0-9]", " ", tolower(vec)))))
}

replaceNa <- function(vec, DV) {
	sapply(vec, function(x) { if (is.na(x)) DV else x })
}