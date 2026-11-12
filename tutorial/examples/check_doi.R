# A reference is accepted only if its DOI resolves and the titles agree.
library(httr2)
resolves <- function(doi, title) {
  r <- request(paste0("https://api.crossref.org/works/", doi)) |>
    req_user_agent("weekly-literature-tutorial") |>  # add a contact address
    req_error(is_error = \(r) FALSE) |>
    req_perform()
  if (resp_status(r) != 200) return(FALSE)            # not registered
  norm   <- \(x) gsub("[^a-z0-9]", "", tolower(x))
  ours   <- norm(title)
  theirs <- norm(resp_body_json(r)$message$title[[1]])
  1 - adist(ours, theirs) / max(nchar(ours), nchar(theirs)) >= 0.85
}
# The self-test: one good reference and two planted errors.
doi <- "10.3897/biss.9.181968"
stopifnot(
   resolves(doi, paste("AI-Assisted Exploration, Curation, and Extension",
                       "of Biodiversity Data Using iChatBio")),
  !resolves(doi, "A title that belongs to some other paper"),
  !resolves("10.1234/no-such-doi", "Anything at all"))
cat("SELF-TEST PASSED\n")
