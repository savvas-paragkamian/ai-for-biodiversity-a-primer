# Read data
occurrences <- read.csv("data/raw/occurrences.csv", stringsAsFactors = FALSE)
checklist <- read.csv("data/raw/checklist.csv", stringsAsFactors = FALSE)

# Clean names for matching
matched_names <- trimws(tolower(checklist$scientific_name))
actual_names <- trimws(occurrences$scientific_name)

# Problems identification
problems <- list()

# 1. Exact duplicate rows
# We check if any row is identical to another
dupes <- occurrences[!duplicated(occurrences), ]
if (nrow(occurrences) != nrow(dupes)) {
  problems[[length(problems) + 1]] <- "Duplicate rows found in data/raw/occurrences.csv"
}

# 2. Record IDs reused for different records
id_records <- aggregate(scientific_name ~ record_id, data = occurrences, FUN = function(x) length(unique(x)))
reused_ids <- id_records[id_records$scientific_name != 1, ]
if (nrow(reused_ids) > 0) {
  problems[[length(problems) + 1]] <- paste("Record IDs reused for different records:", paste(reused_ids$record_id, collapse = ", "))
}

# 3. Names not in checklist after trimming and fixing capitalization
missing_indices <- !actual_names %in% matched_names
if (any(missing_indices)) {
  problems[[length(problems) + 1]] <- paste("Names not in checklist:", paste(unique(actual_names[missing_indices]), collapse = ", "))
}

# 4. Dates not in YYYY-MM-DD or impossible
dates <- occurrences$date
valid_format <- grepl("^\\d{4}-\\d{2}-\\d{2}$", dates)
if (any(!valid_format)) {
  problems[[length(problems) + 1]] <- paste("Invalid date format:", paste(unique(dates[!valid_format]), collapse = ", "))
}

parsed_dates <- as.Date(as.character(dates[valid_format]), format="%Y-%m-%d")
if (any(is.na(parsed_dates))) {
  problems[[length(problems) + 1]] <- paste("Impossible dates:", paste(unique(dates[valid_format][is.na(parsed_dates)]), collapse = ", "))
}

# 5. Missing or non-numeric counts
counts_numeric <- suppressWarnings(as.numeric(occurrences$count))
if (any(is.na(counts_numeric))) {
    problems[[length(problems) + 1]] <- paste("Missing or non-numeric counts:", paste(unique(occurrences$count[is.na(counts_numeric)]), collapse = ", "))
}

# 6. Coordinates outside 34.8-35.7 N and 23.4-26.4 E
lats <- suppressWarnings(as.numeric(occurrences$latitude))
lons <- suppressWarnings(as.numeric(occurrences$longitude))
invalid_lats <- names(lats)[is.na(lats) | lats < 34.8 | lats > 35.7]
invalid_lons <- names(lons)[is.na(lons) | lons < 23.4 | lons > 26.4]
if (length(invalid_lats) > 0 || length(invalid_lons) > 0) {
  problems[[length(problems) + 1]] <- paste("Invalid latitudes:", paste(unique(invalid_lats), collapse = ", "), "Invalid longitudes:", paste(unique(invalid_lons), collapse = ", "))
}

# Print Report
if (length(problems) == 0) {
  cat("No problems found.\n")
} else {
  for (p in problems) {
    cat(p, "\n")
  }
}
