# Extract the same fields with a language model, through ellmer and Ollama.
# Run from the testing folder: Rscript R/02_extract.R run1
# Change `model` to any model you have pulled with Ollama.
library(ellmer)
model <- "qwen3:8b"
run   <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(run)) run <- "run1"

notes <- read.csv("data/notes.csv")
rules <- paste(readLines("RULES.md"), collapse = "\n")

type_note <- type_object(
  station = type_string("Station code S1 to S5, as written",
                        required = FALSE),
  date    = type_string("Sampling date as YYYY-MM-DD", required = FALSE),
  species = type_string("Scientific name exactly as written",
                        required = FALSE),
  count   = type_integer("Exact number of individuals", required = FALSE),
  habitat = type_enum(c("litter", "soil", "moss", "bark", "compost", "cave"),
                      required = FALSE)
)

chat <- chat_ollama(
  model = model,
  system_prompt = paste("Extract one record from a field note.", rules, sep = "\n\n")
)
out <- parallel_chat_structured(chat, as.list(notes$text), type = type_note)
out <- cbind(note_id = notes$note_id, out)

dir.create("results", showWarnings = FALSE)
file <- sprintf("results/llm_%s.csv", run)
write.csv(out, file, row.names = FALSE, na = "")
cat("model", model, "| read", nrow(notes), "notes; wrote", nrow(out), "rows to", file, "\n")
