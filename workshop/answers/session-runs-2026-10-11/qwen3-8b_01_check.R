library(data.table)

# Read data
occurrences <- fread('data/raw/occurrences.csv', na.strings = '', header = TRUE)
checklist <- fread('data/raw/checklist.csv', na.strings = '', header = TRUE)

# Check exact duplicates
exact_duplicates <- sum(duplicated(occurrences))

# Check reused record_ids
reused_record_ids <- sum(duplicated(occurrences$record_id))

# Check names not in checklist
checklist_names <- tolower(trimws(checklist$scientific_name))
occurrence_names <- tolower(trimws(occurrences$name))
missing_names <- setdiff(occurrence_names, checklist_names)

# Check dates
valid_dates <- sapply(occurrences$date, function(x) {
  if (grepl('^\d{4}-\d{2}-\d{2}$', x)) {
    tryCatch(
      as.POSIXlt(x),
      error = function(e) FALSE
    )
  } else {
    FALSE
  }
})
invalid_dates <- sum(!valid_dates)

# Check counts
invalid_counts <- sum(!is.numeric(occurrences$count) | is.na(occurrences$count))

# Check coordinates
valid_coords <- sapply(occurrences$coordinates, function(x) {
  if (grepl('^\d+\.?\d*$', x)) {
    coords <- strsplit(x, ',')[[1]]
    if (length(coords) == 2) {
      lat <- as.numeric(coords[1])
      lon <- as.numeric(coords[2])
      return(
        lat >= 34.8 & lat <= 35.7 &
        lon >= 23.4 & lon <= 26.4
      )
    }
  }
  FALSE
})
invalid_coords <- sum(!valid_coords)

# Print report
cat('Exact duplicates:', exact_duplicates, '\n')
(cat('Reused record IDs:', reused_record_ids, '\n')
cat('Missing names:', length(missing_names), '\n')
cat('Invalid dates:', invalid_dates, '\n')
cat('Invalid counts:', invalid_counts, '\n')
cat('Invalid coordinates:', invalid_coords, '\n')