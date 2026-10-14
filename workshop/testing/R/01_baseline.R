# Baseline without a language model: patterns and keywords only.
# Run from the testing folder: Rscript R/01_baseline.R
notes     <- read.csv("data/notes.csv")
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

out <- data.frame(note_id = notes$note_id)
out$station <- vapply(notes$text, first_match, character(1), pattern = "\\bS[1-5]\\b", USE.NAMES = FALSE)
out$date    <- vapply(notes$text, find_date, character(1), USE.NAMES = FALSE)
out$species <- vapply(notes$text, find_species, character(1), USE.NAMES = FALSE)
out$count   <- mapply(find_count, notes$text, out$species, USE.NAMES = FALSE)
out$habitat <- vapply(notes$text, find_habitat, character(1), USE.NAMES = FALSE)

dir.create("results", showWarnings = FALSE)
write.csv(out, "results/baseline.csv", row.names = FALSE, na = "")
cat("read", nrow(notes), "notes; wrote", nrow(out), "rows to results/baseline.csv\n")
