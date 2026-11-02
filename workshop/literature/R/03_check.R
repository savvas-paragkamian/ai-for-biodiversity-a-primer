# Resolve every DOI on Crossref (then DataCite) and every arXiv identifier on the
# arXiv API, and compare the returned title, first author's surname and year with
# ours. Nothing unverified reaches a .bib.
# Run from the repository root: Rscript R/03_check.R [YYYY-WW] [--offline]
#   --offline   read data/raw/<week>/crossref.json and arxiv-ids.xml instead of the network
#   --self-test plant four bad cases (a DOI that does not exist, a real DOI with a
#               wrong title, a real DOI with a wrong first author, an arXiv identifier
#               that does not exist) and two good ones; passes only if the bad ones
#               fail and the good ones pass (needs the network)
# The title check is the one scripts/verify_bib.py makes in the book: similarity is
# 1 - edit distance / length of the longer normalised title, threshold 0.85. The
# author check compares surnames in lowercase ASCII and accepts one that contains
# the other (particles, compound surnames). A year more than one apart fails; one
# apart (online and print) is noted.
source("R/00_common.R")

MIN_SIMILARITY <- 0.85
cfg <- tryCatch(load_config(), error = function(e) list(contact = "unknown"))

similarity <- function(a, b) {
  a <- norm_title(a); b <- norm_title(b)
  if (is.na(a) || is.na(b) || a == "" || b == "") return(0)
  1 - as.numeric(utils::adist(a, b)) / max(nchar(a), nchar(b))
}

# Do two titles name the same work? Similarity at or above the threshold, or one
# title is the other without its subtitle (the shorter is a prefix of at least
# thirty characters). Returns ok, score and a short explanation.
title_match <- function(ours, theirs) {
  s <- similarity(ours, theirs)
  a <- norm_title(ours); b <- norm_title(theirs)
  prefix <- FALSE
  if (!is.na(a) && !is.na(b) && nchar(a) >= 30 && nchar(b) >= 30) {
    short <- if (nchar(a) < nchar(b)) a else b; long <- if (nchar(a) < nchar(b)) b else a
    prefix <- startsWith(long, short)
  }
  list(ok = s >= MIN_SIMILARITY || prefix, score = s,
       how = if (s >= MIN_SIMILARITY) sprintf("title matches (%.2f)", s)
             else if (prefix) sprintf("title matches up to the subtitle (%.2f)", s)
             else sprintf("title differs (%.2f)", s))
}

# The first author's surname in a Crossref record: the author whose sequence is
# "first", else the first listed. "" when the record names no author (common for
# reports, data papers and some conference items).
crossref_first_author <- function(m) {
  a <- m$author
  if (is.null(a) || length(a) == 0) return("")
  seqs <- vapply(a, function(x) x$sequence %||% "", character(1))
  x <- if (any(seqs == "first")) a[[which(seqs == "first")[1]]] else a[[1]]
  f <- x$family %||% x$name %||% ""
  gsub("\\s+", " ", trimws(f))
}
# The earliest year a Crossref record gives (online, print or issued).
crossref_year <- function(m) {
  ys <- integer()
  for (k in c("published-online", "published-print", "issued", "created")) {
    p <- m[[k]]$`date-parts`
    if (length(p) && length(p[[1]]) && !is.null(p[[1]][[1]])) ys <- c(ys, suppressWarnings(as.integer(p[[1]][[1]])))
  }
  ys <- ys[!is.na(ys)]
  if (length(ys)) min(ys) else NA_integer_
}

# Crossref: returns list(status = "ok"|"unresolved"|"network", title, first_author, year, registrar, record)
crossref <- function(doi) {
  req <- client(paste0("https://api.crossref.org/works/", utils::URLencode(doi, reserved = TRUE)), cfg)
  r <- perform(req)
  if (is.na(r$status)) return(list(status = "network", title = NA_character_, error = r$error))
  if (r$status %in% c(400, 404)) return(list(status = "unresolved", title = NA_character_))
  if (r$status != 200) return(list(status = "network", title = NA_character_, error = paste("HTTP", r$status)))
  m <- jsonlite::fromJSON(r$text, simplifyVector = FALSE)$message
  t <- m$title
  if (length(t) == 0 && length(m$project)) t <- unlist(lapply(m$project, function(p) lapply(p$`project-title`, function(x) x$title)))
  list(status = "ok", title = if (length(t)) gsub("\\s+", " ", t[[1]]) else "",
       first_author = crossref_first_author(m), year = crossref_year(m), registrar = "Crossref", record = m)
}

# DataCite, for the DOIs Crossref does not know: Zenodo, Figshare, ResearchGate
# and most data repositories register there.
datacite <- function(doi) {
  req <- client(paste0("https://api.datacite.org/dois/", utils::URLencode(doi, reserved = TRUE)), cfg)
  r <- perform(req)
  if (is.na(r$status)) return(list(status = "network", title = NA_character_, error = r$error))
  if (r$status %in% c(400, 404)) return(list(status = "unresolved", title = NA_character_))
  if (r$status != 200) return(list(status = "network", title = NA_character_, error = paste("HTTP", r$status)))
  a <- jsonlite::fromJSON(r$text, simplifyVector = FALSE)$data$attributes
  t <- if (length(a$titles)) a$titles[[1]]$title else ""
  cr <- a$creators
  fa <- if (length(cr)) (cr[[1]]$familyName %||% sub(",.*$", "", cr[[1]]$name %||% "")) else ""
  list(status = "ok", title = gsub("\\s+", " ", t %||% ""), first_author = trimws(fa %||% ""),
       year = suppressWarnings(as.integer(a$publicationYear %||% NA)), registrar = "DataCite", record = a)
}

# Crossref first, DataCite when Crossref has never heard of the DOI.
resolve_doi <- function(doi) {
  c <- crossref(doi)
  if (c$status != "unresolved") return(c)
  d <- datacite(doi)
  if (d$status == "ok") d else c
}

# arXiv: ids in batches of 100 (a longer id_list is refused with a 400); returns a
# named list id -> list(title, first_author, year). With save_to, batch k is saved
# as <save_to without .xml>-<k>.xml; the first batch keeps the plain name.
ARXIV_BATCH <- 100
arxiv_titles <- function(ids, save_to = NULL) {
  if (length(ids) == 0) return(list())
  out <- list()
  batches <- split(ids, ceiling(seq_along(ids) / ARXIV_BATCH))
  for (k in seq_along(batches)) {
    req <- client("https://export.arxiv.org/api/query", cfg) |>
      httr2::req_url_query(id_list = paste(batches[[k]], collapse = ","), max_results = ARXIV_BATCH)
    r <- perform(req)
    if (is.na(r$status) || r$status != 200) stop("arXiv API unreachable: ", r$status %||% r$error)
    if (!is.null(save_to)) writeLines(r$text, if (k == 1) save_to else sub("\\.xml$", sprintf("-%d.xml", k), save_to), useBytes = TRUE)
    out <- c(out, parse_arxiv_titles(r$text))
    if (k < length(batches)) Sys.sleep(cfg$delay_seconds$arxiv %||% 3)
  }
  out
}

# the cached arXiv answers of a week: arxiv-ids.xml and any arxiv-ids-<k>.xml
cached_arxiv_titles <- function(ax_path) {
  if (is.null(ax_path)) return(list())
  files <- list.files(dirname(ax_path), pattern = "^arxiv-ids(-[0-9]+)?\\.xml$", full.names = TRUE)
  out <- list()
  for (f in files) out <- c(out, parse_arxiv_titles(paste(readLines(f, warn = FALSE), collapse = "\n")))
  out
}

parse_arxiv_titles <- function(text) {
  x <- xml2::read_xml(text)
  ns <- c(a = "http://www.w3.org/2005/Atom")
  entries <- xml2::xml_find_all(x, ".//a:entry", ns)
  out <- list()
  for (e in entries) {
    id <- xml2::xml_text(xml2::xml_find_first(e, "a:id", ns))
    t <- xml2::xml_find_first(e, "a:title", ns)
    if (!grepl("/abs/", id) || inherits(t, "xml_missing")) next
    # arXiv writes names given name first: the surname is the last word
    names <- xml2::xml_text(xml2::xml_find_all(e, "a:author/a:name", ns))
    fa <- if (length(names)) { p <- strsplit(trimws(names[1]), "\\s+")[[1]]; p[length(p)] } else ""
    pub <- xml2::xml_find_first(e, "a:published", ns)
    out[[strip_version(sub("^.*/abs/", "", id))]] <- list(
      title = gsub("\\s+", " ", trimws(xml2::xml_text(t))), first_author = fa,
      year = if (inherits(pub, "xml_missing")) NA_integer_ else suppressWarnings(as.integer(substr(xml2::xml_text(pub), 1, 4))))
  }
  out
}

ours_author <- function(d, i) {
  a <- if ("first_author" %in% names(d)) d$first_author[i] else NA_character_
  if (is.null(a) || is.na(a) || a %in% c("", "anon")) NA_character_ else a
}
ours_year <- function(d, i) if ("year" %in% names(d)) suppressWarnings(as.integer(d$year[i])) else NA_integer_

# The verdict on one item. The title must match; the first author's surname must
# not contradict the registrar's; the year must not differ by more than one. A
# registrar record that names no author, an author in a script that cannot be
# compared, or a cached answer saved before authors were kept, is said in the
# reason and does not fail the item: the reason is part of the record.
verdict <- function(reg, m, c, our_author, our_year) {
  how <- paste(reg, m$how); ok <- m$ok
  if (!m$ok) how <- paste0(how, ": ", c$title)
  theirs <- c$first_author
  if (is.null(theirs)) how <- paste0(how, "; author not in the cached answer")
  else if (is.na(theirs) || theirs == "") how <- paste0(how, "; author not in the registrar's record")
  else if (is.na(our_author)) how <- paste0(how, "; no author in our record")
  else {
    s <- same_surname(our_author, theirs)
    if (is.na(s)) how <- paste0(how, sprintf("; first author not comparable (ours %s, registrar %s)", our_author, theirs))
    else if (s) how <- paste0(how, sprintf("; first author matches (%s)", theirs))
    else { ok <- FALSE; how <- paste0(how, sprintf("; first author differs: ours %s, registrar %s", our_author, theirs)) }
  }
  their_year <- suppressWarnings(as.integer(c$year %||% NA))
  if (!is.na(their_year) && !is.na(our_year)) {
    dy <- abs(their_year - our_year)
    if (dy > 1) { ok <- FALSE; how <- paste0(how, sprintf("; year differs: ours %d, registrar %d", our_year, their_year)) }
    else if (dy == 1) how <- paste0(how, sprintf("; year %d at the registrar", their_year))
  }
  list(ok = ok, how = how)
}

# Check a table with columns doi, arxiv_id, title. Returns it with verified, verify_reason, found_title.
# known: identifiers verified in an earlier week (data/seen.csv); they are not resolved again.
check_table <- function(d, offline = FALSE, cache_dir = NULL, verbose = TRUE, known = character()) {
  d$verified <- FALSE; d$verify_reason <- NA_character_; d$found_title <- NA_character_
  if (length(known)) {
    k <- (!is.na(d$doi) & d$doi %in% known) | (!is.na(d$arxiv_id) & d$arxiv_id %in% known)
    d$verified[k] <- TRUE; d$verify_reason[k] <- "verified when first seen (data/seen.csv)"
    d_known <- d[k, , drop = FALSE]
    d <- d[!k, , drop = FALSE]
    if (verbose && sum(k)) say(sum(k), " identifiers already verified in an earlier week, not resolved again")
  } else d_known <- d[0, , drop = FALSE]
  cross_path <- if (!is.null(cache_dir)) file.path(cache_dir, "crossref.json") else NULL
  ax_path <- if (!is.null(cache_dir)) file.path(cache_dir, "arxiv-ids.xml") else NULL
  cache <- list()
  if (offline) {
    if (!is.null(cross_path) && file.exists(cross_path)) cache <- jsonlite::fromJSON(cross_path, simplifyVector = FALSE)
    ax <- cached_arxiv_titles(ax_path)
  } else {
    ids <- unique(d$arxiv_id[!is.na(d$arxiv_id) & is.na(d$doi)])
    ax <- if (length(ids)) arxiv_titles(ids, ax_path) else list()
  }
  for (i in seq_len(nrow(d))) {
    doi <- d$doi[i]; aid <- d$arxiv_id[i]
    if (!is.na(doi)) {
      if (offline) {
        c <- cache[[doi]]
        if (is.null(c)) { d$verify_reason[i] <- "no cached Crossref answer"; next }
      } else {
        c <- resolve_doi(doi); c$record <- NULL; cache[[doi]] <- c; Sys.sleep(0.3)
      }
      reg <- c$registrar %||% "Crossref"
      if (c$status == "network") { d$verify_reason[i] <- paste0(reg, " unreachable: ", c$error %||% ""); next }
      if (c$status == "unresolved") { d$verify_reason[i] <- "DOI does not resolve on Crossref or DataCite"; next }
      m <- title_match(d$title[i], c$title); d$found_title[i] <- c$title
      v <- verdict(reg, m, c, ours_author(d, i), ours_year(d, i))
      d$verified[i] <- v$ok; d$verify_reason[i] <- v$how
    } else if (!is.na(aid)) {
      e <- ax[[aid]]
      if (is.null(e)) { d$verify_reason[i] <- "arXiv identifier not found"; next }
      m <- title_match(d$title[i], e$title); d$found_title[i] <- e$title
      v <- verdict("arXiv", m, e, ours_author(d, i), ours_year(d, i))
      d$verified[i] <- v$ok; d$verify_reason[i] <- v$how
    } else {
      d$verify_reason[i] <- "no DOI and no arXiv identifier"
    }
    if (verbose) say(sprintf("%-8s %s  %s", if (d$verified[i]) "ok" else "FAIL", doi %||% aid %||% "-", d$verify_reason[i]))
  }
  if (!offline && !is.null(cross_path) && length(cache)) jsonlite::write_json(cache, cross_path, auto_unbox = TRUE, pretty = TRUE)
  rbind(d, d_known)
}

self_test <- function() {
  d <- data.frame(
    key = c("good_doi", "fake_doi", "wrong_title", "wrong_author", "good_arxiv", "fake_arxiv"),
    doi = c("10.1038/s41586-025-10072-4", "10.1038/s41586-099-99999-9", "10.1038/s41586-025-10072-4", "10.1145/3644815.3644945", NA, NA),
    arxiv_id = c(NA, NA, NA, NA, "2603.17063", "2699.99999"),
    title = c(NA, "A paper that does not exist", "Deliberately wrong title about something else entirely", NA, NA, "Nothing"),
    first_author = c(NA, "Nobody", NA, "Kurniawan", NA, "Nobody"),
    year = c(NA, "2026", NA, "2024", NA, "2026"),
    stringsAsFactors = FALSE)
  # the good cases take their title, first author and year from the resolver itself, so they must
  # pass whatever the paper is; wrong_title keeps the right author, wrong_author the right title:
  # the real first author of 10.1145/3644815.3644945 is Barnett, which the book itself once cited
  # as Kurniawan et al., an error a title-only check cannot see
  c1 <- resolve_doi(d$doi[1]); d$title[1] <- c1$title; d$first_author[c(1, 3)] <- c1$first_author; d$year[c(1, 3)] <- c1$year
  c4 <- resolve_doi(d$doi[4]); d$title[4] <- c4$title
  ax <- arxiv_titles(d$arxiv_id[5]); d$title[5] <- ax[[d$arxiv_id[5]]]$title; d$first_author[5] <- ax[[d$arxiv_id[5]]]$first_author
  r <- check_table(d, verbose = TRUE)
  bad_fail <- all(!r$verified[r$key %in% c("fake_doi", "wrong_title", "wrong_author", "fake_arxiv")])
  good_pass <- all(r$verified[r$key %in% c("good_doi", "good_arxiv")])
  if (bad_fail && good_pass) { say("SELF-TEST PASSED: the four planted failures were caught (a DOI that does not exist, a wrong title, a wrong first author, an arXiv identifier that does not exist) and the two good identifiers passed"); quit(status = 0) }
  say("SELF-TEST FAILED"); print(r[, c("key", "verified", "verify_reason")]); quit(status = 1)
}

if (!interactive() && sys.nframe() == 0) {
  args <- commandArgs(trailingOnly = TRUE)
  if (has_flag("--self-test", args)) self_test()
  week <- week_arg(args)
  offline <- has_flag("--offline", args)
  d <- read_csv(file.path("data", "normalised", paste0(week, ".csv")))
  if (is.null(d)) stop("run R/02_normalise.R first: data/normalised/", week, ".csv is missing")
  seen <- read_csv("data/seen.csv")
  known <- if (is.null(seen)) character() else unique(c(seen$doi[!is.na(seen$doi) & seen$first_seen_week != week],
                                                       seen$arxiv_id[!is.na(seen$arxiv_id) & seen$first_seen_week != week]))
  r <- check_table(d, offline = offline, cache_dir = raw_dir(week), known = known)
  write_csv(r, file.path("data", "normalised", paste0(week, "-checked.csv")))
  say(sum(!is.na(r$doi)), " DOIs and ", sum(is.na(r$doi) & !is.na(r$arxiv_id)), " arXiv identifiers checked",
      if (offline) " from the cached answers" else "", "; ", sum(r$verified), " verified, ", sum(!r$verified), " not")
  say("wrote data/normalised/", week, "-checked.csv")
}
