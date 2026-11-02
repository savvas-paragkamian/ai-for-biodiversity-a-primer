# Extract the same fields with a language model, through ellmer and Ollama.
# Run from the testing folder:
#   Rscript R/02_extract.R run1                # development set (N01 to N10), free sampling
#   Rscript R/02_extract.R run1 heldout        # held-out set (N11 to N25), free sampling
#   Rscript R/02_extract.R fixedA heldout 1    # same sampling with seed 1: repeatable
# Change `model` to any model you have pulled with Ollama. Every raw response,
# the model's reasoning included, is kept under results/<set>/raw/<run>/, and
# the settings and timings go to results/<set>/llm_<run>.json.
library(ellmer)
model <- "qwen3:8b"
args  <- commandArgs(trailingOnly = TRUE)
run   <- if (length(args) >= 1) args[1] else "run1"
set   <- if (length(args) >= 2) args[2] else "dev"
seed  <- if (length(args) >= 3) as.integer(args[3]) else NA_integer_

notes_file <- if (set == "dev") "data/notes.csv" else sprintf("data/notes_%s.csv", set)
notes <- read.csv(notes_file)
rules <- paste(readLines("RULES.md"), collapse = "\n")

# Sampling settings. The Qwen3 model card (huggingface.co/Qwen/Qwen3-8B,
# section "Best Practices") recommends temperature 0.6, top_p 0.95 and top_k 20
# for thinking mode and says not to use greedy decoding (temperature 0), which
# "can lead to performance degradation and endless repetitions". The same
# values are the model's own defaults in Ollama (`ollama show qwen3:8b`). The
# fixed runs keep these settings and add a seed, which makes the sampling
# repeatable without changing it.
sampling <- list(temperature = 0.6, top_p = 0.95, top_k = 20)
p <- params(temperature = sampling$temperature, top_p = sampling$top_p,
            top_k = sampling$top_k, seed = if (is.na(seed)) NULL else seed)

type_note <- type_object(
  station = type_string("Station code S1 to S5, as written",
                        required = FALSE),
  date    = type_string("Sampling date as YYYY-MM-DD", required = FALSE),
  species = type_string("Scientific name exactly as written",
                        required = FALSE),
  count   = type_integer("Exact number of individuals", required = FALSE),
  habitat = type_enum(c("litter", "soil", "moss", "bark", "compost", "cave"),
                      required = FALSE),
  status  = type_enum(c("present", "absent", "not_sampled"),
                      "present: a specimen was sorted, seen or counted; absent: searched for and none found; not_sampled: no sample taken or sample lost",
                      required = FALSE),
  effort  = type_string("Sampling effort or method as written, for example 'Berlese sample ran 48 h' or 'three oaks'; omit when none is stated",
                        required = FALSE),
  count_qualifier = type_enum(c("exact", "partial", "approximate"),
                              "exact: the count covers the whole sample; partial: part of it; approximate: a rough number, in which case count is empty",
                              required = FALSE),
  id_qualifier = type_string("The word tentative when the note doubts the identification ('identification tentative', 'probably', 'cf.'); omit otherwise",
                             required = FALSE)
)
fields <- c("station", "date", "species", "count", "habitat",
            "status", "effort", "count_qualifier", "id_qualifier")

chat <- chat_ollama(
  model = model,
  system_prompt = paste("Extract one record from a field note.", rules, sep = "\n\n"),
  params = p
)

raw_dir <- file.path("results", set, "raw", run)
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
rows <- vector("list", nrow(notes)); secs <- numeric(nrow(notes))
t_start <- Sys.time()
for (i in seq_len(nrow(notes))) {
  t0  <- Sys.time()
  c1  <- chat$clone()                      # a fresh conversation for each note
  rec <- c1$chat_structured(notes$text[i], type = type_note)
  secs[i] <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  turn <- c1$last_turn()                   # the raw API response, reasoning included
  writeLines(jsonlite::toJSON(turn@json, auto_unbox = TRUE, pretty = TRUE),
             file.path(raw_dir, paste0(notes$note_id[i], ".json")))
  for (f in fields) if (is.null(rec[[f]]) || length(rec[[f]]) == 0) rec[[f]] <- NA
  rows[[i]] <- data.frame(note_id = notes$note_id[i],
                          lapply(rec[fields], function(v) as.character(v)),
                          stringsAsFactors = FALSE)
}
out <- do.call(rbind, rows)

file <- file.path("results", set, sprintf("llm_%s.csv", run))
write.csv(out, file, row.names = FALSE, na = "")

# Record what was run, so that the result can be compared with another machine.
show_model <- tryCatch(system2("ollama", c("show", model), stdout = TRUE), error = function(e) character())
ps         <- tryCatch(system2("ollama", "ps", stdout = TRUE), error = function(e) character())
grab <- function(lines, key) { l <- grep(key, lines, value = TRUE); if (length(l)) trimws(sub(paste0(".*", key, "\\s*"), "", l[1])) else NA }
ps_line <- grep(model, ps, value = TRUE, fixed = TRUE)
context_loaded <- if (length(ps_line)) strsplit(trimws(ps_line[1]), "\\s{2,}")[[1]][5] else NA
meta <- list(
  run = run, set = set, notes_file = notes_file, notes = nrow(notes),
  model = model,
  quantization = grab(show_model, "quantization"),
  model_context_length = grab(show_model, "context length"),
  context_loaded = context_loaded,
  thinking = "model default (on)",
  sampling = sampling, seed = seed,
  ollama_version = tryCatch(system2("ollama", "--version", stdout = TRUE), error = function(e) NA),
  ellmer_version = as.character(packageVersion("ellmer")),
  r_version = R.version.string, platform = R.version$platform,
  started = format(t_start, "%Y-%m-%d %H:%M:%S %Z"),
  seconds_per_note = round(secs, 1), seconds_total = round(sum(secs), 1)
)
writeLines(jsonlite::toJSON(meta, auto_unbox = TRUE, pretty = TRUE, na = "null"),
           file.path("results", set, sprintf("llm_%s.json", run)))
cat("model", model, "| set", set, "| run", run,
    if (!is.na(seed)) sprintf("| seed %d", seed) else "| no seed",
    "| read", nrow(notes), "notes; wrote", nrow(out), "rows to", file,
    sprintf("| %.0f s", sum(secs)), "\n")
