# How many of the papers the author knows should have been found were found.
# tests/gold.csv: doi (or arxiv:ID), title, topic, first_pub_date, how_learned.
# Only papers first published on or after the first recorded week are scored;
# add first_pub_date when you learn of a paper, and add the paper itself when
# you hear of it elsewhere: the gold set is the honest coverage test.
# The set is rolling: keep adding papers heard of elsewhere for at least two
# months, drop none, and read the score against the target below. Without a
# target the gold set is a list, not a test.
# Run from the repository root: Rscript tests/recall.R
source("R/00_common.R")

RECALL_TARGET <- 0.90   # share of scored papers the review must find; set by the author
RECALL_WINDOW_WEEKS <- 2 # within this many weeks of first publication

gold <- read_csv("tests/gold.csv")
seen <- read_csv("data/seen.csv", c("uid", "doi", "arxiv_id", "first_seen_week"))
if (is.null(gold) || nrow(gold) == 0) { say("tests/gold.csv is empty: add the papers you know should be found"); quit(status = 0) }
is_ax <- grepl("^arxiv:", gold$doi)
gold$doi[!is_ax] <- norm_doi(gold$doi[!is_ax])
found <- ifelse(is_ax, sub("^arxiv:", "", gold$doi) %in% seen$arxiv_id, gold$doi %in% seen$doi)
# The recorded range: from the first real week to the end of the last one. The
# fixture week 2026-W00 exists in no calendar and is left out of the range.
weeks <- seen$first_seen_week[!is.na(seen$first_seen_week) & !grepl("-W00$", seen$first_seen_week)]
start <- if (length(weeks)) week_monday(min(weeks)) else Sys.Date()
end <- if (length(weeks)) week_monday(max(weeks)) + 6 else Sys.Date()
d <- as.Date(gold$first_pub_date, optional = TRUE)
# a paper is scored once its window has passed inside the recorded range: the
# review cannot have found a paper that appeared after its last recorded week
scored <- !is.na(d) & d >= start & (d + 7 * RECALL_WINDOW_WEEKS) <= end
waiting <- !is.na(d) & d >= start & !scored
say("gold set: ", nrow(gold), " papers; recorded range ", format(start), " to ", format(end), "; ",
    sum(scored), " first published in the range with their ", RECALL_WINDOW_WEEKS, "-week window passed; ",
    sum(found & scored), " of those found; ", sum(waiting), " published too recently to score yet; ",
    sum(found & !scored), " found but not scored (older, undated or too recent); ",
    sum(is.na(d)), " without a first_pub_date (not scored)")
if (any(scored & !found)) { say("missed:"); say(paste0("- ", gold$title[scored & !found], " (", gold$doi[scored & !found], ")", collapse = "\n")) }
if (sum(scored)) {
  rate <- sum(found & scored) / sum(scored)
  say(sprintf("recall %.2f against a target of %.2f within %d weeks of publication: %s",
              rate, RECALL_TARGET, RECALL_WINDOW_WEEKS, if (rate >= RECALL_TARGET) "met" else "NOT MET"))
  if (rate < RECALL_TARGET) quit(status = 1)
}
