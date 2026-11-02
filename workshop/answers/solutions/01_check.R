# Reference solution: report problems in data/raw/occurrences.csv without changing it.
# Run from the session folder: Rscript ../answers/solutions/01_check.R
occ  <- read.csv("data/raw/occurrences.csv", colClasses = "character", na.strings = "")
chk  <- read.csv("data/raw/checklist.csv", colClasses = "character")$scientific_name
norm <- function(x) { x <- gsub("\\s+", " ", trimws(x)); paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2))) }
iso  <- grepl("^\\d{4}-\\d{2}-\\d{2}$", occ$date)
lat  <- as.numeric(occ$latitude); lon <- as.numeric(occ$longitude)
cnt  <- suppressWarnings(as.integer(trimws(occ$count)))
ids  <- unique(occ$record_id[duplicated(occ$record_id)])
present <- occ$occurrence_status == "present"
cat("rows:", nrow(occ), "\n")
cat("exact duplicate rows:", sum(duplicated(occ)), "\n")
cat("record_ids reused with different content:",
    sum(sapply(ids, function(i) nrow(unique(occ[occ$record_id == i, ])) > 1)), "\n")
cat("names changed by trimming/capitalisation:", sum(norm(occ$scientific_name) != occ$scientific_name), "\n")
cat("names not in checklist after normalising:", sum(!norm(occ$scientific_name) %in% chk), "\n")
cat("dates not in YYYY-MM-DD:", sum(!iso), "; impossible ISO dates:", sum(iso & is.na(as.Date(occ$date, "%Y-%m-%d"))), "\n")
cat("non-detections (occurrence_status absent):", sum(occ$occurrence_status == "absent"),
    "; status values other than present/absent:", sum(!occ$occurrence_status %in% c("present", "absent")), "\n")
cat("missing counts among present records:", sum(present & is.na(occ$count)),
    "; non-numeric counts:", sum(!is.na(occ$count) & is.na(cnt)),
    "; counts on absent records:", sum(!present & !is.na(occ$count)), "\n")
cat("records without effort:", sum(is.na(occ$effort)), "\n")
cat("coordinates outside 34.8-35.7 N, 23.4-26.4 E:", sum(!(lat >= 34.8 & lat <= 35.7 & lon >= 23.4 & lon <= 26.4)), "\n")
cat("distinct habitat labels:", length(unique(occ$habitat)), "\n")
cat("notes containing instructions:", sum(grepl("NOTE FOR AI", occ$notes)), "\n")
