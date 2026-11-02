# Score every file in results/<set>/ against the key for that set.
# Run from the testing folder:
#   Rscript R/03_score.R            # development set: results/dev/ against key/key.csv
#   Rscript R/03_score.R heldout    # held-out set: results/heldout/ against key/key_heldout.csv
#
# For each file it prints, per field, the cells that were correct, wrong
# (key and output both filled but different), missed (key filled, output
# empty) and invented (key empty, output filled). Then, per file: cells
# correct out of the total with an exact binomial 95 per cent interval; a
# bootstrap interval that resamples notes, because the cells of one note are
# not independent; and, against the baseline, the discordant cells and
# McNemar's test. Finally every disagreement, so that each error can be read.
set <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(set)) set <- "dev"
key_file <- if (set == "dev") "key/key.csv" else sprintf("key/key_%s.csv", set)
key    <- read.csv(key_file, colClasses = "character", na.strings = "")
fields <- c("station", "date", "species", "count", "habitat",
            "status", "effort", "count_qualifier", "id_qualifier")
dir    <- file.path("results", set)
files  <- list.files(dir, pattern = "\\.csv$", full.names = TRUE)
if (!length(files)) stop("no result files in ", dir)

# effort is free text: correct when key and output contain each other after
# lower-casing and removing punctuation. Every other field must match exactly.
norm_text <- function(x) {
  x <- tolower(trimws(x)); x <- gsub("[[:punct:]]", " ", x); gsub("\\s+", " ", trimws(x))
}
cells_ok <- function(field, k, p) {
  k <- trimws(k); p <- trimws(p)
  ok <- (is.na(k) & is.na(p))
  both <- !is.na(k) & !is.na(p)
  if (field == "effort") {
    for (i in which(both)) {
      nk <- norm_text(k[i]); np <- norm_text(p[i])
      ok[i] <- grepl(nk, np, fixed = TRUE) || grepl(np, nk, fixed = TRUE)
    }
  } else {
    ok[both] <- k[both] == p[both]
  }
  ok
}

read_pred <- function(file) {
  pred <- read.csv(file, colClasses = "character", na.strings = "")
  pred <- pred[match(key$note_id, pred$note_id), ]
  for (f in fields) if (is.null(pred[[f]])) pred[[f]] <- NA_character_
  pred
}

ok_matrix <- function(pred) {
  m <- sapply(fields, function(f) cells_ok(f, key[[f]], pred[[f]]))
  matrix(m, nrow = nrow(key), dimnames = list(key$note_id, fields))
}

field_table <- function(file, pred) {
  do.call(rbind, lapply(fields, function(f) {
    k <- trimws(key[[f]]); p <- trimws(pred[[f]])
    ok <- cells_ok(f, k, p)
    data.frame(file = basename(file), field = f,
               correct  = sum(ok),
               wrong    = sum(!ok & !is.na(k) & !is.na(p)),
               missed   = sum(!is.na(k) & is.na(p)),
               invented = sum(is.na(k) & !is.na(p)))
  }))
}

preds <- lapply(files, read_pred); names(preds) <- basename(files)
oks   <- lapply(preds, ok_matrix)

cat("Set:", set, "|", nrow(key), "notes x", length(fields), "fields =",
    nrow(key) * length(fields), "cells\n\n")
scores <- do.call(rbind, mapply(field_table, files, preds, SIMPLIFY = FALSE))
print(scores, row.names = FALSE)

# Summary per file: binomial interval on cells; bootstrap over notes; McNemar
# against the baseline on the same cells.
set.seed(1)
boot_ci <- function(ok, B = 2000) {
  per_note <- rowMeans(ok)
  means <- replicate(B, mean(per_note[sample(nrow(ok), replace = TRUE)]))
  quantile(means, c(0.025, 0.975))
}
base <- oks[["baseline.csv"]]
cat("\nPer file. 'binomial' treats cells as independent; 'bootstrap' resamples",
    "notes,\nwhich is the unit of replication here. McNemar compares each file",
    "with the\nbaseline on the same cells: b = baseline right and file wrong,",
    "c = the reverse.\n\n")
summary <- do.call(rbind, lapply(names(oks), function(nm) {
  ok <- oks[[nm]]; n <- length(ok); x <- sum(ok)
  bt <- binom.test(x, n)$conf.int; bs <- boot_ci(ok)
  row <- data.frame(file = nm, correct = x, total = n,
                    accuracy = round(x / n, 3),
                    binomial_low = round(bt[1], 3), binomial_high = round(bt[2], 3),
                    bootstrap_low = round(bs[1], 3), bootstrap_high = round(bs[2], 3),
                    b = NA, c = NA, mcnemar_p = NA, exact_p = NA)
  if (!is.null(base) && nm != "baseline.csv") {
    b <- sum(base & !ok); cc <- sum(!base & ok)
    row$b <- b; row$c <- cc
    if (b + cc > 0) {
      tab <- matrix(c(sum(base & ok), b, cc, sum(!base & !ok)), nrow = 2)
      row$mcnemar_p <- round(mcnemar.test(tab)$p.value, 3)
      row$exact_p   <- round(binom.test(b, b + cc)$p.value, 3)
    }
  }
  row
}))
print(summary, row.names = FALSE)

cat("\nDisagreements:\n")
for (nm in names(preds)) {
  pred <- preds[[nm]]
  for (f in fields) {
    k <- trimws(key[[f]]); p <- trimws(pred[[f]])
    bad <- which(!cells_ok(f, k, p))
    for (i in bad) cat(sprintf("%-16s %s %-16s key: %-28s got: %s\n", nm,
                               key$note_id[i], f, ifelse(is.na(k[i]), "(empty)", k[i]),
                               ifelse(is.na(p[i]), "(empty)", p[i])))
  }
}
