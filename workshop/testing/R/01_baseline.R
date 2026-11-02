# Baseline without a language model: patterns and keywords only.
# Run from the testing folder:
#   Rscript R/01_baseline.R            # development set, data/notes.csv (N01 to N10)
#   Rscript R/01_baseline.R heldout    # held-out set, data/notes_heldout.csv (N11 to N25)
# The patterns were written against the development set only and are applied
# unchanged to the held-out set. Do not tune them on the held-out notes.

# Month names are parsed in the C locale, whatever the machine's language.
# Without this line, "12 May 2025" fails to parse under a Greek or German
# locale and the baseline loses every long-form date.
invisible(Sys.setlocale("LC_TIME", "C"))

set <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(set)) set <- "dev"
notes_file <- if (set == "dev") "data/notes.csv" else sprintf("data/notes_%s.csv", set)

notes     <- read.csv(notes_file)
checklist <- read.csv("data/checklist.csv")$scientific_name
habitats  <- c("litter", "soil", "moss", "bark", "compost", "cave")

first_match <- function(pattern, x) {
  m <- regmatches(x, regexpr(pattern, x, perl = TRUE))
  if (length(m)) m else NA_character_
}

find_date <- function(x) {
  iso <- first_match("\\d{4}-\\d{2}-\\d{2}", x)
  if (!is.na(iso)) return(iso)
  dmy <- first_match("\\d{1,2}/\\d{1,2}/\\d{4}", x)
  if (!is.na(dmy)) return(format(as.Date(dmy, "%d/%m/%Y")))
  long <- first_match("\\d{1,2} [A-Z][a-z]+ \\d{4}", x)
  if (!is.na(long)) return(format(as.Date(long, "%d %B %Y")))
  NA_character_
}

find_species <- function(x) {
  hit <- checklist[vapply(checklist, grepl, logical(1), x = x, ignore.case = TRUE)]
  if (length(hit)) hit[1] else NA_character_
}

# The number nearest the species name, within three words either side.
find_count <- function(x, species) {
  if (is.na(species)) return(NA_integer_)
  words <- strsplit(x, "\\s+")[[1]]
  start <- which(tolower(words) == tolower(strsplit(species, " ")[[1]][1]))[1]
  nums  <- grep("^x?\\d+[.,;:]?$", words)
  dist  <- ifelse(nums < start, start - nums, nums - (start + 1))
  near  <- dist >= 1 & dist <= 3
  if (!any(near)) return(NA_integer_)
  best  <- nums[near][which.min(dist[near])]
  as.integer(gsub("\\D", "", words[best]))
}

find_habitat <- function(x) {
  hit <- habitats[vapply(habitats, grepl, logical(1), x = x, ignore.case = TRUE)]
  if (length(hit)) hit[1] else NA_character_
}

# Fields added on 22 October 2026. Patterns from the development set only.
find_status <- function(x, species) {
  if (!is.na(species)) return("present")
  if (grepl("lost|too dry|no sample|nothing sorted|could not", x, ignore.case = TRUE)) return("not_sampled")
  if (grepl("none found|not found|nothing", x, ignore.case = TRUE)) return("absent")
  NA_character_
}

find_effort <- function(x) {
  first_match(paste0("(Berlese[^.;,]*\\d+ ?h|",
                     "(one|two|three|four|five|six|\\d+) (oaks|trees|rocks|boulders|logs|traps)|",
                     "[Dd]eep soil core, \\d+ to \\d+ cm|",
                     "\\d+ ?(h|min|minutes)\\b[^.;,]*)"), x)
}

find_count_qualifier <- function(x, count) {
  if (grepl("roughly|about|around|approximately|circa|dozen", x, ignore.case = TRUE)) return("approximate")
  if (grepl("first tray|counted in the first", x, ignore.case = TRUE)) return("partial")
  if (!is.na(count)) return("exact")
  NA_character_
}

find_id_qualifier <- function(x) {
  if (grepl("tentative|probably|possibly|cf\\.|uncertain", x, ignore.case = TRUE)) "tentative" else NA_character_
}

out <- data.frame(note_id = notes$note_id)
out$station <- vapply(notes$text, first_match, character(1), pattern = "\\bS[1-5]\\b", USE.NAMES = FALSE)
out$date    <- vapply(notes$text, find_date, character(1), USE.NAMES = FALSE)
out$species <- vapply(notes$text, find_species, character(1), USE.NAMES = FALSE)
out$count   <- mapply(find_count, notes$text, out$species, USE.NAMES = FALSE)
out$habitat <- vapply(notes$text, find_habitat, character(1), USE.NAMES = FALSE)
out$status  <- mapply(find_status, notes$text, out$species, USE.NAMES = FALSE)
out$effort  <- vapply(notes$text, find_effort, character(1), USE.NAMES = FALSE)
out$count_qualifier <- mapply(find_count_qualifier, notes$text, out$count, USE.NAMES = FALSE)
out$id_qualifier    <- vapply(notes$text, find_id_qualifier, character(1), USE.NAMES = FALSE)
# A rough number is not a count, and a note without a specimen has no count.
out$count[!is.na(out$count_qualifier) & out$count_qualifier == "approximate"] <- NA
out$count[is.na(out$status) | out$status != "present"] <- NA

dir.create(file.path("results", set), recursive = TRUE, showWarnings = FALSE)
file <- file.path("results", set, "baseline.csv")
write.csv(out, file, row.names = FALSE, na = "")
cat("set", set, "| read", nrow(notes), "notes; wrote", nrow(out), "rows to", file, "\n")
