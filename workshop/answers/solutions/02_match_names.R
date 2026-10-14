# Reference solution: flag names against the checklist; keep every row but exact duplicates.
# Run from the session folder: Rscript ../answers/solutions/02_match_names.R
occ <- read.csv("data/raw/occurrences.csv", colClasses = "character", na.strings = "")
chk <- read.csv("data/raw/checklist.csv", colClasses = "character")$scientific_name
cat("read", nrow(occ), "rows\n")
dup <- duplicated(occ)
cat("removed", sum(dup), "exact duplicate row\n")
occ <- occ[!dup, ]
norm <- function(x) { x <- gsub("\\s+", " ", trimws(x)); paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2))) }
occ$name_status <- ifelse(occ$scientific_name %in% chk, "MATCH",
                   ifelse(norm(occ$scientific_name) %in% chk, "NORMALISED", "NO_MATCH"))
dir.create("data/processed", showWarnings = FALSE)
write.csv(occ, "data/processed/occurrences_checked.csv", row.names = FALSE, na = "")
print(table(occ$name_status))
cat("wrote", nrow(occ), "rows and", ncol(occ), "columns\n")
