# Score every file in results/ against the answer key.
# Run from the testing folder: Rscript R/03_score.R
key    <- read.csv("key/key.csv", colClasses = "character", na.strings = "")
fields <- c("station", "date", "species", "count", "habitat")
files  <- list.files("results", pattern = "\\.csv$", full.names = TRUE)

score <- function(file) {
  pred <- read.csv(file, colClasses = "character", na.strings = "")
  pred <- pred[match(key$note_id, pred$note_id), ]
  rows <- lapply(fields, function(f) {
    k <- trimws(key[[f]]); p <- trimws(pred[[f]])
    same <- (is.na(k) & is.na(p)) | (!is.na(k) & !is.na(p) & k == p)
    data.frame(file = basename(file), field = f,
               correct  = sum(same),
               wrong    = sum(!is.na(k) & !is.na(p) & k != p),
               missed   = sum(!is.na(k) & is.na(p)),
               invented = sum(is.na(k) & !is.na(p)))
  })
  do.call(rbind, rows)
}

scores <- do.call(rbind, lapply(files, score))
print(scores, row.names = FALSE)
cat("\nCorrect cells out of", nrow(key) * length(fields), "\n")
print(tapply(scores$correct, scores$file, sum))

# Disagreements, so that each error can be read rather than only counted.
for (file in files) {
  pred <- read.csv(file, colClasses = "character", na.strings = "")
  pred <- pred[match(key$note_id, pred$note_id), ]
  for (f in fields) {
    k <- trimws(key[[f]]); p <- trimws(pred[[f]])
    bad <- which(!((is.na(k) & is.na(p)) | (!is.na(k) & !is.na(p) & k == p)))
    for (i in bad) cat(sprintf("%-16s %s %-8s key: %-28s got: %s\n", basename(file),
                               key$note_id[i], f, ifelse(is.na(k[i]), "(empty)", k[i]),
                               ifelse(is.na(p[i]), "(empty)", p[i])))
  }
}
